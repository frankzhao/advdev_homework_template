#!/bin/bash
# Setup Production Project (initial active services: Green)
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo "Setting up Parks Production Environment in project ${GUID}-parks-prod"

# Code to set up the parks production project. It will need a StatefulSet MongoDB, and two applications each (Blue/Green) for NationalParks, MLBParks and Parksmap.
# The Green services/routes need to be active initially to guarantee a successful grading pipeline run.

# To be Implemented by Student
oc project $GUID-parks-prod
oc policy add-role-to-user view --serviceaccount=default
oc policy add-role-to-user edit system:serviceaccount:$GUID-jenkins:jenkins

MONGODB_DATABASE="mongodb"
MONGODB_USERNAME="mongodb_user"
MONGODB_PASSWORD="mongodb_password"
MONGODB_SERVICE_NAME="mongodb"
MONGODB_ADMIN_PASSWORD="mongodb_admin_password"
MONGODB_VOLUME="4Gi"

oc new-app -f ../templates/mongo-stateful.template.yaml \
    -n $GUID-parks-prod\
    --param MONGODB_DATABASE=${MONGODB_DATABASE}\
    --param MONGODB_USERNAME=${MONGODB_USERNAME}\
    --param MONGODB_PASSWORD=${MONGODB_PASSWORD}\
    --param MONGODB_ADMIN_PASSWORD=${MONGODB_ADMIN_PASSWORD}\
    --param MONGODB_VOLUME=${MONGODB_VOLUME}\
    --param MONGODB_SERVICE_NAME=${MONGODB_SERVICE_NAME}

# config map
oc create configmap parks-mongodb-config \
    --from-literal=DB_HOST=${MONGODB_SERVICE_NAME}\
    --from-literal=DB_PORT=27017\
    --from-literal=DB_USERNAME=${MONGODB_USERNAME}\
    --from-literal=DB_PASSWORD=${MONGODB_PASSWORD}\
    --from-literal=DB_NAME=${MONGODB_DATABASE}\
    --from-literal=DB_REPLICASET=rs0

# # parksmap
# oc new-build --binary=true --name=parksmap --image-stream=redhat-openjdk18-openshift:1.2 --allow-missing-imagestream-tags=true
# oc new-app $GUID-parks-prod/parksmap:0.0-0 --name=parksmap --allow-missing-imagestream-tags=true -l type=parksmap-frontend -e APPNAME="ParksMap (Prod)"
# oc rollout pause dc parksmap
# oc set triggers dc/parksmap --remove-all
# oc expose dc/parksmap --port=8080 --name=parksmap
# oc create route edge parksmap --service=parksmap --port=8080
# oc set probe dc/parksmap --readiness \
#     --get-url=http://:8080/ws/healthz/ --initial-delay-seconds=30
# oc set probe dc/parksmap --liveness \
#     --get-url=http://:8080/ws/healthz/ --initial-delay-seconds=30
# oc rollout resume dc/parksmap

# # nationalparks
# oc new-build --binary=true --name=nationalparks --image-stream=redhat-openjdk18-openshift:1.2 --allow-missing-imagestream-tags=true
# oc new-app $GUID-parks-prod/nationalparks:0.0-0 --name=nationalparks \
#     --allow-missing-imagestream-tags=true \
#     -l type=parksmap-backend \
#     -e APPNAME="National Parks (Prod)" \
#     -e DB_HOST=$MONGODB_SERVICE_NAME \
#     -e DB_PORT=27017 \
#     -e DB_USERNAME=$MONGODB_USERNAME \
#     -e DB_PASSWORD=$MONGODB_PASSWORD \
#     -e DB_NAME=$MONGODB_DATABASE \
#     -n $GUID-parks-prod
# oc rollout pause dc nationalparks
# oc set volume dc/nationalparks --add \
#     --name=parks-mongodb-config \
#     --configmap-name=parks-mongodb-config \
#     -n $GUID-parks-prod
# oc set triggers dc/nationalparks --remove-all
# oc expose dc/nationalparks --port=8080 --name=nationalparks
# oc create route edge nationalparks --service=nationalparks --port=8080
# oc set probe dc/nationalparks --readiness \
#     --get-url=http://:8080/ws/healthz/ --initial-delay-seconds=30
# oc set probe dc/nationalparks --liveness \
#     --get-url=http://:8080/ws/healthz/ --initial-delay-seconds=30
# oc rollout resume dc/nationalparks

# mlbparks
oc new-app $GUID-parks-prod/mlbparks-green:0.0 --name=mlbparks-green \
    --allow-missing-imagestream-tags=true \
    --allow-missing-images=true \
    -l type=parksmap-backend \
    -e APPNAME="MLB Parks (Prod)" \
    -e DB_HOST=$MONGODB_SERVICE_NAME \
    -e DB_PORT=27017 \
    -e DB_USERNAME=$MONGODB_USERNAME \
    -e DB_PASSWORD=$MONGODB_PASSWORD \
    -e DB_NAME=$MONGODB_DATABASE \
    -n $GUID-parks-prod
oc rollout pause dc mlbparks-green
oc set volume dc/mlbparks-green --add \
    --name=parks-mongodb-config \
    --configmap-name=parks-mongodb-config \
    -n $GUID-parks-prod
oc set triggers dc/mlbparks-green --remove-all
# oc expose dc/mlbparks-green --port=8080 --name=mlbparks-green
# oc create route edge mlbparks-green --service=mlbparks-green --port=8080
oc set probe dc/mlbparks-green --readiness \
    --get-url=http://:8080/ws/healthz --initial-delay-seconds=30
oc set probe dc/mlbparks-green --liveness \
    --get-url=http://:8080/ws/healthz --initial-delay-seconds=30
oc rollout resume dc/mlbparks-green

oc new-app $GUID-parks-prod/mlbparks-blue:0.0 --name=mlbparks-blue \
    --allow-missing-imagestream-tags=true \
    --allow-missing-images=true \
    -l type=parksmap-backend \
    -e APPNAME="MLB Parks (Prod)" \
    -e DB_HOST=$MONGODB_SERVICE_NAME \
    -e DB_PORT=27017 \
    -e DB_USERNAME=$MONGODB_USERNAME \
    -e DB_PASSWORD=$MONGODB_PASSWORD \
    -e DB_NAME=$MONGODB_DATABASE \
    -n $GUID-parks-prod
oc rollout pause dc mlbparks-blue
oc set volume dc/mlbparks-blue --add \
    --name=parks-mongodb-config \
    --configmap-name=parks-mongodb-config \
    -n $GUID-parks-prod
oc set triggers dc/mlbparks-blue --remove-all
# oc expose dc/mlbparks-blue --port=8080 --name=mlbparks-blue
# oc create route edge mlbparks-blue --service=mlbparks-blue --port=8080
oc set probe dc/mlbparks-blue --readiness \
    --get-url=http://:8080/ws/healthz --initial-delay-seconds=30
oc set probe dc/mlbparks-blue --liveness \
    --get-url=http://:8080/ws/healthz --initial-delay-seconds=30
oc rollout resume dc/mlbparks-blue

oc create route edge mlbparks --service=mlbparks-green --port=8080