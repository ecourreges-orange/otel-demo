#!/bin/bash

[ -z "$JAVA_XMS" ] && JAVA_XMS=2048m
[ -z "$JAVA_XMX" ] && JAVA_XMX=2048m

set -e

# OpenTelemetry:
# https://github.com/open-telemetry/opentelemetry-java-instrumentation
JAVA_OPTS="${JAVA_OPTS} \
  -Xms${JAVA_XMS} \
  -Xmx${JAVA_XMX} \
  -Dapplication.name=${APP_NAME} \
  -Dapplication.home=${APP_HOME} \
  -Dotel.exporter=jaeger \
  -Dotel.exporter.jaeger.endpoint=${JAEGER_HOST}:14250 \
  -Dotel.exporter.jaeger.service.name=${APP_NAME} \
  -Dotel.config.sampler.probability=${SAMPLING_PROBABILITY} "


if [ "$SLEUTH" = "yes" ]; then
   CONF_LOC=/config/application.yml,${APP_HOME}/config/application.properties 
else
   CONF_LOC=/config/application.yml
fi

if [ "$OTEL" = "yes" ]; then
    JAVA_OPTS="${JAVA_OPTS} -javaagent:${APP_HOME}/opentelemetry-javaagent-all.jar -Dspring.sleuth.enabled=false"
fi

exec java  ${JAVA_OPTS} \
  -jar "${APP_HOME}/${APP_NAME}.jar" \
  --spring.config.location=${CONF_LOC}

