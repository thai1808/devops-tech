# FROM openjdk:17.0.2-oraclelinux8
# 
# COPY target/obo-0.0.1-SNAPSHOT.jar obo-0.0.1-SNAPSHOT.jar
# 
# ENTRYPOINT ["java","-jar","/obo-0.0.1-SNAPSHOT.jar"]

FROM ubuntu:20.04 AS builder

RUN apt-get update && apt-get upgrade -y
RUN apt-get install wget tar -y

RUN wget https://download.java.net/openjdk/jdk20/ri/openjdk-20+36_linux-x64_bin.tar.gz
RUN tar -xvf /openjdk-20+36_linux-x64_bin.tar.gz
RUN mv jdk-20 /opt/

ENV JAVA_HOME="/opt/jdk-20"
ENV PATH="$JAVA_HOME/bin:$PATH"

RUN java --version

RUN wget https://mirrors.estointernet.in/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
RUN tar -xvf apache-maven-3.6.3-bin.tar.gz
RUN mv apache-maven-3.6.3 /opt/

ENV M2_HOME="/opt/apache-maven-3.6.3"
ENV PATH="$M2_HOME/bin:$PATH"

RUN mvn --version

COPY . /techmaster-obo-web

WORKDIR /techmaster-obo-web

RUN mvn install

FROM ubuntu:20.04 AS artifact

COPY --from=builder /opt/jdk-20/ /opt/jdk-20/
COPY --from=builder /opt/apache-maven-3.6.3/ /opt/apache-maven-3.6.3/

ENV JAVA_HOME="/opt/jdk-20"
ENV M2_HOME="/opt/apache-maven-3.6.3"
ENV PATH="$M2_HOME/bin:$JAVA_HOME/bin:$PATH"

COPY --from=builder /techmaster-obo-web/src/main/resources/ techmaster-obo-web/src/main/resources/
COPY --from=builder /techmaster-obo-web/target/obo-0.0.1-SNAPSHOT.jar techmaster-obo-web/target/obo-0.0.1-SNAPSHOT.jar

WORKDIR /techmaster-obo-web

ENTRYPOINT ["java", "-jar", "target/obo-0.0.1-SNAPSHOT.jar"]
