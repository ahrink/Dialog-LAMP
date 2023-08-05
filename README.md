# Dialog-LAMP
Dialog to start a LAMP server -- code tested on Ubuntu Server 22.04 fresh install
1. Physical Network Interfaces PNI - pending persistent network configuration and other issues.
... [ignite] a LAMP Dialog Project
... Download, unzip, move files to a folder 
... chmod +x a* and run aDInstall.sh (sh aDInstall.sh)

Notes from the past:
20230711 update
add function "check_tmpLog" to capture standard errors in shell and stop app from creating endless loops.

modified check-Version function to kickstart the app
added function check_tmpLog
removed call to  check_Version from run_Install function
verified app with: 
Linux ahr 5.15.0-76-generic #83~20.04.1-Ubuntu SMP Wed Jun 21 20:23:31 UTC 2023 x86_64 x86_64 x86_64 GNU/Linux
REM: fresh install:  Ubuntu 20.04.1 and kylin-desktop

RE: kylin-desktop
# sudo passwd root # set root user
# read this 1st: https://github.com/ahrink/Ubuntu-Kylin-23.04
# ...
# apt install ubuntukylin-desktop

# press ok → select lghtdm
# select → ukui login
# apt-get update
# nano /etc/hostname

#leftovers
# Note: net-tools will be dropped out from required packages in favor of iproute2
# net-tools or ifconfig does not exist on a fresh install of Ubuntu 24 server
# aDApp.sh is using “ifconfig” to display network interface details
# line 37, 65 RE: “ls /sys/class/net/” is backwards compatible
# line 87 “ifconfig” is used and means to rework the code see, tool_kit
# eventually, a tool pouch is needed – but this kit is good enough
# a tool-kit can be inserted in app config evicting medical-surgery of code lines
# watch for kit in config, aDConfig.ahr

# yes, I wrote the above before I got to code, what else “we” need to know?
# line numbers will change, so a new version will be available
# developing (towards the goal):
# 1. suppressing errors seems working
# 2. keep var tFle until successful install
# 3. work on tool-kit eg BIND DNS https://linuxconfig.org/linux-dns-server-bind-configuration
# 4. etc…
# 5. # asof="20230805"
# added simAHR.sh
# https://github.com/ahrink/stamp
# Praevisio Installer is simulation implementing the ahr_stamp as a service for future projects:
# https://github.com/ahrink/Praevisio-Installer

Some references to start with:
- apache2/jammy-updates 2.4.52-1ubuntu4.5 amd64 Apache HTTP Server
- bind9/jammy-updates,jammy-security 1:9.18.12-0ubuntu0.22.04.2 amd64 Internet Domain Name Server
- dnsutils/jammy-updates,jammy-security 1:9.18.12-0ubuntu0.22.04.2 all Transitional package for bind9-dnsutils


 concluding, [ignite] a LAMP Dialog Project
