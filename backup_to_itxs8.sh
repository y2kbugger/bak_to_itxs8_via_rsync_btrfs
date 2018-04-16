#! /usr/bin/env bash

bakroot="/media/itxs8_fs"
bakdatetime=$(date +%Y-%m-%dT%H:%M:%S%z)

case "$HOSTNAME" in
  15r)
    backupname=$HOSTNAME
    ;;
  *)
    echo "Is this running from pix2?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) backupname="pix2"; break;;
            No ) exit;;
        esac
    done
    ;;
esac

data="${bakroot}/$backupname"
snap="${bakroot}/bak/$backupname/${bakdatetime}"

shopt -s expand_aliases
alias rsynclog="ssh y2k@192.168.1.228 \"cat >> $snap.log\""


echo "Dry run?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) dry="--dry-run"; break;;
        No ) dry=""; break;;
    esac
done

# backup current state
rsync -avihx ${dry} --delete --progress ~/ y2k@192.168.1.228:$data | rsynclog
sync

# make a read only snapshot if not dry-run
[ -z "$dry" ] && ssh y2k@192.168.1.228 "sudo btrfs subvolume snapshot -r $data $snap && sync"

if [ -r "/storage/emulated/0" ]; then
    backupname="${backupname}_internal"

    data="${bakroot}/$backupname"
    snap="${bakroot}/bak/$backupname/${bakdatetime}"

    echo $snap
    alias rsynclog="ssh y2k@192.168.1.228 \"cat >> $snap.log\""

    rsync -avihx ${dry} --delete --progress /storage/emulated/0 y2k@192.168.1.228:${data} | rsynclog
    sync

    # make a read only snapshot if not dry-run
    [ -z "$dry" ] && ssh y2k@192.168.1.228 "sudo btrfs subvolume snapshot -r ${data} $snap && sync"
fi
