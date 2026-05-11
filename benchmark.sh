#!/bin/sh
# Benchmark kwinctrl vs ww-run-raise raising a ghostty window.
# Requires: ghostty running, hyperfine, target/release/kwinctrl built.
# Usage: ./benchmark.sh   (override runs: RUNS=5 ./benchmark.sh)
set -eu

RUNS='10'
FILTER='com.mitchellh.ghostty'
PROCESS='ghostty'
SLEEP='0.25'

KWINCTRL="./target/release/kwinctrl --toggle --filter ${FILTER} --process ${PROCESS}"
WW="./ww-run-raise/ww --toggle --filter ${FILTER}"
PREPARE="sleep ${SLEEP} && ${KWINCTRL} && sleep ${SLEEP}"

exec hyperfine \
    --runs "${RUNS}" \
    --prepare "${PREPARE}" \
    --command-name kwinctrl "${KWINCTRL}" \
    --command-name ww "${WW}"
