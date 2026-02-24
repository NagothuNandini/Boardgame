FROM docker.io/library/eclipse-temurin:17-jre-alpine
WORKDIR /app

# Copy pre-built JAR from workspace
COPY target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]
