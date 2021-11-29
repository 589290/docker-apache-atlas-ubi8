#!/bin/bash

cd /opt/apache-atlas-2.2.0 \
&& ./bin/atlas_start.py -setup \
&& sleep 600 \
&& ./bin/atlas_start.py \
&& while true
  do
    sleep 3600
  done

#RUN cd /opt/apache-atlas-${ATLAS_VERSION} \
#    && ./bin/atlas_start.py -setup || true

#RUN cd /opt/apache-atlas-${ATLAS_VERSION} \
#    && ./bin/atlas_start.py & \
#    touch /opt/apache-atlas-${ATLAS_VERSION}/logs/application.log \
#    && tail -f /opt/apache-atlas-${ATLAS_VERSION}/logs/application.log | sed '/AtlasAuthenticationFilter.init(filterConfig=null)/ q' \
#    && sleep 10 \
#    && python3 /opt/apache-atlas-${ATLAS_VERSION}/bin/atlas_stop.py