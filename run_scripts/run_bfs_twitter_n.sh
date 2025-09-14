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

echo "running for $graph for N=$bfs_N"

./run_scripts/drop_cache.sh

numactl --hardware

numactl -N 0 vmtouch -t benchmark/graphs/$graph.sg

numactl --hardware

if  [ "$mem_pressure" -eq 1 ]; then
    numactl -m 0 ../tormentor/fragtor 560 &
    numactl -m 1 ../tormentor/fragtor 670 &


    sleep 100

    numactl --hardware
fi

if [ "$always" -eq 1 ]; then
   echo always > /sys/kernel/mm/transparent_hugepage/enabled
   #echo always > /sys/kernel/mm/transparent_hugepage/defrag
   #echo 0 > /proc/sys/vm/compaction_proactiveness
fi

for i in 1 2 3
do
        time ./bfs -f benchmark/graphs/$graph.sg -n$bfs_N > /dev/null
done

if [ "$always" -eq 1 ]; then
   echo madvise > /sys/kernel/mm/transparent_hugepage/enabled
   #echo madvise > /sys/kernel/mm/transparent_hugepage/defrag
   #echo 20 > /proc/sys/vm/compaction_proactiveness
fi

if  [ "$mem_pressure" -eq 1 ]; then
    pkill fragtor

    sleep 30

    numactl --hardware
fi

vmtouch -e benchmark/graphs/$graph.sg

numactl --hardware
