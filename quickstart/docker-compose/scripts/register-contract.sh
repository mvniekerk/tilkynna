#/bin/sh
#
# *************************************************
# Copyright (c) 2019, Grindrod Bank Limited
# License MIT: https://opensource.org/licenses/MIT
# **************************************************
#
export A3S_IDENTITY_SERVER_BASE_URL=http://a3s-identity-server
export A3S_BASE_URL=http://a3s:80
export A3S_USERNAME="a3s-bootstrap-admin"
export A3S_PASSWORD="Password1#"
export A3S_CLIENT_ID="a3s-default"
export A3S_SECRET="secret"

get_token() {
    sleep 30 # avoid timeout  
    echo "Getting token"
    export TOKEN=`curl \
    -s -v \
    -X POST ${A3S_IDENTITY_SERVER_BASE_URL}/connect/token \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -H 'cache-control: no-cache' \
    -d "grant_type=password&username=${A3S_USERNAME}&password=${A3S_PASSWORD}&client_id=${A3S_CLIENT_ID}&client_secret=${A3S_SECRET}" \
    | jq -r '.access_token'`
    echo "TOKEN is :$TOKEN" 
    echo
    echo
}

register_contract() {
    echo "Registering contract"

    curl -s -v \
        -H "Accept: application/json" \
        -H "Content-Type: application/x-yaml" \
        -H "Authorization: Bearer $TOKEN" \
        -H "cache-control: no-cache" \
        -X PUT \
        --data-binary @/scripts/contract.yaml  \
        ${A3S_BASE_URL}/securityContracts
 
}

get_token

if [ -n "${TOKEN}" ]; then
    ##Uncomment these lines to verify the contract
    # echo "----------------------------------------"
    # cat /scripts/contract.yaml 
    # echo "----------------------------------------"
    register_contract 
else
    echo "TOKEN issue"
    exit 1
fi


