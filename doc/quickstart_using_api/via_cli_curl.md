## Quickstart for using the Tilkynna API 

## Via CLI curl commands

### Pre-requisites

> This example uses:
> * [curl](https://github.com/curl/curl) (a handy command line client to do HTTP requests) and 
> * [jq](https://stedolan.github.io/jq/) (a nice command line JSON processor)
> * sftp: sftp cli must be installed on the host to obtain the generated report from the SFTP destination server.

### Steps

* Get an authentication token in order to get API access:

```bash
TOKEN=`curl \
-s -v \
-X POST http://localhost:80/connect/token \
-H 'Content-Type: application/x-www-form-urlencoded' \
-H 'cache-control: no-cache' \
-d 'grant_type=password&username=tilkynna-admin&password=Password1#&client_id=tylkinna-test-client&client_secret=secret&scope=tilkynna' \
| jq '.access_token' -r` \
&& echo "TOKEN is :$TOKEN"
```


* Create a data source 
We use the Tilkynna database for this sample report.
TilkynnaDB_Datasource

```bash
POSTGRES_HOST=`docker inspect -f '{{ range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' tilkynna_postgresql_1` \
&& DATASOURCE=`curl -s -X POST \
  http://localhost:9981/datasources \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "cache-control: no-cache" \
  -d '{
  "name": "stores",
  "description": "stores",
  "connection": {
    "driver": "org.postgresql.Driver",
    "url": "'"jdbc:postgresql://$POSTGRES_HOST:5432/tilkynna"'",
    "username": "postgres",
    "password": "postgres"
  }
}' | jq '.header.id' -r`  \
&& echo "DATASOURCE is :$DATASOURCE"
```

* Validate the data source
```bash
curl -s -v -X PUT \
  http://localhost:9981/datasources/$DATASOURCE/validate \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "cache-control: no-cache" \
  -d '{
    "driver": "org.postgresql.Driver",
    "url": "'"jdbc:postgresql://$POSTGRES_HOST:5432/tilkynna"'",
    "username": "postgres",
    "password": "postgres"
}'
```

* Upload a report template:
This uses the sample report available in the postman testing collection:

```bash
postman/tilkynna_sample_report.rptdesign
```

```bash
TEMPLATE=`curl -s -X POST \
  http://localhost:9981/templates \
  -H "Authorization: Bearer $TOKEN" \
  -H "cache-control: no-cache" \
  -H "content-type: multipart/form-data" \
  -F file=@../../postman/tilkynna_sample_report.rptdesign \
  -F "templateName=Sample" \
  -F "tags=Sample, NoParams" \
  -F "datasourceIds=$DATASOURCE" | jq '.templateId' -r` \
&& echo "TEMPLATE is: $TEMPLATE"
```

* Create an SFTP report destination

Note: The SFTP server is running as a container. Run the following command to determine it's host.

```bash
SFTP_HOST=`docker inspect -f '{{ range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' tilkynna_sftp_1` \
&& DESTINATION_ID=`curl -s -X POST \
  http://localhost:9981/destinations \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $TOKEN" \
  -H 'cache-control: no-cache' \
-d '{
  "destinationType": "SFTP",
  "host": "'"$SFTP_HOST"'",
  "port": "22",
  "path" : "/upload",
  "user": "foo",
  "password": "pass",
  "header": {
    "name": "SFTP server",
    "description": "our shared sftp server",
    "securityProtocol": "ssl",
    "timeout": "100000",
    "downloadable": "false"
  }
}' | jq '.header.id' -r` \
&& echo "DESTINATION is: $DESTINATION_ID"
```

* Generate a report

```bash
CORRELATION_ID=`curl -s -X POST \
  http://localhost:9981/templates/$TEMPLATE/generate \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "cache-control: no-cache" \
  -d '{
  "callbackUrl": "https://myserver.com/notification/callback/here",
  "doNotRetry": "false",
  "exportFormat": "PDF",
  "reportParameters": [
    {
      "name": "DestinationType",
      "value": "SFTP"
    }
  ],
  "destinationOptions": {
    "destinationId": "'"$DESTINATION_ID"'",
    "destinationParameters": [
      {
        "name": "path",
        "value": "sub_folder"
      }
    ]
  }
}' | jq '.correlationId' -r` \
&& echo "CORRELATION_ID: $CORRELATION_ID"
```

* Check Status of Report Generation

```bash
curl -X GET \
  http://localhost:9981/reports/$CORRELATION_ID/status \
  -H "Authorization: Bearer $TOKEN" \
  -H 'cache-control: no-cache'
```

* The report can be retrieved using SFTP

If you have `sshpass` installed you can use
```bash
sshpass -p pass sftp -P 2222 -oStrictHostKeyChecking=no foo@localhost:/upload/sub_folder/$CORRELATION_ID.PDF
```

otherwise
```
sftp -P 2222 foo@localhost:/upload/sub_folder/
```
Login credential will be `pass`.
then in the SFTP prompt tpe the following to list files:
```
ls
```
Then download the desired file using
```
get <file-name>
```
Exit the SFTP session using:
```
bye
```