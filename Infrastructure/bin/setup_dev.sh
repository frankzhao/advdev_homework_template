#!/bin/bash
# Setup Development Project
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo "Setting up Parks Development Environment in project ${GUID}-parks-dev"

# Code to set up the parks development project.

# To be Implemented by Student
oc project $GUID-parks-dev
oc policy add-role-to-user view --serviceaccount=default


MONGODB_DATABASE="mongodb"
MONGODB_USERNAME="mongodb_user"
MONGODB_PASSWORD="mongodb_password"
MONGODB_SERVICE_NAME="mongodb-internal"
oc new-app -f ../templates/mongo-stateful.template.yaml -n $GUID-parks-dev

# parksmap
oc new-build --binary=true --name=parksmap --image-stream=redhat-openjdk18-openshift:1.2 --allow-missing-imagestream-tags=true
oc new-app $GUID-parks-dev/parksmap:0.0-0 --name=parksmap --allow-missing-imagestream-tags=true -l type=parksmap-frontend -e APPNAME="ParksMap (Dev)"
oc rollout pause dc parksmap
oc set triggers dc/parksmap --remove-all
oc expose dc/parksmap --port=8080 --name=parksmap
oc create route edge parksmap --service=parksmap --port=8080
oc set probe dc/parksmap --readiness \
    --get-url=http://:8080/ws/healthz --initial-delay-seconds=30
oc set probe dc/parksmap --liveness \
    --get-url=http://:8080/ws/healthz --initial-delay-seconds=30
oc rollout resume dc/parksmap

# nationalparks
oc new-build --binary=true --name=nationalparks --image-stream=redhat-openjdk18-openshift:1.2 --allow-missing-imagestream-tags=true
oc new-app $GUID-parks-dev/nationalparks:0.0-0 --name=nationalparks \
    --allow-missing-imagestream-tags=true \
    -l type=parksmap-backend \
    -e APPNAME="National Parks (Dev)" \
    -e DB_HOST=$MONGODB_SERVICE_NAME \
    -e DB_PORT=27017 \
    -e DB_USERNAME=$MONGODB_USERNAME \
    -e DB_PASSWORD=$MONGODB_PASSWORD \
    -e DB_NAME=$MONGODB_DATABASE
oc rollout pause dc nationalparks
oc set triggers dc/nationalparks --remove-all
oc expose dc/nationalparks --port=8080 --name=nationalparks
oc create route edge nationalparks --service=nationalparks --port=8080
oc set probe dc/nationalparks --readiness \
    --get-url=http://:8080/ws/healthz --initial-delay-seconds=30
oc set probe dc/nationalparks --liveness \
    --get-url=http://:8080/ws/healthz --initial-delay-seconds=30
oc rollout resume dc/nationalparks

# mlbparks
oc new-build --binary=true --name=mlbparks --image-stream=redhat-openjdk18-openshift:1.2 --allow-missing-imagestream-tags=true
oc new-app $GUID-parks-dev/mlbparks:0.0-0 --name=mlbparks \
    --allow-missing-imagestream-tags=true \
    -l type=parksmap-backend \
    -e APPNAME="MLB Parks (Dev)" \
    -e DB_HOST=$MONGODB_SERVICE_NAME \
    -e DB_PORT=27017 \
    -e DB_USERNAME=$MONGODB_USERNAME \
    -e DB_PASSWORD=$MONGODB_PASSWORD \
    -e DB_NAME=$MONGODB_DATABASE
oc rollout pause dc mlbparks
oc set triggers dc/mlbparks --remove-all
oc expose dc/mlbparks --port=8080 --name=mlbparks
oc create route edge mlbparks --service=mlbparks --port=8080
oc set probe dc/mlbparks --readiness \
    --get-url=http://:8080/ws/healthz --initial-delay-seconds=30
oc set probe dc/mlbparks --liveness \
    --get-url=http://:8080/ws/healthz --initial-delay-seconds=30
oc rollout resume dc/mlbparks

# oc new-project $GUID-nationalparks-dev --display-name "Parks Development Environment"
# oc policy add-role-to-user edit system:serviceaccount:$GUID-jenkins:jenkins \
#     -n $GUID-parks-dev

# oc new-build --name=parksmap --image-stream=redhat-openjdk18-openshift:1.2 \
#     --allow-missing-imagestream-tags=true --context-dir=ParksMap \
#     https://github.com/wkulhanek/advdev_homework_template
# oc new-build --name=nationalparks --image-stream=redhat-openjdk18-openshift:1.2 \
#     --allow-missing-imagestream-tags=true --context-dir=Nationalparks \
#     https://github.com/wkulhanek/advdev_homework_template
# oc new-build --name=mlbparks --image-stream=redhat-openjdk18-openshift:1.2 \
#     --allow-missing-imagestream-tags=true --context-dir=MLBParks \
#     https://github.com/wkulhanek/advdev_homework_template



# oc new-app $GUID-nationalparks-dev/nationalparks:0.0-0 \
#     --name=parksmap --allow-missing-imagestream-tags=true \
#     -e APPNAME="Parks Frontend Dev" -l type=nationalparks-frontend

