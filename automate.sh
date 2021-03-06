#!/usr/bin/env bash

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Resize the filesystem if '.racing_robots does not exist'
cd /auto_mate
if [ ! -f .racing_robots ]; then
echo "Resizing filesystem ..."
fdisk /dev/mmcblk0 <<EOF
d
2
n
p
2


w
EOF
touch .racing_robots
echo "NEEDS_RESIZE" > .racing_robots
reboot
else
  RR=`cat .racing_robots`
  if [[ $RR == "NEEDS_RESIZE" ]]; then
    echo "Finalizing filesystem resize ..."
    resize2fs /dev/mmcblk0p2
    echo "DONE" > .racing_robots

    # Create some users
    adduser --quiet --disabled-password -shell /bin/bash --home /home/racing --gecos "Racing Robots" racing
    echo -e 'robots\nrobots\n' | passwd racing
  fi

  # Install some packages
  apt-get update
  apt-get -y install git aptitude

  # Clone presentation to racing robots desktop
  cd /home/racing/
  if [ ! -d "twin_presentation" ]; then
    git clone https://github.com/BioBoost/twin_presentation.git
    mkdir -p /home/racing/Desktop
    ln -s /home/racing/twin_presentation/index.html /home/racing/Desktop/RacingRobots.html
  else
    cd twin_presentation
    git pull
  fi
  # Make sure Desktop dir is owner by racing user
  chown racing:racing /home/racing/Desktop
fi

echo "Done"
