#!/usr/bin/env bash

# Resize the filesystem if '~/.racing_robots does not exist'
cd /auto_mate
if [ ! -f .racing_robots ]; then
echo "Resizing filesystem ..."
sudo fdisk /dev/mmcblk0 <<EOF
d
2
n
p
2


w
EOF
touch .racing_robots
echo "NEEDS_RESIZE" > .racing_robots
sudo reboot
else
  RR=`cat .racing_robots`
  if [[ $RR == "NEEDS_RESIZE" ]]; then
    echo "Finalizing filesystem resize ..."
    sudo resize2fs /dev/mmcblk0p2
    echo "DONE" > .racing_robots

    # Create some users
    sudo adduser --quiet --disabled-password -shell /bin/bash --home /home/racing --gecos "Racing Robots" racing
    echo -e 'robots\nrobots\n' | sudo passwd racing
  fi

  # Install some packages
  sudo apt-get update
  sudo apt-get -y install git aptitude
fi

echo "Done"
