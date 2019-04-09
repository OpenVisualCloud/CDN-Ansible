## Visual Cloud Delivery Network
[![License](https://img.shields.io/badge/license-BSD_3_Clause-stable.svg)](https://github.com/OpenVisualCloud/CDN-Ansible/blob/master/LICENSE)
[![Contributions](https://img.shields.io/badge/contributions-welcome-stable.svg)](https://github.com/OpenVisualCloud/CDN-Ansible/wiki)
[![01.org](https://img.shields.io/badge/01.org-Official-0018F9.svg)](https://01.org/visual-cloud-reference-solution-cdn)
 
  Content Delivery Network are growing in importance are being viewed as new class of CPSs.
  The objective of this project is to share an optimize recipe and a CDN reference solution
  based on open source frameworks. This release is for Intel Select Solution for Visual Cloud Content Delivery on Cascade Lake platform.

## License

  Visual Cloud Delivery Network is license under BSD 3-Clouse. See [LICENSE](https://github.com/OpenVisualCloud/CDN-Ansible/blob/master/LICENSE) for more details.

## Documentation

  Visual Cloud Delivery Network documentation can be found at the [01.org project page](https://01.org/visual-cloud-reference-solution-for-cdn/documentation-list).

## Requirements
 
  > Require Ansible 2.4 or newer \
  > Expects NFVi-BKC Ubuntu-16.04 or Ubuntu-18.04, CentOS-7.6 and RHEL-7.6 hosts \
  > Package will detect the respective Operating System and install the CDN components


 1. These playbooks deploy a implementation of various components of VCDN such as `Apache Traffic Server: Web Server`,
    `FFmpeg: Video encode, decode, transcode framework`, `NGINX: Web Server` and `SVT: Scalable Video Technology for HEVC encoder`. 

 2. To use CDN components, first edit `group_vars/all` (hostname of nginx node for creating ssl 
    certificate and proxy environment).  You can also use `lookup` plugins like `lookup('env', 'http_proxy')` for more detail please checkout Ansible document. 
    This can also be done by following if your targets and control machines are in same environment.
    
    Set the following environment variables-
  ```
     $ export CDN_DIR="Enter the path of CDN directory"
     $ export http_proxy="Enter the http_proxy"
     $ export https_proxy="Enter the https_proxy"
     $ export hostname="Enter the hostname or IP of server"

     $ printf "proxy_env\n http_proxy=\"$http_proxy\"\n https_proxy=\"$https_proxy\"\n\nhostname=\"$hostname\"\n" | sudo tee $CDN_PATH/group_vars/all
  ```     

 3. Also edit the `inventory` file that contains the hostnames/IPs and login credential of 
    the machines on which you want these components to install.

 4. Ansible has host key checking enabled by default. If a host is reinstalled and has a different 
    key in `known_hosts`, this will result in an error message until corrected. You can disable 
    this behavior, you can do so by editing `/etc/ansible/ansible.cfg`

  ```
    [defaults]
    host_key_checking = False
  ```

  Alternatively this can be set by the ANSIBLE_HOST_KEY_CHECKING environment variable:

   ```
    $ export ANSIBLE_HOST_KEY_CHECKING=False
   ```

 5. Generate ssh key in the ansible machine, which we have to copy to all the remote hosts for 
    doing deployments or configurations on them:
   
   ``` 
    $ ssh-keygen -t rsa -b 4096 -C "username@ip_add_of_ansible_machine"
   ```
  
  Now copy the ssh key generated to the remote hosts (Before copying the ssh key make sure that 
  you are able to ssh the remote host where you want to copy the key):
   
   ```
    $ ssh-copy-id remote_user@remote_ip
   ```
    
  To set up SSH agent to avoid retyping passwords, you can do:   
   
   ```
    $ ssh-agent bash
    $ ssh-add ~/.ssh/id_rsa
   ```
  For more detail about ansible setup refer link [Getting Started Ansible](https://docs.ansible.com/ansible/latest/user_guide/intro_getting_started.html).
  
 6. Now as we have setup our `inventory` file and other configurations are done, lets try pinging 
    all the servers listed in the `inventory` file.
 
   ```
    $ ansible -i inventory all -m ping
   ```

  If pinging get successfull, then we are good and can go further :) 

 7. For running the playbook go inside CDN directory where you have `CDN.yml`, `inventory` etc., should 
    be present. The ansible playbook command is given below:
 
   ```
    $ ansible-playbook -i inventory CDN.yml --become -K
   ```

  here -K, ask for privilege escalation password
 
  When the playbook run complete, the CDN components will be installed successfully on the target machines. 


 ### ansible_install.sh
 
  The `ansible_install.sh` script provided will install the ansible and configure the target machines.
  First make the script executable and then run in same directory like:
  
```
   $ chmod +x ansible_install.sh
   $ ./ansible_install.sh
```

  1. Script will install the dependencies required for ansible, and ansible version 2.7.1. 
  2. It will also generate the ssh key in ansible machine (where ansible is installing) for this it will 
     prompt for IP address username of ansible machine.
  3. Now it will prompt for how many target machines you want to configure. 
  4. Then you have to enter the username and IP address of the target machines one by one, so that ssh key 
     will successfully copied to these target machines.

  If you are using ansible_install.sh script for installing ansible then you don't need to generate and copy ssh key manually. 



 ## Visual Cloud Delivery Network Components


  ### Apache traffic Server: Web Server

  Apache Traffic Server is a high-performance web proxy cache that improves network efficiency and 
  performance by caching frequently-accessed information at the edge of the network. This role install 
  and configure the apache traffic server from source. After `CDN.yml` run completes, you can start the 
  trafficserver using `start_ats.yml`, before starting trafficserver you need to edit the `remap.config` 
  in target machine at `/opt/ats/etc/trafficserver/remap.config`, edit the IP and port of your server, you can also edit 
  `storage.config`, `records.config` as well as other config files accordingly in target machines at `/opt/ats/etc/trafficserver/*`.

  This Playbook will copy the optimal config files to target machines, if you want to edit any of config file 
  you can do in target machine at `/opt/ats/etc/trafficserver/*`
 
 ```
   $ ansible-playbook -i inventory start_ats.yml --become -K 
 ```

 If you have made any changes in config files and want to restart the trafficserver then run the 
 `stop_ats.yml`, like:

  ```
   ansible-playbook -i inventory stop_ats.yml --become -K 
  ```
 Then start the trafficserver using `start_ats.yml` 

  vars directory contains the variable that are used in `tasks/main.yml`
  handlers directory contains the handlers that are triggers by notify in `tasks/main.yml`
  template directory contains the config files that will be copied to target machines


  ### NGINX: Web Server

  NGINX is server for web serving, media streaming. In addition to its HTTP and HTTPS server capabilities. 
  **nginx+rtmp-module** Media streaming, http and https. This role install and configure the nginx+rtmp-module 
  server from source. 

  This Playbook will copy the optimal nginx.conf files to target machines, if you want to make changes in conf
  file you can do that at `/usr/local/nginx/conf/nginx.conf`.


  After CDN.yml run completes, you can start the nginx using `start_nginx.yml` inside nginx role, like:
  
  ```
    $ ansible-playbook -i inventory start_nginx.yml --become -K 
  ```

  If you made any changes in conf files and want to restart the nginx then run the `stop_nginx.yml`, like:
 
  ```
    $ ansible-playbook -i inventory stop_nginx.yml --become -K 
  ```
  
  Then start the nginx using `start_ats.yml` like above. 

  vars directory contains the variable that are used in `tasks/main.yml`
  handlers directory contains the handlers that are triggers by notify in `tasks/main.yml`
  template directory contains the conf file that will be copied to target machines


  ### FFmpeg: Web Server

  FFmpeg is a command line tool for video and audio transcoding for both live and static content.
  This role install and configure the ffmpeg from source.
  ffmpeg is a very fast video and audio converter that can also grab from a live audio/video source.
  It can also convert between arbitrary sample rates and resize video on the fly with a high 
  quality polyphase filter.  
  
  This playbook will configure following codecs:

  - H.264 (libx264) video encoder
  - H.265 (libx265) video encoder
  - AV1 (libaom) video encoder/decoder
  - VP8/VP9 (libvpx) video encoder/decoder
  - AAC (libfdk-aac) audio encoder
  - MP3 (libmp3lame) audio encoder
  - Opus (libopus) audio decoder and encoder
    
  For running the ffmpeg, go to localtion where input files are stored and run the ffmpeg command
  with or without codec:

  ```
    $ ffmpeg -i InputVideo.mpg ...[video options] [audio options] [output]
  ```

  For more detail, please refer manual page of ffmpeg:

  ```
    $ man ffmpeg 
  ```

  ### SVT: Scalabale Video Technology for HEVC encoder

  The Scalable Video Technology for HEVC Encoder (SVT-HEVC Encoder) is an HEVC-compliant encoder library core 
  that achieves excellent density-quality tradeoffs, and is highly optimized for Intel Xeon  Scalable 
  Processor and on D processors. \
  This role install ans build the SVT-HEVC from source. 
  
  1. For running SVT copy the binary (`HevcEncoderApp`, `libHevcEncoder.so`) from */opt/SVT-HEVC/Bin/Release* 
     to any location of your choice.
  2. Change the permissions on the sample application `HevcEncoderApp` executable by running the command: 
    
  ```
     $ chmod +x HevcEncoderApp
  ```

  3. cd into your chosen location
  4. Run the sample application to encode.
  5. Sample application supports reading from pipe.Eg.
   
  ```
     $ ffmpeg -i [input.mp4] -nostdin -f rawvideo -pix_fmt yuv420p - | 
       ./HevcEncoderApp -i stdin -n [number_of_frames_to_encode] -w [width] -h [height]
  ```

