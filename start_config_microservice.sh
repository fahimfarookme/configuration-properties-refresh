#!/bin/bash

CONFIG_SERVER_PORT=11001
DEBUG="-Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=6005,suspend=n"

function wait_till_started {
	until [ "`curl --silent --show-error --connect-timeout 1 http://localhost:$1/health | grep 'UP'`" != "" ];
	do
	  echo "sleeping for 10 seconds..."
	  sleep 10
	done
}

function update_in_config_repo {
	echo "prop.date=`date`" > microservice.properties
	git add microservice.properties
	git status
	git commit -m "Auto commit"
	git push origin master
}

printf "\n\nPackaging...\n\n"
mvn clean package

printf "\n\nStarting the config-server...\n\n"
java -Dport=$CONFIG_SERVER_PORT -jar config-server/target/config-server-0.0.1-SNAPSHOT.jar &
wait_till_started   $CONFIG_SERVER_PORT

printf "\n\nStarting the microservice...\n\n"
java $DEBUG -Dconfig.uri=localhost:$CONFIG_SERVER_PORT -Dport=14001 -jar microservice/target/microservice-0.0.1-SNAPSHOT.jar &
wait_till_started   14001

printf "\n\nBefore updating the date property in config-repo...\n\n"
curl http://localhost:14001/config-prop/date

printf "\n\nUpdating the date property in config-repo...\n\n"
update_in_config_repo

printf "\n\nInvoking /refresh endpoint of microservice...\n\n"
curl -X POST http://localhost:14001/refresh

printf "\n\nChecking whether the new date is reflected in microservice...\n\n"
curl http://localhost:14001/config-prop/date

