#!/usr/bin/env bash
#
# Use ./trap_daemon.sh 1
# to run the program in interactive mode
#
# Otherwise:
#   Put trap_daemon.sh into /config/boot/ folder to run the daemon during boot
#
TIMEOUT=90    # Maximum time to do network reconnect before restart the shell
TRACE=$1      # Print debug messages to STDOUT when argument is 1
TRACE=${TRACE:-0}
SCRIPT_NAME=${0##*/}
LOGNAME=/dev/null  # You can use "/var/tmp/${SCRIPT_NAME}.log" for debug purposes

function is_net_alive {
    ping -c1 -W1 -q 9.9.9.9 |grep -c ' 0% packet loss' 
}

function get_socket {
    netstat -apnt 2>/dev/null |grep /shell |awk '{if($2 > 10000 && $6=="ESTABLISHED"){split($4,fm,"."); split($5,to,"."); if(!(fm[1]==to[1]&& fm[2]==to[2] && fm[3]==to[3])){print $2,$4,$5,$7;}}}'
}

function trace {
    if [[ $TRACE == 1 ]]; then
        echo -e $@
    elif [[ $TRACE == 200 ]]; then
        echo -e $@ >>$LOGNAME
    fi
}

if [[ -e /persistfs/no_trap.txt ]]; then  ### NB!  Use it to prevent daemon loading when something doing wrong
    exit;
fi

# Find full path to our script to use it in nohup command later
SOURCE=${BASH_SOURCE[0]}
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
FULLNAME="$DIR/$SCRIPT_NAME"
# Found

echo -e "$(date -u)\tCount= $(ps axww |grep -v grep |grep -c $SCRIPT_NAME)" >>$LOGNAME
if [[ $(ps axww |grep -v grep |grep -c $SCRIPT_NAME ) > 2 ]]; then
    echo -e "$(date -u)\tAlready run - exiting" >>$LOGNAME
    exit
fi

if [[ $TRACE == 200 ]]; then
    echo -e "$(date -u)\tWe are like a daemon" >>$LOGNAME
    sleep 60

elif [[ $TRACE == 0 ]]; then
    echo -e "$(date -u)\tTrying to start as daemon" >>$LOGNAME
    nohup $FULLNAME 200 0<&- &>/dev/null &
    exit
fi

while [[ true ]]; do

line=$(get_socket)

count=$(echo $line |cut -f1 -d' ')
src=$(echo $line |cut -f2 -d' ')
dst=$(echo $line |cut -f3 -d' ')
pid=$(echo $line |cut -f4 -d' '| cut -f1 -d'/')

start=$(date "+%s")
secs=0
if [[ $count > 0 ]]; then
  while [[ true ]]; do
    sleep 1;
    secs=$(( $(date "+%s") - $start ))
    newcount=$(netstat -apnt 2>/dev/null |grep -E "$src\s+$dst\s+ESTABLISHED\s+$pid/" |awk '{print $2}')
    if [[ $count == $newcount ]]; then
        # pause or network is dead
        trace "$(date -u)\t$count\t$src\t$dst\t$pid\t$newcount\tFROZEN $secs secs"
        if [[ $count == 0 ]]; then
            if [[ $(is_net_alive) == 0 ]]; then
                # the network is dead
                # wget 'http://127.0.0.1/cgi-bin/do?cmd=main_screen'; rm -f 'do?cmd=main_screen'
                if [[  $secs > $TIMEOUT ]]; then
                    echo kill -15 $pid
                    trace "Signal sent"
                    break
                fi
            fi
        fi
    #elif [[ $newcount == 0 ]]; then
    #    trace "$(date -u)\t$count\t$src\t$dst\t$pid\t$newcount\tNULL!!!!"
    #    # Socket reopened by shell; We have no packets
    #    if [[ $(is_net_alive) == 0 ]]; then
            #########################
            # Pause playing  (see https://dune-hd.com/support/ip_control/dune_ip_control_overview.txt )
            # wget 'http://127.0.0.1/cgi-bin/do?cmd=ir_code&ir_code=E11EBF00' >/dev/null 2>&1
            # trace "============================= Pause send ================================"
            # rm -f do\?cmd*
            # ################## It doesn't working while net is dead. Player will do it only after socket's reconnect
    #    fi
    else
        trace "$(date -u)\t$count\t$src\t$dst\t$pid\t$newcount"
        if [[ -z $newcount ]]; then
            break
        elif [[ $newcount > 0 ]]; then
            start=$(date "+%s")
        fi
    fi
    count=$newcount
  done
else
    trace "$(date -u)\t$count\t$src\t$dst\t$pid\t Nothing..."
fi

sleep 1;
done