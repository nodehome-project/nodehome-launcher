FROM tomcat:8.5.42-jdk8-openjdk-slim

MAINTAINER nodehome.io <support@nodehome.io>

# Fix sh
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Get Tomcat
RUN ln -s /usr/local/tomcat /opt/tomcat

# Copy source
ADD ./source/ /home/nodehome/NodeHome-Platform-SNS/
ADD ./tools/service-run.sh /usr/local/bin/service-run.sh

ENV CATALINA_HOME /opt/tomcat
ENV PATH $PATH:$CATALINA_HOME/bin

EXPOSE 8886
EXPOSE 8080
EXPOSE 8009
VOLUME "/opt/tomcat/webapps"
WORKDIR /opt/tomcat

# Launch Tomcat
# CMD ["/usr/local/bin/service-run.sh"]