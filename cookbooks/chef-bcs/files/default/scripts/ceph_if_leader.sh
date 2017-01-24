#!/bin/bash

# Helper to check if node is Ceph leader

ceph quorum_status -f json-pretty | \
grep quorum_leader_name | grep -q `hostname -s` >/dev/null

if [ $? -eq 0 ]; then
  $*
fi
