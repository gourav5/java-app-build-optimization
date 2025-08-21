# ---------- Build stage ----------
FROM maven:3.9.6-eclipse-temurin-8 AS builder

WORKDIR /app

# Copy pom.xml and download dependencies (cache Maven repo)
COPY pom.xml .
RUN --mount=type=cache,target=/root/.m2 mvn dependency:go-offline -B

# Copy project files and build JAR
COPY src ./src
RUN --mount=type=cache,target=/root/.m2 mvn clean package -DskipTests

# ---------- Runtime stage ----------
FROM openjdk:8-jre-alpine

# Install bash (cached layer)
RUN apk add --no-cache bash

WORKDIR /app

# Copy built JAR from builder stage
COPY --from=builder /app/target/docker-java-app-example.jar /app/

EXPOSE 8080
CMD ["java", "-jar", "docker-java-app-example.jar"]

