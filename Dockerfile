# Pull base image 
From tomcat:8-jre8 

# Maintainer 
MAINTAINER "iamsaikishore" 
COPY ./webapp.war /usr/local/tomcat/webapps
