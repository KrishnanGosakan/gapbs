#madvise huge page
echo madvise > /sys/kernel/mm/transparent_hugepage/enabled
echo 8192 > /sys/kernel/mm/transparent_hugepage/khugepaged/pages_to_scan
echo 50 > /sys/kernel/mm/transparent_hugepage/khugepaged/scan_sleep_millisecs
echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/alloc_sleep_millisecs

echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/defrag

echo 0 > /proc/sys/kernel/numa_balancing
echo 0 > /proc/sys/kernel/nmi_watchdog

echo 0 > /proc/sys/kernel/randomize_va_space

swapoff -a

#disable turbo
echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo

n="$(nproc)"
m="$(expr $n - 1)"

#write "performance" to scaling_governor
for i in $(seq 0 $m)
do
echo performance > /sys/devices/system/cpu/cpufreq/policy$i/scaling_governor
done

