#!/bin/bash

# Perform first time update / upgrade
if [ ! -e /var/system-updated ]; then
	apt-get update -y || exit 1
	apt-get upgrade -y || exit 1

	touch /var/system-updated
fi
