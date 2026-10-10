# Backend + dashboard image (used by Railway; works with any Docker host).
# Built from the repo root because the backend needs ../proto and ../dashboard.

FROM eclipse-temurin:17-jdk AS build
WORKDIR /src
COPY proto/ proto/
COPY backend/ backend/
WORKDIR /src/backend
# Extract the Spring Boot jar into plain jars: lazysodium can't load its native
# libsodium from a jar nested inside the Boot jar ("URI is not hierarchical").
RUN chmod +x gradlew && ./gradlew bootJar --no-daemon -q \
 && java -Djarmode=tools -jar build/libs/backend-0.0.1-SNAPSHOT.jar extract --destination /app

# Debian-based (not Alpine): lazysodium's bundled libsodium needs glibc.
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/ ./
COPY dashboard/ dashboard/
ENV MESH_DASHBOARD_DIR=/app/dashboard/ \
    JAVA_OPTS="-XX:MaxRAMPercentage=75"
EXPOSE 8080
CMD ["sh", "-c", "exec java $JAVA_OPTS -jar backend-0.0.1-SNAPSHOT.jar"]
