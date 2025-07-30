#!/bin/bash
set -ex

echo "Start ovsdb-server ..."
systemctl start ovsdb-server

# Wait for ovsdb-server to be ready
for i in {1..10}; do
  if ovs-vsctl show; then
    break
  fi
  echo "Waiting for ovsdb-server..."
  sleep 1
done

echo "Configuring controller ..."
ovs-vsctl --retry --timeout=2 --no-wait set Open_vSwitch . \
	external_ids:ovn-remote="tcp:$OVN_SB_IP:6642" \
	external_ids:ovn-encap-ip=`hostname -I` \
	external_ids:ovn-encap-type=geneve

ovs-vsctl --may-exist add-br br-int

echo "Start ovn-controller ..."
systemctl start ovn-controller
