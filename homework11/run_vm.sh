#!/bin/bash

readonly MACHINE_IP="$(ip -4 a s net0.30 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')"
qemu-system-x86_64 \
  -enable-kvm \
  -cpu host \
  -smp 8,sockets=1,cores=4,threads=2 \
  -m 8G \
  -nic user,hostfwd=tcp::11022-:22,hostfwd=tcp::11080-:80,hostfwd=tcp::11043-:443 \
  -monitor stdio \
  -vga virtio \
  -vnc ${MACHINE_IP}:0,to=10000,password=on \
  -drive file=disk0.qcow2 \
  -drive file=debian.iso,media=cdrom
