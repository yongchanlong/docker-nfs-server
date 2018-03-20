#!/bin/bash
set -ex

if [ ! -d "/storage" ]; then
  mkdir /storage
fi

if [ ! -d "/storage/docker-nfs-server" ]; then
  mkdir /storage/docker-nfs-server
fi

file="/storage/docker-nfs-server/exports"
if [ ! -f "$file" ]; then
  echo "
  /storage *(rw,fsid=0,insecure,no_root_squash,no_subtree_check,sync)
  " > /storage/docker-nfs-server/exports
fi

file="/etc/exports"
if [ -f "$file" ]; then
  rm /etc/exports
fi

ln -s /storage/docker-nfs-server/exports /etc/exports
    
mount -t nfsd nfsd /proc/fs/nfsd
# Fixed nlockmgr port
echo 'fs.nfs.nlm_tcpport=32768' >> /etc/sysctl.conf
echo 'fs.nfs.nlm_udpport=32768' >> /etc/sysctl.conf
sysctl -p > /dev/null

rpcbind -w
rpc.nfsd -N 2 -V 3 -N 4 -N 4.1 8
exportfs -arfv
rpc.statd -p 32765 -o 32766
rpc.mountd -N 2 -V 3 -N 4 -N 4.1 -p 32767 -F
