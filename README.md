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

1. Create a selenium python test.

Example "example-chrome-selenium.py":

```
from selenium import webdriver
options = webdriver.ChromeOptions()
options.add_argument('headless')
capabilities = {}
capabilities.update(options.to_capabilities())
driver = webdriver.Remote(command_executor = 'http://selenium:4444/wd/hub', desired_capabilities = capabilities)
driver.get('https://www.fsf.org')
print driver.current_url
```

Things to consider:

* In this example "selenium" is the host wich will run the selenium standalone (see step 3)
* In this example we will need a selenium chrome standalone server

2. Customize the SNMP daemon configuration file to extend it and allow execution of the selenium python test.

Example "example-chrome-snmpd.conf":

```
agentAddress  udp:161
view   systemonly  included   .1.3.6.1.2.1.1
view   systemonly  included   .1.3.6.1.2.1.25.1
rocommunity public  default    -V systemonly
rocommunity6 public  default   -V systemonly
rouser   authOnlyUser
sysLocation    Sitting on the Dock of the Bay
sysContact     Me <me@example.org>
sysServices    72
proc  mountd
proc  ntalkd    4
proc  sendmail 10 1
disk       /     10000
disk       /var  5%
includeAllDisks  10%
load   12 10 5
trapsink     localhost public
iquerySecName   internalUser       
rouser          internalUser
defaultMonitors          yes
linkUpDownNotifications  yes
extend    test1   /bin/echo  Hello, world!
extend example_chrome_selenium /usr/bin/python /example-chrome-selenium.py
master          agentx
```

Things to consider:

* We need to hardcode the container path where we will copy the selenium python test. In this example "/example-chrome-selenium.py"

3. Start up a selenium standalone server (chrome or firefox).

You can skip this step if you use the provided "docker-compose.yml" example.

Example:

```
docker run  --name selenium \
  -e START_XVFB=false \
  -d selenium/standalone-chrome
```

4. Start up the selenium-snmpd container mounting as volumes the selenium test (step 1) and the custon SNMP configuration file (step 2).

You can skip this step if you use the provided "docker-compose.yml" example.

Example:

```
docker run --name snmpd \
  --link selenium:selenium \
  -v docker-selenium-python-snmpd/examples/example-chrome-selenium.py:/example-chrome-selenium.py \
  -v docker-selenium-python-snmpd/examples/example-chrome-snmpd.conf:/etc/snmp/snmpd.conf \
  -d kedu/selenium-python-snmpd
```

5. Test it asking for the right OID.

We provided a "test" container in our "docker-compose.yml" example:

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

Expected output similar to:

```
iso.3.6.1.4.1.8072.1.3.2.3.1.1.23.101.120.97.109.112.108.101.95.99.104.114.111.109.101.95.115.101.108.101.110.105.117.109 = STRING: "https://www.fsf.org/"
```

6. (Optional) In case that you used provided docker compose stop it:

```
CTRL + ESC
```

And remove all the images and networks:

```
docker-compose down
```

# Allowed volumes

```
/example-chrome-selenium.py
```
You can map your custom python selenium test. You should then bind mount a custom "/ect/snmp/snmpd.conf" file pointing to the script path in the docker container filesystem ("/example-chrome-selenium.py" in this example.

Example:

```
-v examples/example-chrome-selenium.py:/example-chrome-selenium.py
```

```
/etc/snmp/snmpd.conf
```

Path to custom SNMP daemon config file. In this file you should add the right path to your custom scripts, but you can change the community password as well, etc.

Example:

```
-v examples/example-chrome-snmpd.conf:/etc/snmp/snmpd.conf
```

```
/etc/default/snmp
```

Default parameters passed to SNMP daemon at start time. Warning: you should always run it in the foreground ("-f" switch) or the container will exit after start.

Example:

```
-v files/snmpd:/etc/default/snmp
```

# Troubleshooting

In this section we will follow the provided example

1. Make sure the selenium python test actually runs properly inside the container

Connect to the container and try to execute it:

```
docker exec -ti snmpd bash
/usr/bin/python /example-chrome-selenium.py
```

Expected output similar to:

```
https://www.fsf.org/
```

If the script throws an exception similar to:

```
Traceback (most recent call last):
  File "/example-chrome-selenium.py", line 6, in <module>
    driver = webdriver.Remote(command_executor = 'http://selenium:4444/wd/hub', desired_capabilities = capabilities)
  File "/usr/local/lib/python2.7/dist-packages/selenium/webdriver/remote/webdriver.py", line 157, in __init__
    self.start_session(capabilities, browser_profile)
  File "/usr/local/lib/python2.7/dist-packages/selenium/webdriver/remote/webdriver.py", line 252, in start_session
    response = self.execute(Command.NEW_SESSION, parameters)
  File "/usr/local/lib/python2.7/dist-packages/selenium/webdriver/remote/webdriver.py", line 319, in execute
    response = self.command_executor.execute(driver_command, params)
  File "/usr/local/lib/python2.7/dist-packages/selenium/webdriver/remote/remote_connection.py", line 374, in execute
    return self._request(command_info[0], url, body=data)
  File "/usr/local/lib/python2.7/dist-packages/selenium/webdriver/remote/remote_connection.py", line 402, in _request
    resp = http.request(method, url, body=body, headers=headers)
  File "/usr/local/lib/python2.7/dist-packages/urllib3/request.py", line 72, in request
    **urlopen_kw)
  File "/usr/local/lib/python2.7/dist-packages/urllib3/request.py", line 150, in request_encode_body
    return self.urlopen(method, url, **extra_kw)
  File "/usr/local/lib/python2.7/dist-packages/urllib3/poolmanager.py", line 323, in urlopen
    response = conn.urlopen(method, u.request_uri, **kw)
  File "/usr/local/lib/python2.7/dist-packages/urllib3/connectionpool.py", line 667, in urlopen
    **response_kw)
  File "/usr/local/lib/python2.7/dist-packages/urllib3/connectionpool.py", line 667, in urlopen
    **response_kw)
  File "/usr/local/lib/python2.7/dist-packages/urllib3/connectionpool.py", line 667, in urlopen
    **response_kw)
  File "/usr/local/lib/python2.7/dist-packages/urllib3/connectionpool.py", line 638, in urlopen
    _stacktrace=sys.exc_info()[2])
  File "/usr/local/lib/python2.7/dist-packages/urllib3/util/retry.py", line 398, in increment
    raise MaxRetryError(_pool, url, error or ResponseError(cause))
urllib3.exceptions.MaxRetryError: HTTPConnectionPool(host='selenium', port=4444): Max retries exceeded with url: /wd/hub/session (Caused by NewConnectionError('<urllib3.connection.HTTPConnection object at 0x7f5
```

Chances are that selenium standalone server is not up. So try to start it up:

```
docker start selenium
```

If throws another exception chances are that your selenium python script needs package not installed in the image.

Have a look to [Dockerfile](https://github.com/Kedu-SCCL/docker-selenium-python-snmpd/blob/master/Dockerfile) and build your own image.

2. Check user that runs SNMP daemon

The user that runs the snmpd daemon is the one executing the selenium python test. If you mounted as a volume a custom "/etc/default/snmp" configuration file you should check the user running the daemon.

We experienced issues when running as a default user "Debian-snmp", because didn't have permissions to create temporary files in the path of the script ("/").

You should need to connect to the container, perform an "apt-get update" and install "procps" package.

3. Checj SNMP is exposed to accept external connections

The main setting to check in the snmpd.conf file is:

```
agentAddress udp:161
```

4. Check SNMP OID

You can perform an snmpwalk to discover the final OID that triggers the selenium python script:

```
docker exec -ti test bash
snmpwalk -v 2c -c public snmpd iso.3.6.1.4.1.8072.1.3.2.3.1.1
```

Expected output similar to:

```
iso.3.6.1.4.1.8072.1.3.2.3.1.1.5.116.101.115.116.49 = STRING: "Hello, world!"
iso.3.6.1.4.1.8072.1.3.2.3.1.1.23.101.120.97.109.112.108.101.95.99.104.114.111.109.101.95.115.101.108.101.110.105.117.109 = STRING: "https://www.fsf.org/"
```

So we can extract the OID's:

```
1.3.6.1.4.1.8072.1.3.2.3.1.1.5.116.101.115.116.49
```

For script located in:

```
 extend    test1   /bin/echo  Hello, world!
```

And:

```
1.3.6.1.4.1.8072.1.3.2.3.1.1.23.101.120.97.109.112.108.101.95.99.104.114.111.109.101.95.115.101.108.101.110.105.117.109
```

For script located in:

```
extend example_chrome_selenium /usr/bin/python /example-chrome-selenium.py
```















