#!/bin/bash

cd /var/lib/jenkins/workspace/PipelineInfra/nginx/terraform
url=http://$(terraform output | cut -b 23- | rev | cut -b 2- | rev)

echo $url

regex = 'Welcome to nginx!'

body=$(curl $url)
echo $body

if [$body =~ $regex] 
then 
    echo "nginx esta no ar" 
    exit 0
else 
    echo "nginx fora" 
    exit 1
fi
