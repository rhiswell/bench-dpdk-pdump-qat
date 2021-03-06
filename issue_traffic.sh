#!/bin/bash

PKTGEN_DIR=/root/workspace/dpdk-pktgen/

PCAP_LIST=${1:-pcaplist.txt}


function app_echo
{
    local msg=${1:-}
    echo "ISSUE_TRAFFIC.SH: $msg"
}


cd $PKTGEN_DIR


function print_usage_then_die
{
    app_echo "Usage: $0 <list_of_pcap_files>"
    exit 1
}


[[ -z "$PCAP_LIST" ]] && print_usage_then_die
./build/pktgen -- -c config -f tx -t ${PCAP_LIST} > /var/log/pktgen_tx.log 2>&1

exit 0
