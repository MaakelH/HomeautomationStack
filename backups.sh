#!/bin/bash

# Load environment variables from script.env file
if [ -f script.env ]; then
    export $(egrep -v '^#' script.env | xargs)
fi

# Set variables for container names
C_NAME_HOMEASSISTANT=${C_NAME_HOMEASSISTANT:-homeassistant}
C_NAME_NODERED=${C_NAME_NODERED:-noderedNew}
C_NAME_GRAFANA=${C_NAME_GRAFANA:-grafanaNew}
C_NAME_INFLUXDB2=${C_NAME_INFLUXDB2:-influxdb2}
C_NAME_TIMESCALEDB=${C_NAME_TIMESCALEDB:-timescaledb}
C_NAME_PGADMIN=${C_NAME_PGADMIN:-pgAdmin}

# Set variables for volume names
V_NAME_HOMEASSISTANT=${V_NAME_HOMEASSISTANT:-homeassistant_homeassistant}
V_NAME_NODERED=${V_NAME_NODERED:-mh_nodered_data}
V_NAME_GRAFANA=${V_NAME_GRAFANA:-mh_grafana}
V_NAME_INFLUXDB2=${V_NAME_INFLUXDB2:-mh_influxdb}
V_NAME_TIMESCALEDB=${V_NAME_TIMESCALEDB:-mh_timescale}
V_NAME_PGADMIN=${V_NAME_PGADMIN:-mh_pgadmin-data}

# Stop and backup Home Assistant
docker stop $C_NAME_HOMEASSISTANT
if [ -f $(pwd)/backups/homeassistant/backup.tar.gz ]; then
    rm -f $(pwd)/backups/homeassistant/backup.tar.gz
fi
docker run --rm -v $V_NAME_HOMEASSISTANT:/config -v $(pwd)/backups/homeassistant:/backup ubuntu tar czf /backup/backup.tar.gz -C /config .
docker start $C_NAME_HOMEASSISTANT

# Stop and backup Node-RED
docker stop $C_NAME_NODERED
if [ -f $(pwd)/backups/nodered/backup.tar.gz ]; then
    rm -f $(pwd)/backups/nodered/backup.tar.gz
fi
docker run --rm -v $V_NAME_NODERED:/data -v $(pwd)/backups/nodered:/backup ubuntu tar czf /backup/backup.tar.gz -C /data .
docker start $C_NAME_NODERED

# Stop and backup Grafana
docker stop $C_NAME_GRAFANA
if [ -f $(pwd)/backups/grafana/backup.tar.gz ]; then
    rm -f $(pwd)/backups/grafana/backup.tar.gz
fi
docker run --rm -v $V_NAME_GRAFANA:/var/lib/grafana -v $(pwd)/backups/grafana:/backup ubuntu tar czf /backup/backup.tar.gz -C /var/lib/grafana .
docker start $C_NAME_GRAFANA

# Stop and backup InfluxDB
docker stop $C_NAME_INFLUXDB2
if [ -f $(pwd)/backups/Influx/backup.tar.gz ]; then
    rm -f $(pwd)/backups/Influx/backup.tar.gz
fi
docker run --rm -v $V_NAME_INFLUXDB2:/var/lib/influxdb2 -v $(pwd)/backups/Influx:/backup ubuntu tar czf /backup/backup.tar.gz -C /var/lib/influxdb2 .
docker start $C_NAME_INFLUXDB2

# Stop and backup TimescaleDB
docker stop $C_NAME_TIMESCALEDB
if [ -f $(pwd)/backups/Timesacaledb/backup.tar.gz ]; then
    rm -f $(pwd)/backups/Timesacaledb/backup.tar.gz
fi
docker run --rm -v $V_NAME_TIMESCALEDB:/var/lib/postgresql/data -v $(pwd)/backups/Timesacaledb:/backup ubuntu tar czf /backup/backup.tar.gz -C /var/lib/postgresql/data .
docker start $C_NAME_TIMESCALEDB

# Stop and backup pgAdmin
docker stop $C_NAME_PGADMIN
if [ -f $(pwd)/backups/PgAdmin/backup.tar.gz ]; then
    rm -f $(pwd)/backups/PgAdmin/backup.tar.gz
fi
docker run --rm -v $V_NAME_PGADMIN:/var/lib/pgadmin -v $(pwd)/backups/PgAdmin:/backup ubuntu tar czf /backup/backup.tar.gz -C /var/lib/pgadmin .
docker start $C_NAME_PGADMIN

# Restore file ownership after backup
#sudo chown -R 1000:1000 $(pwd)/backups

