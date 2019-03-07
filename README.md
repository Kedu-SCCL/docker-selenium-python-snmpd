# Table of Contents

- [Introduction](#introduction)
- [Usage](#usage)
- [Allowed volumes](#allowed-volumes)
- [Troubleshooting](#troubleshooting)

# Introduction

SNMP ready container to run python selenium tests.

The purpose is to setup a web monitor that can be integrated with monitoring tools such as Nagios or Zabbix.

An example could be set up a selenium test that automates (headless) a login, a click into a certian part of the website, and a logout, measures the consumed time and returns as a float in seconds.

Your monitoring system (Nagios, Zabbix, etc.) could be configured to graph this monitor and determine spikes in the load time, or even timeouts.

# Usage

1. Create a selenium python test. An example has been provided in "files/example-chrome-selenium.py"

2. Configure snmpd configuration to suit your needs. An example has been provided in "files/example-chrome-snmpd.conf".

Please take into account that you should reference in your snmpd.conf file the script created in the step 1. In our example:

```
extend example_chrome_selenium /usr/bin/python /example-chrome-selenium.py
```

3. Start up a selenium standalone server (chrome or firefox). An example "docker-compose.yml" file has been provided, so you can just to next step.

4. Start up the selenium-snmpd container. An example "docker-compose.yml" file has been provided, so you can jump to next step.

5. Test it asking for the right OID. We provided a "test" container in our "docker-compose.yml" example:

```
cd && git clone https://github.com/Kedu-SCCL/selenium-python-snmpd
cd selenium-python-snmpd
docker-compose up
```

Open a new terminal and ask for the right OID:

```
docker exec -ti test bash
snmpwalk -v 2c -c public snmpd 1.3.6.1.4.1.8072.1.3.2.3.1.1.23.101.120.97.109.112.108.101.95.99.104.114.111.109.101.95.115.101.108.101.110.105.117.109
```

# Allowed volumes

```
-v /path/host/my_custom_python_selenium_test.py:/my_custom_python_selenium_test.py
```

You can map your custom python selenium test. You should then bind mount a custom "/ect/snmp/snmpd.conf" file pointing to the script path in the docker container filesystem ("/my_custom_python_selenium_test.py" in this example.

```
-v /path/host/my_custom_snmpd.conf:/etc/snmp/snmpd.conf
```

Path to custom "snmpd.conf". In this file you should add the right path to your custom scripts, but you can change the community password as well, etc.

# Troubleshooting

TODO
