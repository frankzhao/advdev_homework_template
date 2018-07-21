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
oc new-project $GUID-nationalparks-dev --display-name "Parks Development Environment"
oc policy add-role-to-user edit system:serviceaccount:$GUID-jenkins:jenkins \
    -n $GUID-parks-dev

oc new-build --name=parksmap --image-stream=redhat-openjdk18-openshift:1.2 \
    --allow-missing-imagestream-tags=true --context-dir=ParksMap \
    https://github.com/wkulhanek/advdev_homework_template
oc new-build --name=nationalparks --image-stream=redhat-openjdk18-openshift:1.2 \
    --allow-missing-imagestream-tags=true --context-dir=Nationalparks \
    https://github.com/wkulhanek/advdev_homework_template
oc new-build --name=mlbparks --image-stream=redhat-openjdk18-openshift:1.2 \
    --allow-missing-imagestream-tags=true --context-dir=MLBParks \
    https://github.com/wkulhanek/advdev_homework_template



oc new-app $GUID-nationalparks-dev/nationalparks:0.0-0 \
    --name=parksmap --allow-missing-imagestream-tags=true \
    -e APPNAME="Parks Frontend Dev" -l type=nationalparks-frontend

