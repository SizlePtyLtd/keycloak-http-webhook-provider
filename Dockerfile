FROM maven:latest AS spi-builder

COPY ./ ./
RUN mvn clean install -Dmaven.artifact.threads=30

FROM quay.io/keycloak/keycloak:20.0.2 as builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor

WORKDIR /opt/keycloak
# for demonstration purposes only, please make sure to use proper certificates in production instead
COPY --from=spi-builder ./target/keycloak_http_webhook_provider.jar /opt/keycloak/providers/
RUN /opt/keycloak/bin/kc.sh build --spi-events-listener=http_webhook --spi-events-listener-http_webhook=true

FROM quay.io/keycloak/keycloak:20.0.2 AS keycloak
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# change these values to point to a running postgres instance
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
