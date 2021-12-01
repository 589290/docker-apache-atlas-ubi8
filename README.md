[![Atlas version](https://img.shields.io/badge/Atlas-2.2.0-brightgreen.svg)](https://github.com/589290/docker-apache-atlas)
[![License: Apache 2.0](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0.html)
[![Docker Pulls](https://img.shields.io/docker/pulls/589290/apache-atlas.svg)](https://hub.docker.com/repository/docker/589290/apache-atlas)

Apache Atlas Docker image
=======================================

`Apache Atlas` from the 2.2.0 release source tarball, patched for better docker/maven compatibility, and built using the IronBank [ubi8](https://ironbank.dso.mil/repomap/details;image=ubi8) base image. The [Red Hat ubi](https://catalog.redhat.com/software/containers/ubi8/ubi/5c359854d70cc534b3a3784e) can be substituted in place of the IronBank image.

Atlas is built with `embedded HBase + Solr` and it is pre-initialized, so you can use it right after image download without additional steps.

If you want to use external Atlas backends, set them up according to [the documentation](https://atlas.apache.org/#/Configuration).

Basic usage
-----------
1. Pull the latest release image:

```bash
docker pull 589290/apache-atlas-ubi8:latest
```

2. Start Apache Atlas in a container exposing the web interface on port 21000:

```bash
docker run -d \
    --name atlas \
    -p 21000:21000 \
    589290/apache-atlas-ubi8:latest
```

3. (OPTIONAL) Start Apache Atlas exposing Atlas, SOLR, and HBase web interfaces:

```bash
docker run -d \
    --name atlas \
    -p 21000:21000 \
    -p 9838:9838 \
    -p 61510:61510 \
    -p 61530:61530 \
    589290/apache-atlas-ubi8:latest
```

4. Currently, the Atlas setup & startup scripts error when started at container creation. As such they are currently commented out. To bring Atlas up after container creation, you must shell into the running container and execute the setup and startup scripts manually.

````bash
docker exec -it atlas "/opt/atlas/bin/atlas_start.py -setup"
````

Please, take into account that the first startup of Atlas may take up to few mins depending on host machine performance before web-interface become available at `http://localhost:21000/`

Atlas web default login credentials: `admin / admin`

Usage options
-------------

Gracefully stop Atlas:

```bash
docker exec -it atlas /opt/atlas/bin/atlas_stop.py
```

Check Atlas startup script output:

```bash
docker logs atlas
```

Run the example (this will add sample types and instances along with traits):

```bash
docker exec -it atlas /opt/atlas/bin/quick_start.py
```

Start Atlas overriding settings by environment variables 
(to support large number of metadata objects for example):

```bash
docker run -d \
    --name atlas \
    -e "ATLAS_SERVER_OPTS=-server -XX:SoftRefLRUPolicyMSPerMB=0 \
    -XX:+CMSClassUnloadingEnabled -XX:+UseConcMarkSweepGC \
    -XX:+CMSParallelRemarkEnabled -XX:+PrintTenuringDistribution \
    -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=dumps/atlas_server.hprof \
    -Xloggc:logs/gc-worker.log -verbose:gc -XX:+UseGCLogFileRotation \
    -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=1m -XX:+PrintGCDetails \
    -XX:+PrintHeapAtGC -XX:+PrintGCTimeStamps" \
    -p 21000:21000 \
    589290/apache-atlas-ubi8:latest
```

Start Atlas with data directory mounted on the host to provide its persistency:

```bash
docker run -d \
    --name atlas \
    -v ${PWD}/data:/opt/atlas/data \
    -p 21000:21000 \
    589290/apache-atlas-ubi8:latest
```

Environment Variables
---------------------

The following environment variables are available for configuration:

| Name | Default | Description |
|------|---------|-------------|
| JAVA_HOME | /etc/alternatives/java_sdk_1.8.0_openjdk | The java implementation to use. If JAVA_HOME is not found we expect java and jar to be in path
| ATLAS_OPTS | <none> | any additional java opts you want to set. This will apply to both client and server operations
| ATLAS_CLIENT_OPTS | <none> | any additional java opts that you want to set for client only
| ATLAS_CLIENT_HEAP | <none> | java heap size we want to set for the client. Default is 1024MB
| ATLAS_SERVER_OPTS | <none> |  any additional opts you want to set for atlas service.
| ATLAS_SERVER_HEAP | <none> | java heap size we want to set for the atlas server. Default is 1024MB
| ATLAS_HOME_DIR | <none> | What is is considered as atlas home dir. Default is the base location of the installed software
| ATLAS_LOG_DIR | <none> | Where log files are stored. Defatult is logs directory under the base install location
| ATLAS_PID_DIR | <none> | Where pid files are stored. Defatult is logs directory under the base install location
| ATLAS_EXPANDED_WEBAPP_DIR | <none> | Where do you want to expand the war file. By Default it is in /server/webapp dir under the base install dir.


Bug Tracker
-----------

Bugs are tracked on [GitHub Issues](https://github.com/589290/docker-apache-atlas-ubi8/issues).
In case of trouble, please check there to see if your issue has already been reported.
If you spotted it first, help us smash it by providing detailed feedback and possibly a PR! (^_^)
