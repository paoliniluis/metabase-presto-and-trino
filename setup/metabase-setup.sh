#!/bin/sh

echo "seting up $1"
# get deps
apk add curl jq
# get the wait-until script
curl -L https://raw.githubusercontent.com/nickjj/wait-until/v0.2.0/wait-until -o /usr/local/bin/wait-until && \
chmod +x /usr/local/bin/wait-until
# run the script and everything else
wait-until "echo 'Checking if Metabase is ready' && curl -s http://$1/api/health | grep -ioE 'ok'" 60 && \
if curl -s http://$1/api/session/properties | jq -r '."setup-token"' | grep -ioE "null"; then echo 'Instance already configured, exiting (or <v43)'; else \
echo 'Setting up the instance' && \
token=$(curl -s http://$1/api/session/properties | jq -r '."setup-token"') && \
echo 'Setup token fetched, now configuring with:' && \
echo "{'token':'$token','user':{'first_name':'a','last_name':'b','email':'a@b.com','site_name':'metabot1','password':'metabot1','password_confirm':'metabot1'},'database':null,'invite':null,'prefs':{'site_name':'metabot1','site_locale':'en','allow_tracking':'false'}}" > file.json && \
sed 's/'\''/\"/g' file.json > file2.json && \
cat file2.json && \
sessionToken=$(curl -s http://$1/api/setup -H 'Content-Type: application/json' --data-binary @file2.json | jq -r '.id') && echo ' < Admin session token, exiting' && \
# creating a postgres
curl -s -X POST http://$1/api/database -H 'Content-Type: application/json' --cookie "metabase.SESSION=$sessionToken" --data '{"is_on_demand":false,"is_full_sync":false,"is_sample":false,"cache_ttl":null,"refingerprint":false,"auto_run_queries":true,"schedules":{},"details":{"host":"presto-server","port":8443,"catalog":"postgres","schema":null,"user":"presto","password":null,"ssl":false,"advanced-options":false},"name":"presto-postgres","engine":"presto-jdbc"}' && \
curl -s -X POST http://$1/api/database -H 'Content-Type: application/json' --cookie "metabase.SESSION=$sessionToken" --data '{"is_on_demand":false,"is_full_sync":false,"is_sample":false,"cache_ttl":null,"refingerprint":false,"auto_run_queries":true,"schedules":{},"details":{"host":"presto-server","port":8443,"catalog":"mysql","schema":null,"user":"presto","password":null,"ssl":false,"advanced-options":false},"name":"presto-mysql","engine":"presto-jdbc"}' && \
curl -s -X POST http://$1/api/database -H 'Content-Type: application/json' --cookie "metabase.SESSION=$sessionToken" --data '{"is_on_demand":false,"is_full_sync":false,"is_sample":false,"cache_ttl":null,"refingerprint":false,"auto_run_queries":true,"schedules":{},"details":{"host":"presto-server","port":8443,"catalog":"mongodb","schema":"sample","user":"presto","password":null,"ssl":false,"advanced-options":false},"name":"presto-mongodb","engine":"presto-jdbc"}' && \
curl -s -X POST http://$1/api/database -H 'Content-Type: application/json' --cookie "metabase.SESSION=$sessionToken" --data '{"engine":"starburst","name":"trino-server-postgres","details":{"host":"trino-server","port":8443,"catalog":"postgres","schema":null,"user":"admin","password":null,"ssl":false,"advanced-options":false},"is_full_sync":true}' && \
curl -s -X POST http://$1/api/database -H 'Content-Type: application/json' --cookie "metabase.SESSION=$sessionToken" --data '{"engine":"starburst","name":"trino-server-mongodb","details":{"host":"trino-server","port":8443,"catalog":"mongodb","schema":null,"user":"admin","password":null,"ssl":false,"advanced-options":false},"is_full_sync":true}' && \
curl -s -X POST http://$1/api/database -H 'Content-Type: application/json' --cookie "metabase.SESSION=$sessionToken" --data '{"engine":"starburst","name":"trino-server-mysql","details":{"host":"trino-server","port":8443,"catalog":"mysql","schema":"sample","user":"admin","password":null,"ssl":false,"advanced-options":false},"is_full_sync":true}' && \
curl -s -X POST http://$1/api/database -H 'Content-Type: application/json' --cookie "metabase.SESSION=$sessionToken" --data '{"is_on_demand":false,"is_full_sync":false,"is_sample":false,"cache_ttl":null,"refingerprint":false,"auto_run_queries":true,"schedules":{},"details":{"host":"trino-server","port":8443,"catalog":"postgres","schema":null,"user":"admin","password":null,"ssl":false,"advanced-options":false},"name":"trino-with-presto-driver-postgres","engine":"presto-jdbc"}' && \
curl -s -X POST http://$1/api/database -H 'Content-Type: application/json' --cookie "metabase.SESSION=$sessionToken" --data '{"is_on_demand":false,"is_full_sync":false,"is_sample":false,"cache_ttl":null,"refingerprint":false,"auto_run_queries":true,"schedules":{},"details":{"host":"trino-server","port":8443,"catalog":"mysql","schema":null,"user":"admin","password":null,"ssl":false,"advanced-options":false},"name":"trino-with-presto-driver-mongodb","engine":"presto-jdbc"}' && \
curl -s -X POST http://$1/api/database -H 'Content-Type: application/json' --cookie "metabase.SESSION=$sessionToken" --data '{"is_on_demand":false,"is_full_sync":false,"is_sample":false,"cache_ttl":null,"refingerprint":false,"auto_run_queries":true,"schedules":{},"details":{"host":"trino-server","port":8443,"catalog":"mongodb","schema":null,"user":"admin","password":null,"ssl":false,"advanced-options":false},"name":"trino-with-presto-driver-mysql","engine":"presto-jdbc"}' && \
curl -s -X DELETE http://$1/api/database/1 -H 'Content-Type: application/json' --cookie "metabase.SESSION=$sessionToken"; fi