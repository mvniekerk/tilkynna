[![CircleCI](https://circleci.com/gh/GrindrodBank/tilkynna.svg?style=svg)](https://circleci.com/gh/GrindrodBank/tilkynna)
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FGrindrodBank%2Ftilkynna.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2FGrindrodBank%2Ftilkynna?ref=badge_shield)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=Grindrodbank_tilkynna&metric=alert_status)](https://sonarcloud.io/dashboard?id=Grindrodbank_tilkynna)

# Tilkynna
Tilkynna is an enterprise grade, utility-style report server wrapper written in Java.

## Quickstart

Taking it out for a spin in 5-10 minutes:

### Pre-requisites

> This example uses:
> * [docker](https://www.docker.com): docker must be installed on the host.
> * [docker-compose](https://docs.docker.com/compose/): docker-compose must be installed on the host.


* Clone Github repo:
```bash
git clone git@github.com:GrindrodBank/tilkynna.git
```

* Run using docker-compose:
```bash
cd tilkynna
cd quickstart/docker-compose
docker-compose -p tilkynna up
```

6 services are installed:
* `Web_1` - The actual Tilkynna reporting service installed on port 9981
* `PostgreSQL` Database installed on port 5432
* `A3S PostgreSQL` Database installed on port 5478
* `a3s-identity-server` and `a3s` Authentication services installed on port 80 and 8081 and can be accessed by going to http://localhost:80
* `SFTP` - An SFTP server running on port 2222

### Credentials for PostgreSQL database
* Password: postgres
* Database: tilkynna

### Credentials for A3S
* grant_type: password
* username: tilkynna-admin
* password: Password1#
* client_id: tilkynna-test-client
* client_secret: secret
* scope: tilkynna


### Credentials for SFTP
* Username: foo
* Password: pass

## Using the API 

- [Via CLI curl commands](doc/quickstart_using_api/via_cli_curl.md)
- [Using Postman GUI Tool](doc/quickstart_using_api/via_postman_gui.md)

## To undeploy everything:

```bash
docker-compose -p tilkynna down
```

# Project Documentation

All project documentation is currently available within the `/doc` folder.

[Performance Testing Results are available in the `/doc` folder](doc/performance.md) 


## License
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2FGrindrodBank%2Ftilkynna.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2FGrindrodBank%2Ftilkynna?ref=badge_large)
