# monitor_ntp
Simple bash script to monitor NTP process on old Linux systems
## Description

This is a simple Bash script that verifies the process `ntp` is running normally, firing a restart of the service in the case it is not found in the running processes.

The script is very simple program which is intended to be installed and executed in very old Linux distributions where clock synchronization sometimes dies for unknown and undocumented reasons. 

This problem is known to happen at least in the following Linux Distributions

 * Red Hat Enerprise Linux 4.8 distribution 
 * CentOS 5.x
 * CentOS 6.x

In those systems, where clock synchronization is crucial, the unexpected death of NTP can be a source of many collateral problems, so it is mandatory to be sure that NTP is constantly running, keeping the system clock alligned as much as possible with the global time server.

## Usage

The program is best to be executend under crontab (please see below); although, `monitor_ntp` can be used as standalone command with the following syntax:

```
/path_to_file/monitor_ntp.sh [-h]|[-V]|[-c count][-d delay]
``` 

## Crontab implementation

The best way to implement `monitor_ntp` is via crontab, adding the following line:

```
1 * * * * /path_to_file/monitor_ntp.sh > /dev/null
```

The above line is intended to esecute `monitor_ntp` every hour (which is should be more than enough) restarting `ntp` service in case it is found inactive
