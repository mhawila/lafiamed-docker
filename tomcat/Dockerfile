FROM tomcat:8-jre8-temurin

RUN mkdir -p /usr/local/tomcat/.OpenMRS

COPY openmrs-runtime.properties /usr/local/tomcat/openmrs-runtime.properties
COPY localtime /etc/localtime

EXPOSE 8080
