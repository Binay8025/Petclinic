# -------- Build Stage --------
FROM maven:3.9.6-eclipse-temurin-17 AS builder

WORKDIR /app

COPY pom.xml .

COPY src ./src

RUN mvn clean package -DskipTests

# -------- Runtime Stage --------
FROM jetty:9.4-jre8

# Clean default apps
RUN rm -rf /var/lib/jetty/webapps/*

# Deploy WAR
COPY --from=builder /build/target/petclinic.war /var/lib/jetty/webapps/root.war

EXPOSE 8080

