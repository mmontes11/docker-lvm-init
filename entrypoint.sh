#!/bin/bash

set -euo pipefail

DEVICE="${DEVICE:-/dev/sdb}"
VG_NAME="${VG_NAME:-topolvm}"
THIN_POOL_NAME="${THIN_POOL_NAME:-pool0}"
THIN_POOL_SIZE="${THIN_POOL_SIZE:-95%FREE}"
if [[ "$NODE_NAME" == compute-xlarge-* ]]; then
  THIN_POOL_SIZE="99%FREE"
fi

echo "Waiting for $DEVICE..."
while [ ! -b "$DEVICE" ]; do sleep 1; done

if ! pvs "$DEVICE" >/dev/null 2>&1; then
  echo "Creating physical volume on $DEVICE"
  pvcreate "$DEVICE"
else
  echo "Physical volume already exists on $DEVICE"
fi
pvdisplay "$DEVICE"

if ! vgs "$VG_NAME" >/dev/null 2>&1; then
  echo "Creating volume group $VG_NAME"
  vgcreate "$VG_NAME" "$DEVICE"
else
  echo "Volume group $VG_NAME already exists"
fi
vgdisplay "$VG_NAME"

if ! lvs "$VG_NAME/$THIN_POOL_NAME" >/dev/null 2>&1; then
  echo "Creating thin pool $THIN_POOL_NAME in $VG_NAME"
  lvcreate -T -n "$THIN_POOL_NAME" -l "$THIN_POOL_SIZE" "$VG_NAME"
else
  echo "Thin pool $THIN_POOL_NAME already exists in $VG_NAME"
fi
lvdisplay "$VG_NAME/$THIN_POOL_NAME"

echo "LVM init complete"

exec "$@"