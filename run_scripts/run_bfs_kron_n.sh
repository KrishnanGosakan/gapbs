#!/bin/bash

if  [ "$mem_pressure" -eq 1 ]; then
    echo "mem pressure needed"
fi

if [ "$always" -eq 1 ]; then
   echo "always set"
fi

if [[ ! -v bfs_N ]]; then
   bfs_N=64
fi

if [[ ! -v iters ]]; then
   iters=5
fi

if [[ ! -v recordbpf ]]; then
   recordbpf=0
fi

if [ "$recordbpf" -eq 1 ]; then
   echo "recording with bpftrace"
   bpftrace thpmon.bt -o thprec &
fi

if [[ ! -v disturb ]]; then
   disturb=0
fi

if [ "$disturb" -eq 1 ]; then
   echo "will disturb"
fi
echo "running for $graph for N=$bfs_N"

./run_scripts/drop_cache.sh

numactl --hardware

numactl -N 0 vmtouch -t benchmark/graphs/$graph.sg

numactl --hardware

if  [ "$mem_pressure" -eq 1 ]; then
    numactl ../tormentor/fragtor &


    sleep 250

    numactl --hardware
fi

if [ "$always" -eq 1 ]; then
   echo always > /sys/kernel/mm/transparent_hugepage/enabled
   #echo always > /sys/kernel/mm/transparent_hugepage/defrag
   echo 90 > /proc/sys/vm/compaction_proactiveness
fi

if [ "$disturb" -eq 1 ]; then
   ./do_disturb.sh &
fi

for i in $(seq $iters)
do
        time ./bfs -f benchmark/graphs/$graph.sg -n$bfs_N > /dev/null
done

if [ "$always" -eq 1 ]; then
   echo madvise > /sys/kernel/mm/transparent_hugepage/enabled
   #echo madvise > /sys/kernel/mm/transparent_hugepage/defrag
   echo 20 > /proc/sys/vm/compaction_proactiveness
fi

if  [ "$mem_pressure" -eq 1 ]; then
    pkill fragtor

    sleep 30

    numactl --hardware
fi

if [ "$recordbpf" -eq 1 ]; then
   pkill bpftrace
fi

vmtouch -e benchmark/graphs/$graph.sg

numactl --hardware
