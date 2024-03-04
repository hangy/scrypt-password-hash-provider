# syntax = docker/dockerfile:1.2

ARG DEPENDENCY_KEYCLOAK_VERSION=24.0.0

# build a scrypt password provider for keycloak using maven
FROM maven:3-eclipse-temurin-17 AS builder

ARG DEPENDENCY_KEYCLOAK_VERSION
WORKDIR /build
ADD . /build/
RUN set -x && \
    mvn -B package -Drevision=${DEPENDENCY_KEYCLOAK_VERSION}

ARG DEPENDENCY_KEYCLOAK_VERSION
FROM quay.io/keycloak/keycloak:${DEPENDENCY_KEYCLOAK_VERSION}

USER root
# get the compiled scrypt password hash provider

COPY --from=builder --chown=keycloak:keycloak /build/target/keycloak-scrypt-*.jar /opt/keycloak/providers/
RUN set -x && \
    /opt/keycloak/bin/kc.sh build && \
    chown -R keycloak:root /opt/keycloak
USER keycloak
