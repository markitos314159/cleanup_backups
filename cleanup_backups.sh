#!/bin/bash

# Get Elasticsearch password from Kubernetes secret
ES_PASSWORD=$(kubectl get secret gv-es-elastic-user -o go-template='{{.data.elastic | base64decode}}')

# Get the list of indices starting with "backup_"
INDICES=$(kubectl exec gv-es-default-0 -- curl -s -u "elastic:$ES_PASSWORD" -X GET 'http://localhost:9200/_cat/indices' -H 'Content-Type: application/json' | grep "backup_" | awk '{print $3}')

# Loop through each index and delete it
for INDEX in $INDICES; do
  echo "Deleting index: $INDEX"
  kubectl exec gv-es-default-0 -- curl -s -u "elastic:$ES_PASSWORD" -X DELETE "http://localhost:9200/$INDEX"
  echo "Deleted index: $INDEX"
done
