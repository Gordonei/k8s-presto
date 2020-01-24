FROM prestosql/presto:latest

USER root

RUN \
    set -xeu && \
    yum -y -q update && \
    yum -y -q install \
      curl \
      wget \
      less \
      vim \
      python3 \
      python3-pip && \
    yum -q clean all && \
    rm -rf /var/cache/yum && \
    rm -rf /tmp/* /var/tmp/* \
 # god-awful hack
 && rm -rf /usr/bin/python \
 && ln -s /usr/bin/python3 /usr/bin/python \
 && pip3 install \
      jinja2

ENV PRESTO_HOME /presto
ENV PRESTO_USER presto
ENV PRESTO_DATA_DIR ${PRESTO_HOME}/data
ENV PRESTO_CONFIGS_DIR ${PRESTO_HOME}/etc/conf
ENV PRESTO_CATALOG_DIR ${PRESTO_HOME}/etc/catalog
ENV TEMPLATE_DIR ${PRESTO_HOME}/templates
ENV TEMPLATE_DEFAULT_DIR ${TEMPLATE_DIR}/default_conf
ENV TEMPLATE_CUSTOM_DIR ${TEMPLATE_DIR}/custom_conf
ENV TEMPLATE_CATALOG_DIR ${TEMPLATE_DIR}/catalog
ENV PATH $PATH:$PRESTO_HOME/bin

RUN userdel presto && \
    groupadd presto --gid 1000 && \
    useradd --uid 1000 --gid 1000 \
     --create-home \
     --home-dir ${PRESTO_HOME} \
     --shell /bin/bash \
     $PRESTO_USER \
 && mkdir -p $PRESTO_HOME \
 #&& wget --quiet $PRESTO_BIN \
 #&& tar xzf presto-server-${PRESTO_VERSION}.tar.gz \
 #&& rm -rf presto-server-${PRESTO_VERSION}.tar.gz \
 && mv /usr/lib/presto/* $PRESTO_HOME \
 #&& mv presto-server-${PRESTO_VERSION}/* $PRESTO_HOME \
 #&& rm -rf presto-server-${PRESTO_VERSION} \
 && mkdir -p ${PRESTO_CONFIGS_DIR} \
 && mkdir -p ${PRESTO_CATALOG_DIR} \
 && mkdir -p ${TEMPLATE_DIR} \
 && mkdir -p ${TEMPLATE_DEFAULT_DIR} \
 && mkdir -p ${TEMPLATE_CUSTOM_DIR} \
 && mkdir -p ${TEMPLATE_CATALOG_DIR} \
 && mkdir -p ${PRESTO_DATA_DIR} \
 && cd ${PRESTO_HOME}/bin \
 #&& wget --quiet ${PRESTO_CLI_BIN} \
 #&& mv presto-cli-${PRESTO_VERSION}-executable.jar presto \
 && chmod +x presto \
 && chown -R ${PRESTO_USER}:${PRESTO_USER} ${PRESTO_HOME}

#COPY hive-aux-jars/aws-emr-jsonserde.jar \
#     ${PRESTO_HOME}/plugin/hive-hadoop2/aws-emr-jsonserde.jar
#COPY hive-aux-jars/json-serde-1.3.8-jar-with-dependencies.jar \
#     ${PRESTO_HOME}/plugin/hive-hadoop2/openx-json-serde.jar
COPY template_configs ${TEMPLATE_DEFAULT_DIR}
COPY presto-entrypoint.py ${PRESTO_HOME}/presto-entrypoint.py

#RUN chown ${PRESTO_USER}:${PRESTO_USER} \
#      ${PRESTO_HOME}/plugin/hive-hadoop2/aws-emr-jsonserde.jar \
#      ${PRESTO_HOME}/plugin/hive-hadoop2/openx-json-serde.jar \
# && chmod 644 \
#      ${PRESTO_HOME}/plugin/hive-hadoop2/aws-emr-jsonserde.jar \
#      ${PRESTO_HOME}/plugin/hive-hadoop2/openx-json-serde.jar \
RUN chmod -R 755 ${TEMPLATE_DIR}

USER ${PRESTO_USER}
WORKDIR ${PRESTO_HOME}

EXPOSE 8080

CMD ["python3", "presto-entrypoint.py"]
