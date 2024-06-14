FROM ubuntu:20.04

# Set environment variables to avoid user interaction during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install OpenJDK-11 and other necessary tools
RUN apt-get update && apt-get install -y openjdk-11-jdk wget tar vim curl

# Define environment variables for Java and Tomcat
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64
ENV CATALINA_HOME /opt/tomcat

# Install Tomcat
RUN mkdir -p $CATALINA_HOME \
    && wget -qO- https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.1/bin/apache-tomcat-9.0.1.tar.gz | tar zxv -C $CATALINA_HOME --strip-components=1
RUN sed -i 's/port="8080"/port="8081"/g' $CATALINA_HOME/conf/server.xml

RUN rm -rf $CATALINA_HOME/webapps/*
# Assume the WAR file is in the same directory as the Dockerfile
COPY ./target/TomcatMavenApp-2.3.war $CATALINA_HOME/webapps/ROOT.war

# Expose port 8081
EXPOSE 8081

# Start Tomcat
CMD ["/opt/tomcat/bin/catalina.sh", "run"]
