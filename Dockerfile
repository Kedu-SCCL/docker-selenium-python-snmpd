FROM debian:9

MAINTAINER Kedu SCCL <info@kedu.coop>

ADD requirements.txt .

RUN apt-get update && apt-get install -y \
    snmp \
    snmpd \
    python \
    python-pip && \
    pip install -r requirements.txt

COPY files/entrypoint.sh /

COPY files/snmpd.conf /etc/snmp/

COPY files/snmpd /etc/default/

ENTRYPOINT ["/entrypoint.sh"]
