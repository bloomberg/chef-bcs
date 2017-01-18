#!/bin/bash

# This Zabbix agent script parses the output of `ceph health` and attempts to
# distinguish between blocked/slow ops and other likely more serious events.
# The use of parameterized thresholds allow you to ignore (some) blocked ops /
# slow OSDs at your own risk. Pass "0" as thresholds if you do not ever want to
# ignore blocked ops and slow OSDs.
#
# Usage:
# ceph health | ceph_health_filter <blocked op threshold> <slow OSD threshold>

BLOCKED_OP_RE='[0-9]+ (ops|requests)\ are\ blocked'
BLOCKED_OP_MIN=$1
SLOW_OSD_RE='[0-9]+ osds\ have\ slow\ request'
SLOW_OSD_MIN=$2

STDIN=$(cat)

# Report Ceph health output verbatim if it is not HEALTH_WARN
echo $STDIN | grep -q ^HEALTH_WARN >/dev/null 2>&1 \
|| { echo "$STDIN" && exit 0; }

# If HEALTH_WARN highlights any non-slow/blocked warnings, we exit and trigger
# a regular HEALTH_WARN
COMBINED_RE="($BLOCKED_OP_RE|$SLOW_OSD_RE)"
if [ "`echo "$STDIN" | egrep -vc \"$COMBINED_RE\"`" -ge 1 ]; then
  echo "$STDIN" | sed 's/^HEALTH_WARN/HEALTH_WARN_non_blocked/'
  exit 0
fi

BLOCKED_OP_TXT="`echo \"$STDIN\" | egrep -m 1 -o \"$BLOCKED_OP_RE\"`"
BLOCKED_OP="`echo "$BLOCKED_OP_TXT" | awk '{print $1}'`"

SLOW_OSD_TXT="`echo \"$STDIN\" | egrep -m 1 -o \"$SLOW_OSD_RE\"`"
SLOW_OSD="`echo "$SLOW_OSD_TXT" | awk '{print $1}'`"

# If blocked ops/slow OSDs do not hit threshold, treat state as HEALTH_OK
if [ $BLOCKED_OP -ge $BLOCKED_OP_MIN ] || [ $SLOW_OSD -ge $SLOW_OSD_MIN ]; then
  echo "$STDIN" | sed 's/^HEALTH_WARN/HEALTH_WARN_blocked/'
else
  echo HEALTH_OK
fi
