#!/bin/bash
#
# Copyright (c) 2018, Intel Corporation.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#     * Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of Intel Corporation nor the names of its contributors
#       may be used to endorse or promote products derived from this software
#       without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#



# Check if we're root
if [ "$EUID" -ne 0 ]; then
        echo "Please run this as root"
        exit 1
fi

if [ -f /etc/os-release ]; then
	. /etc/os-release
	OS=$NAME
	VER=$VERSION_ID
	echo
	echo "**********************************"
	echo "  Detected OS: $OS"
	echo "  Installing packages..."
	echo "**********************************"
	echo 
fi

if [ "$OS" = "Ubuntu" ]; then
	apt-get -y install software-properties-common sshpass python3-pip python-pip build-essential libssl-dev libffi-dev python-dev python-keyczar
        pip3 install Jinja2
	pip install httplib2
	pip install cryptography
	pip install pyyaml
	
	apt-add-repository ppa:ansible/ansible
	apt-get update
	apt-get install ansible

elif [ "$OS" = "Red Hat Enterprise Linux Server" ] || [ "$OS" = "CentOS Linux" ] || [ "$OS" = "Fedora" ]; then
	yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
	yum install -y ansible 
	yum install -y python sshpass
fi

echo
echo -e "**********************************"
echo -e "  Packages installed"
echo -e "**********************************"
echo 

read -p "Please enter the IP of host (Ansible) machine (IP of this machine): " -r HOST_IP

read -p "Please enter the user name of host machine: " -r HOST_USER

# Generating the ssh-key in host machine
ssh-keygen -t rsa -b 4096 -C ${HOST_USER}@${HOST_IP}

echo
echo -e "*********************************************************"
echo -e " ssh-key is successfully generated in host machine  "
echo -e "**********************************************************"
echo 

read -p "Enter the numbers of target machines: " -r NUM_TARGETS

# Copying the ssh-key to target machines
for i in $(seq 1 $NUM_TARGETS)
do

read -p "Please enter the IP of target machine ${i}: " -r TARGET_IP

read -p "Please enter the user name of target machine ${i}: " -r TARGET_USER

ssh-copy-id ${TARGET_USER}@${TARGET_IP}

echo
echo -e "*********************************************"
echo -e " ssh-key is copied to target machine ${i} "
echo -e "**********************************************"
echo 

done


