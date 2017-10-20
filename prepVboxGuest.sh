#!/usr/bin/env bash

PHASE_TO_RUN="phase1"
SCRIPT_DIR=$(pwd)
CD_MEDIA_PATH=/run/media/*

# these will get reset when checkforvboxcd() is run
DIRECTORY_NAME=$(whoami)
VBOX_GUEST_CD_PATH="/run/media/$DIRECTORY_NAME/VBOXADDITIONS*"

# Check for sudo access
if [[ $EUID -ne 0 ]]; then
	echo "===--- ERROR ---==="
	echo "This script must be run as root"
	echo "EXAMPLE: sudo $0"
	echo "Help available: $0 help"
	echo "===--- fin ---==="
	exit 1
fi

# Check for Help request
if [[ "$1" == "help" ]]; then
	echo "===--- Help ---==="
	echo "This script is intended to be run on a fresh installation of CentOS 7 that is running in Virtual Box."
	echo "This has been tested with:"
	echo "Virtual Box 5.1.30"
	echo "Using CentOS CentOS-7-x86_64-DVD-1708.iso"
	echo "Using the Gmome Desktop installation with Gnome Applications and Office Suite options."
	echo "It updates the system, and installs necessary components that the Virtual Box Guest Additions package needs to install successfully."
	echo "===--- fin ---==="
	exit 1
fi

# check for phase 2
if [[ "$1" == "phase2" ]]; then
	echo "===--- Phase 2 ---==="
	PHASE_TO_RUN="phase2"
fi

systemRebootCheck(){
	# Reboot
	read -p "System needs to reboot.  Do you want to reboot now? [y/N] " -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
	  reboot
	  exit 0
	else
	  echo "Please reboot the system to apply these changes then continue"
	  exit 0
	fi
}

checkforvboxcd(){
	for DIRECTORY_NAME in $CD_MEDIA_PATH; do
		VBOX_GUEST_CD_PATH="$DIRECTORY_NAME/VBOXADDITIONS*"
		if ls $VBOX_GUEST_CD_PATH > /dev/null 2>&1; then 
			VBOX_GUEST_CD_PATH=$DIRECTORY_NAME/$(ls "$DIRECTORY_NAME/")
			echo "=== Virtual Box Guest Additions CD found at $VBOX_GUEST_CD_PATH"
			return 0 # 0 is true in bash scripts
		fi
		echo "=== Virtual Box Guest Additions CD was NOT found. Please insert the CD"
		echo "--- Using the Virtual Box main menu at the top of the window do this:"
		echo "--- Select Devices > Insert Guest Additions CD Image"
		echo "--- "
		echo "--- if your mouse is captured by the Virtual Box window, press the right Ctrl key on your keyboard to release it."
		return 1 # 1 is false in bash scripts
	done
}

# Make sure that the Virtual Box Guest Additions CD is inserted
if ! checkforvboxcd; then exit 1; fi

# Output and hold the start time for total time calculation.
START_TIME=`date +%s`
echo "$0 starting..."
echo "Start time: $START_TIME"

if [[ "$PHASE_TO_RUN" == "phase1" ]]; then
	echo "=== Getting Updates"
	yum update -y
	echo "=== Ensuring network is set to start on boot"
	sed -i -e "s/ONBOOT=no/ONBOOT=yes/g" /etc/sysconfig/network-scripts/ifcfg-enp0s3
	echo "=== Getting the latest Kernel and tools"
	yum update kernel* -y
	rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
	yum install dkms binutils gcc make patch libgomp glibc-headers glibc-devel kernel-headers kernel-devel bzip2 perl -y
	echo "=== REBOOT REQUIRED ==="
	echo "=== After reboot please run the command:"
	echo "=== "
	echo "===     sudo $0 phase2"
	echo "=== "
	echo "=== REBOOT REQUIRED ==="
	systemRebootCheck
fi

if [[ "$PHASE_TO_RUN" == "phase2" ]]; then
	# Continue After Reboot
	PATH=/sbin:/bin:/usr/sbin:/usr/bin
	KERN_DIR=/usr/src/kernels/`uname -r`
	export KERN_DIR
	$VBOX_GUEST_CD_PATH/VBoxLinuxAdditions.run
	echo "=== REBOOT REQUIRED ==="
	echo "=== "
	echo "=== Everything is done, but the system still needs to reboot"
	echo "=== You do not need to run another command once reboot is complete, but Virtual Box Guest Additions installation is complete."
	echo "=== "
	echo "=== REBOOT REQUIRED ==="
	systemRebootCheck
fi

printf "\n\n======\n Done \n======\n\n"
# calculate and output the total run time.
END_TIME=`date +%s`
TOTAL_RUN_TIME=$((END_TIME-START_TIME))
echo "End time: $END_TIME"
echo "Total Run Time: $TOTAL_RUN_TIME"

