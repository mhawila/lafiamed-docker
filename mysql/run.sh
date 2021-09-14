#!/bin/sh
set -ex

if [ ! -d "/run/mysqld" ]; then
	mkdir -p /run/mysqld
fi

if [ -d "$MYSQL_DATA_DIRECTORY" ]; then
	echo 'MySQL data directory exists'
else
	echo 'MySQL data directory does not exist'
	echo "Creating MySQL data directory: $MYSQL_DATA_DIRECTORY"
	mkdir -p "$MYSQL_DATA_DIRECTORY"
fi

if [ -d "$MYSQL_DATA_DIRECTORY/mysql" ]; then
  	echo 'Data directory already initialized'
else
  	echo 'Initializing database'
 	mysql_install_db --user=root --datadir="$MYSQL_DATA_DIRECTORY" --rpm
	echo 'Database initialized'

	tfile=$(mktemp)
  	if [ ! -f "$tfile" ]; then
      		return 1
  	fi

  	cat <<-EOF > "$tfile"
		USE mysql;
		FLUSH PRIVILEGES;
		GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION;
		UPDATE user SET password=PASSWORD("$MYSQL_ROOT_PASSWORD") WHERE user='root';
		CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` CHARACTER SET utf8 COLLATE utf8_general_ci;
		GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
		GRANT ALL ON \`$MYSQL_DATABASE\`.* to '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
	EOF

  	/usr/sbin/mysqld --user=root --bootstrap --verbose=0 < "$tfile"
  	rm -f "$tfile"

	echo "Importing data to $MYSQL_DATABASE database"
	cat openmrs.sql | mysql_embedded -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"
fi
echo 'Starting server'
exec /usr/sbin/mysqld --user=root --console
