#!/usr/bin/env bash

BIN_DIR=/home/innovate/bin

${BIN_DIR}/hpcc_stop && sudo rm -rf /var/lib/HPCCSystems/* /var/log/HPCCSystems && ${BIN_DIR}/hpcc_start

sudo journalctl --vacuum-time=2d
