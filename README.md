# CentOS-on-VirtualBox
This project allows for simple installation of Virtual Box Guest Additions on a base install of CentOS7 in Virtual Box.  This has been tested using the installation base environment of Gnome Desktop, with Gnome Applications and Office Suite and Productivity options selected using the CentOS-7-x86_64-DVD-1708.iso and Virtual Box version 5.1.30.

## Usage
Note:
In this portion a URL shortener is used that links to the file:
https://raw.githubusercontent.com/deviantlycan/CentOS-on-VirtualBox/master/prepVboxGuest.sh
in this project

In a command terminal, run the following commands:

```
wget https://goo.gl/qQwG1u -O ~/prepVboxGuest.sh
chmod 0755 ~/prepVboxGuest.sh
sudo ~/prepVboxGuest.sh
```

The script will prompt you to reboot. Press "y" on your keyboard to reboot the system.  Once reboot is complete, open a command terminal again and enter the command 

```
sudo ~/prepVboxGuest.sh phase2
```

to complete the installation.
