#!/bin/bash

if [ -z $1 ]; then
    echo "Input target yaml"
    exit 1
fi

tpath=$(realpath $1)

# 아직 테스트중 필수기능 아님
kubeconform -schema-location \
    'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json' \
    -schema-location default \
    -verbose \
    $tpath
