#!/bin/bash
cd /var/lib/jenkins/workspace/PipelineInfra/nginx/terraform

uri=$(terraform output | cut -b 23- | rev | cut -b 2- | rev)

echo $uri

body=$(curl "http://$uri")

regex='Welcome to nginx!'

if [[ $body =~ $regex ]]
then 
    echo "::::: nginx está no ar :::::"
    exit 0
else
    echo "::::: nginx não está no ar :::::"
    exit 1
fi
