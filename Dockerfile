# -------- Build Stage --------
FROM maven:3.8.8-eclipse-temurin-8 AS builder

WORKDIR /build

COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn clean package -DskipTests


# -------- Runtime Stage --------
FROM jetty:9.4-jre8

# Clean default apps
RUN rm -rf /var/lib/jetty/webapps/*

# Deploy WAR
COPY --from=builder /build/target/petclinic.war /var/lib/jetty/webapps/root.war

EXPOSE 8080

