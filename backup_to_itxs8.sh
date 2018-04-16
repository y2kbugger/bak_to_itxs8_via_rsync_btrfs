#! /usr/bin/env bash

bakroot="/media/itxs8_fs"
bakdatetime=$(date +%Y-%m-%dT%H:%M:%S%z)

data="${bakroot}/$HOSTNAME"
snap="${bakroot}/bak/$HOSTNAME/${bakdatetime}"

shopt -s expand_aliases
alias rsynclog="ssh y2k@192.168.1.228 \"cat >> $snap.log\""

# backup current state
rsync -aAXvih --delete --progress /home/y2k/ y2k@192.168.1.228:$data | rsynclog
sync

# make a read only snapshot
ssh y2k@192.168.1.228 "sudo btrfs subvolume snapshot -r $data $snap && sync"
