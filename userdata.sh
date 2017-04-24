#!/bin/bash
FILE=/tmp/firstrun.log
if [ ! -e $FILE ]
then
 touch $FILE
 nohup $0 0<&- &>/dev/null &
 exit
fi

function checkStatus() {
  count=1
  sleep 10;
  STATUS=`cat /var/prompt/ps1`;
  while [[ ${STATUS}x != 'Active'x ]]; do
    echo -n '.';
    sleep 5;
    count=$(($count+1));
    STATUS=`cat /var/prompt/ps1`;

    if [[ $count -eq 60 ]]; then
      checkretstatus=\"restart\";
      return;
    fi
  done;
  checkretstatus=\"run\";
}

function checkF5Ready {
  sleep 5
  while [[ ! -e '/var/prompt/ps1' ]]
  do
    echo -n '.'
    sleep 5
  done

  sleep 5
  STATUS=`cat /var/prompt/ps1`

  while [[ ${STATUS}x != 'NO LICENSE'x ]]
  do
    echo -n '.'
    sleep 5
    STATUS=`cat /var/prompt/ps1`
  done

  echo -n ' '

  while [[ ! -e '/var/prompt/cmiSyncStatus' ]]
  do
    echo -n '.'
    sleep 5
  done

  STATUS=`cat /var/prompt/cmiSyncStatus`
  while [[ ${STATUS}x != 'Standalone'x ]]
  do
    echo -n '.'
    sleep 5
    STATUS=`cat /var/prompt/cmiSyncStatus`
  done
}

function checkStatusnoret {
  sleep 10
  STATUS=`cat /var/prompt/ps1`
  while [[ ${STATUS}x != 'Active'x ]]
  do
    echo -n '.'
    sleep 5
    STATUS=`cat /var/prompt/ps1`
  done
}

exec 1<&-
exec 2<&-
exec 1<>$FILE
exec 2>&1
checkF5Ready
sleep 150
logger -p local0.info 'firstrun debug: starting-tmsh-config'
tmsh modify auth user admin password \"adminadmin\"
tmsh modify auth user admin shell bash
tmsh save /sys config
checkStatusnoret
tmsh modify sys global-settings gui-setup disabled
tmsh create net vlan external interfaces add { 1.1 { untagged } }
tmsh create net self 10.0.1.10 address 10.0.1.10/24 vlan external
tmsh create net vlan internal interfaces add { 1.2 { untagged } }
tmsh create net self 10.0.2.10 address 10.0.2.10/24 vlan internal
tmsh modify sys ntp timezone America/New_York servers add { time.apple.com }
