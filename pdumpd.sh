#!/bin/bash

set -ueo pipefail

PDUMP_DIR=/root/DPDK/dpdk-18.05/app/pdump/

CMD=${1:-}
OUTPUT_PCAP=${2:-}


function app_echo
{
    local msg=${1:-}
    echo "PDUMPD.SH: $msg"
}


function print_usage_then_die
{
    app_echo "Usage: $0 <start|stop|restart> [path_to_save_output_pcap]"
    exit 1
}


[[ -z "$CMD" ]] && print_usage_then_die
([[ "$CMD" = "start" ]] || [[ "$CMD" = "restart" ]]) && [[ -z "$OUTPUT_PCAP" ]] && print_usage_then_die


cd ${PDUMP_DIR}


function kill_pdumpd
{
    (test -e /var/run/pdump.pid && kill -INT $(cat /var/run/pdump.pid) && app_echo "Old job is killed") || app_echo "WARN: no running pdumpd"
    rm -f /var/run/pdump.pid
}


function start_pdumpd
{
    rm -f /tmp/${OUTPUT_PCAP}

    ./dpdk-pdump -- --pdump "port=0,queue=*,rx-dev=${OUTPUT_PCAP}" > /var/log/pdump.log 2>&1 & \
        echo -n $! > /var/run/pdump.pid
    app_echo "Wait 10s for pdumpd becoming ready" && sleep 10
    app_echo "New job is running by pid $(cat /var/run/pdump.pid)"
}


case $CMD in
    start)
        start_pdumpd
        ;;
    stop)
        kill_pdumpd
        ;;
    restart)
        kill_pdumpd
        start_pdumpd
        ;;
    *)
        print_usage_then_die
        ;;
esac

exit 0

