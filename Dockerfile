FROM alpine:3.16.2
WORKDIR /app
RUN apk update && apk add openjdk11-jre-headless && wget https://repo1.maven.org/maven2/com/madgag/bfg/1.14.0/bfg-1.14.0.jar -O bfg.jar
WORKDIR /data
ENTRYPOINT ["java", "-jar", "/app/bfg.jar"]
