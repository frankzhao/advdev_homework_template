#!/bin/bash
# Setup Sonarqube Project
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo "Setting up Sonarqube in project $GUID-sonarqube"

# Code to set up the SonarQube project.
# Ideally just calls a template
# oc new-app -f ../templates/sonarqube.yaml --param .....

# To be Implemented by Student
oc new-app -f ../templates/sonarqube.template.yaml\
  --param POSTGRESQL_USERNAME=sonar\
  --param POSTGRESQL_PASSWORD=sonar\
  --param POSTGRESQL_DATABASE=sonar\
  --param POSTGRESQL_VOLUME=4Gi\
  --param GUID=$GUID
# oc new-app --template=postgresql-persistent --param POSTGRESQL_USER=sonar\
#   --param POSTGRESQL_PASSWORD=sonar --param POSTGRESQL_DATABASE=sonar\
#   --param VOLUME_CAPACITY=4Gi --labels=app=sonarqube_db
# oc new-app https://github.com/wkulhanek/docker-openshift-sonarqube.git
# oc set env dc/docker-openshift-sonarqube SONARQUBE_JDBC_USERNAME=sonar,SONARQUBE_JDBC_PASSWORD=sonar,SONARQUBE_JDBC_URL=jdbc:postgresql://postgresql/sonar
# oc expose svc/docker-openshift-sonarqube
# oc set resources dc/docker-openshift-sonarqube --requests=memory=1.5Gi,cpu=1 --limits=memory=3Gi,cpu=2


