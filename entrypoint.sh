#!/bin/sh

# fluentd
if [[ -z "${FLUENTD_ENABLE}" ]]; then
  echo "FLUENTD_ENABLE variable not defined, fluentd will not start."
else
  echo "FLUENTD is enabled"
  if [[ -z "${SPLUNK_HOST}" ]]; then
    echo "SPLUNK_HOST variable not defined, fluentd will start with /opt/fidexporter/fluent.conf"
    fluentd --config $FLUENTD_CONF  >> /dev/stdout 
  else
  if [[ -z "${SPLUNK_HOST_PORT}" ]]; then
    echo "SPLUNK_HOST_PORT not defined, default set to 8000"
    SPLUNK_HOST_PORT="8000"
  fi
  fi
    echo "Starting fluentd with SPLUNK output to ${SPLUNK_HOST}:${SPLUNK_HOST_PORT}"
    # sed -i "s/SPLUNK_HOST/${SPLUNK_HOST}/" /opt/fidexporter/fluent.conf
    # sed -i "s/SPLUNK_PORT/${SPLUNK_HOST_PORT}/" /opt/fidexporter/fluent.conf
    fluentd --config $FLUENTD_CONF >> /dev/stdout &
fi

# To keep the process running in case to use the image for metrics only
tail -f /dev/null



