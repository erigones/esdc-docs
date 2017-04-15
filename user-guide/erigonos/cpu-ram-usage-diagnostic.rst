CPU/RAM Troubleshooting
***********************

How to display the amount of logical processors
###############################################

.. code-block:: bash

    [root@node01 ~] psrinfo -vp
    The physical processor has 4 cores and 8 virtual processors (1 3 5 7 9 11 13 15)
        The core has 2 virtual processors (1 9)
        The core has 2 virtual processors (3 11)
        The core has 2 virtual processors (5 13)
        The core has 2 virtual processors (7 15)
    x86 (GenuineIntel 106A5 family 6 model 26 step 5 clock 2267 MHz)
      Intel(r) Xeon(r) CPU           E5520  @ 2.27GHz
    The physical processor has 4 cores and 8 virtual processors (0 2 4 6 8 10 12 14)
        The core has 2 virtual processors (0 8)
        The core has 2 virtual processors (2 10)
        The core has 2 virtual processors (4 12)
        The core has 2 virtual processors (6 14)
    x86 (GenuineIntel 106A5 family 6 model 26 step 5 clock 2267 MHz)
      Intel(r) Xeon(r) CPU           E5520  @ 2.27GHz

How to display CPU statistics and load distribution among processors
####################################################################

.. code-block:: bash

    [root@node01 ~] mpstat 1 5
    CPU minf mjf xcal  intr ithr  csw icsw migr smtx  srw syscl  usr sys  wt idl
      0  870   1  274  2440  235  569    2   47   59    0  4709    2   3   0  94
      1  547   1   58   203   63  462    3   19   35    0  4964    2   2   0  95
      2  326   0  142   424  132  690    1   29   52    0  2427    1   2   0  97
      3  168   1   38   325  123  814    1   17   39    0  1875    1   2   0  97
      4  105   0   31   326  135  224    0   16   37    0  1060    1   1   0  98
      5  114   0   25   216   87  382    1   16   31    0  1192    1   1   0  98
      6  116   0   38   459  153  769    1   14   37    0  2732    1   2   0  97
      7  241   1   20   656  185  762    1   15   33    0  1466    0   1   0  98
      8   95   0   34   230   92  327    1    9   26    0  1620    1   1   0  98
      9  111   0   18   238   86  691    1   15   34    0  1481    1   1   0  98
      10   66   0   37   160   64  219    0    7   25    0  1184    0   1   0  99
      11  103   0   21   157   61  345    1   12   26    0  1281    0   1   0  99
      12   50   0   20   721  194  306    1   10   28    0  1318    0   1   0  98
      13  129   0  203   320  141  741    1   15   33    0  1445    1   1   0  98
      14   34   0   13   213   72  342    0    7   25    0  1453    0   1   0  99
      15   94   0   20   406  226  367    1   12   54    0   883    0   1   0  98

* CPU - Processor ID.

.. note:: A high number of following calls can be an indication of performance problems.

    * xcal - Number of inter-processor cross-calls.
    * intr - Number of interrupts.
    * smtx - Number of operations, which couldn't acquire a lock on the first try (spins on mutexes).

* syscl - Number of syscalls.
* usr - Percent of processor user time.
* sys - Percent of processor system time.
* idl - Percent of processor idle time.

How to display the amount of total memory available in the system (MiB)
#######################################################################

.. code-block:: bash

    [root@node01 ~] prtconf -m
    32758

How to display virtual memory usage
###################################

.. code-block:: bash

    [root@node01 ~] vmstat
     kthr      memory            page            disk          faults      cpu
     r b w   swap  free  re  mf pi po fr de sr lf rm s0 s1   in   sy   cs us sy id
     0 0 0 54267716 25895544 366 3131 74 0 0 0 240 6 -268 186 -1 7442 30957 7950 1 1 98

* r - The number of kernel threads in run queue. High values of `r` may indicate performance issues.
* us - User time (%).
* sy - System time (%).
* id - Idle time (%).

How to display processes on the system and in the zones
#######################################################

.. code-block:: bash

    [root@node01 ~] prstat -Z
       PID USERNAME  SIZE   RSS STATE  PRI NICE      TIME  CPU PROCESS/NLWP
      3538 root     2095M 2083M sleep    1    0   0:03:54 0.4% qemu-system-x86/12
      3421 root     2094M 2082M sleep   59    0   0:01:09 0.1% qemu-system-x86/5
        90 root        0K    0K sleep   99  -20   0:00:18 0.0% zpool-zones/238
      3601 root       47M   31M sleep   59    0   0:00:07 0.0% python2.7/1
      3585 root       38M   28M sleep   59    0   0:00:03 0.0% python2.7/1
      3469 root       37M   28M sleep   59    0   0:00:03 0.0% python2.7/1
      2843 root       14M   11M sleep    1    0   0:00:03 0.0% kvmiostat/1
      3632 root       42M   17M sleep    1    0   0:00:00 0.0% python2.7/1
      9573 root     4560K 3408K cpu1     1    0   0:00:00 0.0% prstat/1
       184 root     6156K 2948K sleep    1    0   0:00:00 0.0% syseventd/18
      2829 root     3996K 2436K sleep    1    0   0:00:00 0.0% vm-kvm-disk-io-/1
      2806 root     6092K 4600K sleep    1    0   0:00:00 0.0% vm-network-moni/1
      2203 root     2604K  812K sleep   29    0   0:00:00 0.0% lldpd/1
      2801 root     1876K 1180K sleep   59    0   0:00:00 0.0% ctrun/1
      2738 root     3952K  892K sleep   59    0   0:00:00 0.0% ipmon/1
      2709 root     4888K 3560K sleep    1    0   0:00:00 0.0% picld/4
      2821 root     2120K 1084K sleep   59    0   0:00:00 0.0% cron/1
      2852 daemon   4116K 1812K sleep    1    0   0:00:00 0.0% rpcbind/3
      3560 root       35M   16M sleep    1    0   0:00:00 0.0% python2.7/1
      2834 root     5144K 1216K sleep   59    0   0:00:00 0.0% zabbix_agentd/1
        88 root     2664K 1524K sleep   29    0   0:00:00 0.0% pfexecd/3
        21 root     2988K 1608K sleep   29    0   0:00:00 0.0% dlmgmtd/7
      2825 root     4868K 3392K sleep    1    0   0:00:00 0.0% vm-cpu-monitor/1
      2835 root     5144K 1216K sleep   59    0   0:00:00 0.0% zabbix_agentd/1
    ZONEID    NPROC  SWAP   RSS MEMORY      TIME  CPU ZONE
         3        2 2095M 2083M   6.4%   0:03:54 0.4% f7860689-c435-4964-9f7d-2d2*
         1        2 2094M 2082M   6.4%   0:01:09 0.1% a28faa4d-d0ee-4593-938a-f0d*
         0       89 1330M  629M   1.8%   0:00:50 0.1% global

    Total: 93 processes, 521 lwps, load averages: 0.25, 0.26, 0.26

* PID - Process ID.
* USERNAME - The real user (login) name or real user ID.
* SIZE - The total virtual memory size of the process, including all mapped files and devices.
* RSS - The resident set size of the process (RSS), in kilobytes (K), megabytes (M), or gigabytes (G).
* STATE - The state of the process.

    * cpuN - Process is running on CPU ``N``.
    * sleep - Sleeping: process is waiting for an event to complete.
    * wait - Waiting: process is waiting for CPU usage to drop to the CPU-caps enforced limit.
    * run - Runnable: process in on run queue.
    * zombie - Zombie state: process terminated and parent not waiting.
    * stop - Process is stopped.
* TIME - The cumulative execution time for the process.
* CPU - The percentage of recent CPU time used by the process.
* PROCESS - The name of the process.


How to display memory usage of virtual machines
###############################################

.. code-block:: bash

    [root@node01 ~] zonememstat
                                     ZONE  RSS(MB)  CAP(MB)    NOVER  POUT(MB)
                                   global        0        -        -         -
     a28faa4d-d0ee-4593-938a-f0d062022b02     2082     3072        0         0
     f7860689-c435-4964-9f7d-2d2d70cfe389     2082     3072        0         0

* ZONE - The zone name.
* RSS - The amount of physical memory consumed.
* CAP - The memory cap.
* NOVER - Number of times the zone reached over its cap.
* POUT - The amount of paged out memory.

How to display memory usage by type
###################################

.. code-block:: bash

    [root@node01 ~] echo ::memstat | mdb -k
    Page Summary                Pages                MB  %Tot
    ------------     ----------------  ----------------  ----
    Kernel                     462970              1808    6%
    ZFS File Data              127036               496    2%
    Anon                      1169355              4567   14%
    Exec and libs                4516                17    0%
    Page cache                  15842                61    0%
    Free (cachelist)            19856                77    0%
    Free (freelist)           6584225             25719   79%

    Total                     8383800             32749
    Physical                  8383799             32749

How to display the amount of consumed memory by processes and virtual machines
##############################################################################

.. code-block:: bash

    [root@node01 ~] prstat -s rss -z 3
    PID USERNAME  SIZE   RSS STATE  PRI NICE      TIME  CPU PROCESS/NLWP
    3538 root     2095M 2083M sleep    1    0   0:04:11 0.5% qemu-system-x86/12
    3274 root        0K    0K sleep   60    -   0:00:00 0.0% zsched/1

    Total: 2 processes, 13 lwps, load averages: 0.26, 0.26, 0.26

Interrupt mapping
#############################################

.. code-block:: bash

    [root@node01 ~] echo ::interrupts | mdb -k
    IRQ  Vect IPL Bus    Trg Type   CPU Share APIC/INT# ISR(s)
    3    0xb1 12  ISA    Edg Fixed  10  1     0x0/0x3   asyintr
    4    0xb0 12  ISA    Edg Fixed  9   1     0x0/0x4   asyintr
    9    0x81 9   PCI    Lvl Fixed  1   1     0x0/0x9   acpi_wrapper_isr
    17   0x85 9   PCI    Lvl Fixed  6   1     0x0/0x11  uhci_intr
    18   0x86 9   PCI    Lvl Fixed  7   1     0x0/0x12  uhci_intr
    19   0x83 9   PCI    Lvl Fixed  4   1     0x0/0x13  ehci_intr
    20   0x87 9   PCI    Lvl Fixed  8   2     0x0/0x14  uhci_intr, uhci_intr
    21   0x84 9   PCI    Lvl Fixed  5   3     0x0/0x15  uhci_intr, uhci_intr,ehci_intr
    22   0x40 5   PCI    Lvl Fixed  14  1     0x0/0x16  0
    32   0x20 2          Edg IPI    all 1     -         cmi_cmci_trap
    56   0x82 7   PCI    Edg MSI    2   1     -         pcieb_intr_handler
    57   0x30 4   PCI    Edg MSI    3   1     -         pcieb_intr_handler
    58   0x60 6   PCI    Edg MSI-X  13  1     -         bnx_intr_1lvl
    59   0x41 5   PCI    Lvl Fixed  15  1     0x1/0x0   drsas_isr
    60   0x61 6   PCI    Edg MSI-X  0   1     -         bnx_intr_1lvl
    160  0xa0 0          Edg IPI    all 0     -         poke_cpu
    208  0xd0 14         Edg IPI    all 1     -         kcpc_hw_overflow_intr
    209  0xd1 14         Edg IPI    all 1     -         cbe_fire
    210  0xd3 14         Edg IPI    all 1     -         cbe_fire
    240  0xe0 15         Edg IPI    all 1     -         xc_serv
    241  0xe1 15         Edg IPI    all 1     -         apic_error_intr
    ...

Interrupt monitoring
####################

.. code-block:: bash

    [root@node01 ~] intrstat

      device |      cpu0 %tim      cpu1 %tim      cpu2 %tim      cpu3 %tim      cpu4 %tim      cpu5 %tim
    -------------+------------------------------------------------------------------------------------------
       bnx#0 |         0  0.0         0  0.0         0  0.0         0  0.0         0  0.0         0  0.0
       bnx#1 |        24  0.0         0  0.0         0  0.0         0  0.0         0  0.0         0  0.0
      ehci#0 |         0  0.0         0  0.0         0  0.0         0  0.0         1  0.0         0  0.0
      ehci#1 |         0  0.0         0  0.0         0  0.0         0  0.0         0  0.0         6  0.0
      uhci#0 |         0  0.0         0  0.0         0  0.0         0  0.0         0  0.0         0  0.0
      uhci#1 |         0  0.0         0  0.0         0  0.0         0  0.0         0  0.0         0  0.0
      uhci#2 |         0  0.0         0  0.0         0  0.0         0  0.0         0  0.0         6  0.0
      uhci#3 |         0  0.0         0  0.0         0  0.0         0  0.0         0  0.0         0  0.0
      uhci#4 |         0  0.0         0  0.0         0  0.0         0  0.0         0  0.0         6  0.0
      uhci#5 |         0  0.0         0  0.0         0  0.0         0  0.0         0  0.0         0  0.0

