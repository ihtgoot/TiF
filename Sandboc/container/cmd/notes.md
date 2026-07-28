[[containers]] [[isolation]] [[sandbox]] [[confrence_talk_goto]] [[docker_run]]

# resources:
  * https://chatgpt.com/c/6a590ded-0508-83e8-87bc-1b18fff0a10d


# Container 
  * Namespace , Cgroup , Chroot
```
  └─> docker run --rm -it ubuntu /bin/bash
  Unable to find image 'ubuntu:latest' locally
  latest: Pulling from library/ubuntu
  ed819469700f: Pull complete
  a3679419df18: Pull complete
  e16351a257e4: Download complete
  Digest: sha256:3131b4cc82a783df6c9df078f86e01819a13594b865c2cad47bd1bca2b7063bb
  Status: Downloaded newer image for ubuntu:latest
  root@a0905880f3a3:/# hostname
  a0905880f3a3
  root@a0905880f3a3:/# ps
    PID TTY          TIME CMD
      1 pts/0    00:00:00 bash
      9 pts/0    00:00:00 ps
```

  
# Namesapce:
  * limit what process can see
  * done via syscalls
    * Unix Timesharing System
    * Process IDs
    * Mounts
    * Network
    * User IDs
    * InterProcess Comms
  * restricts the view of the process about the system
  * [[main.go]]
```
  23210 pts/2    S<+    0:00      |   \_ sudo go run main.go run /bin/bash
  23212 pts/3    S<s    0:00      |       \_ sudo go run main.go run /bin/bash
  23213 pts/3    S<l    0:00      |           \_ go run main.go run /bin/bash
  23249 pts/3    S<l    0:00      |               \_ /root/.cache/go-build/33/3346aa5ca765f878de5eef42d7
  23255 pts/3    S<l    0:00      |                   \_ /proc/self/exe child /bin/bash
  23261 pts/3    S<     0:00      |                       \_ /bin/bash
  23472 pts/3    R<+    0:00      |                           \_ ps fax
```


* V1 : UTS only
```
Parent
    |
    +--> child (UTS namespace)
            |
            +--> /bin/bash
no PID namespace
```
---

* https://www.youtube.com/watch?v=sK5i-N34im8


---
# CLI:
* tif run     <image>  <cmd>       # docker-like: run arbitrary container
* tif model   <name>   [flags]     # llm-like: pull/load a gguf, run llama.cpp inside a sandbox
* tif pull    <image|model>        # fetches either a rootfs OR a model, based on ref format
* tif ps
* tif stop    <id>
* tif logs    <id>
* tif inspect <id>
* tif stats   <id>                 # live general profiler
* tif infer-stats <id>             # live ProfInfer-style profiler, only valid for model workloads

# .TiF file
* general : [[egC.tif.txt]]
* llm : [[egllm.tif.txt]] 
 



---
[[linux internal]] [[linux]] [[system programming]] [[process and resource isolation]] [[contaner]] [[kernal talks]]

# what can i actaully control in resource allocation and what am i contolling ? and How do we measure ? :
```
  Application
      ▲
  Runtime (TiF)
      ▲
  Linux Kernel
      ▲
  Hardware
```
## what we can control ?
* what i can see we can divide this into 2 parts one process control and other is hardware
1. Process control:
  1. PID Namespace (CLONE_NEWPID) :
      * which processes can this process see
      * so what happens in container is that we can create a new PID space inside the contaner , isolatde from the linux gloabl processes   
      * ``` 
        Host Namespace

        PID 1     systemd
        PID 510   chrome
        PID 900   TiF Runtime
           │
           ▼
        ──────────────────────────
        New PID Namespace
    
        PID 1     bash
        PID 2     sleep
        PID 3     python
        PID 4     nginx```
      *  host system can see the process inside the namesapce but the process in nameaspce cannot see the outside ones so one process can have multiple pids
      * pid 1: init process 
      * **Kernal interface :** CLONE_NEWPID
  2. UTS Namesapce (CLONE_NEWUTS) :
      * UTS : unix time sharing 
        * terrible name i know but this helps us control the hostname and domainname 
      * **Kernal interface :** CLONE_NEWUTS
  3. Mount Namespace (CLONE_NEWNS) :
      * what filesystem does this process see?
      * without this everyprocess use the same mount table 
      * this enable us to have an isolated mount table such that chages in it deosnot affect the host system
        * A mount namespace does NOT give you an isolated filesystem. It gives you an isolated mount table.
        * *Mount Table:* The Linux mount table records currently active filesystems and their mount points, allowing the kernel to route file access to the correct storage device.  
          * it is primarily maintained in memory by the kernel and exposed via /proc/mounts, which provides the authoritative list of active mounts. 
      * without mount namesape linux will duplicate the mount table from host system
      * **leak:** here we have a concept called mount propagation ; by default mount is shared ,that can coust the change inside the container to affect the host anf this is mount propagation leak.
        * propagation types:
          * shared : everyone has every mount
          * private : no propagation
          * slave : host change appears inside but conntaner changes doesnot
          * unbindable : cannot be bind mounted else where
        *  syscall.MS_PRIVATE|syscall.MS_REC 
          * MS_REC : apply recursively
          * MS_PRIVATE : keep private
      * mount namespace isolates the map. chroot()/pivot_root() changes what the map points to. Together they create the filesystem view that a container sees.   
      * **Kernal interface :** CLONE_NEWNS
  4. IPC Namespace (CLONE_NEWIPC) :
      * IPC : Inter Process Communication
      * enable data sharing at very low latency
      * every linux process has its own memeory so linux provides a way for processes to communicate between them
      * ther are 3 kinds of IPC:
        * shared memeory : suppose 2 process want to access same data so 2 create 2 copics this becomes expensice with large data so what shaoed ipc enables us to do is that it allocated the meory in one place and both the processes can use that
        ```
        +----------------------+
        | Shared Memory        |
        | counter = 42         |
        +----------------------+
            ▲        ▲
            │        │
          Process A   Process B
        ```
          * this one i will use inthe llama.cpp contnaer to attact ProfInfer profiler 
        * Senaphores : solution of race condition
        * message queue : instead of sharing memery process can send message in between
      * every ipc process gets an id, this namespace approch enabel process isolation  
      * **Kernal Object :** struct ipc_namespace
      * **Kernal interface :** CLONE_NEWIPC / clone()
  5. User Namespace (CLONE_NEWUSER) :
      * *WHO AM I?*
      * this is not new user it isolated the process in *"who are you"*
      * gicing real root to container is dangerous , so create a namespace where UID 0 inside the namespace maps to some non-root UID on the host.
      * linux privilages are based on uid and guid and Root can :
        * mount filesystems
        * create other namespaces
        * change network settings
        * read protected files
        * load kernel modules
        * kill basically anything
      * user namesapce is an mapping table , uid and gid are used to see the real acces by the kernal
      * inside a new namespace the process has root like access this means it can :
        * mount certain filesystems
        * create child namespaces
        * set hostname in its own UTS namespace
        * use capabilities inside the namespace
        * run container setup steps without host root
      * this is enables us to have rootless container
      * here root in this sandboxed universe, not root over the whole machine
      * 
      * **Kernal Object :** struct user_namespace  
      * **Kernal Interface :** CLONE_NEWUSER 
  6. Network Namespace (CLONE_NEWNET)
      * "What network stack do I see?"
      * Application->Socket Layer->TCP->IP->Routing->ARP->Device Driver->NIC
      *  Normally every process belongs to the host's network namespace, so they share the same networking stack
        * docker ther are 6  kinds of networking 
        * Bridge
        * host ---------------------------|
        * oberlay                         |
        * macvian                         |
        * IPvlan                          |
        * none----------------------------|--> we implement these 2
      * almost all process share: 
        * interfaces
        * IP addresses
        * routing table
        * firewall
        * ARP cache
        * listening ports 
      *  The kernel creates a new networking context (struct net), isolating networking resources from the host., this enable our process to have its own:
        * Network Interfaces
        * IP Addresses
        * Routing Table
        * ARP Cache
        * Neighbor Cache
        * Firewall Rules
        * iptables
        * nftables
        * Socket Tables
        * TCP State
        * UDP State
        * Port Numbers
        * Network Devices
        * /proc/net
      * initaily the namesapce only containe *loopback(lo, no path out)* because linux cannto assune whay iterface or ip or subnet or bridge we need;
      * **how do we connet to internet ?** *veth (virtual ethernet)* 
        ```veth0 <=========> veth1```
      * why bridge ? : get all container on one cale of ethernet
      * the namesapce enable contnaer to have their iwn routing table(iproute), NAT(MASQUERADE)
      * *loaclhost :* both host and conatiner have differnt loopback 
      * since the namesapce provide use with our own socket table we have access all ports without caring ehat are used by the host machine 
      * **Kernel object :** struct net
      * **Kernal Interface :** CLONE_NEWNET
  7. Root Filesystem (chroot / pivot_root)
      * "What is /?"
      * *filesystem :* 
      * **Kernel object :**
      * **Kernal Interface :**
  8. Mounts (mount())inter
      * **Kernel object :**
      * **Kernal Interface :**
  9. Environment (execve())
      * **Kernel object :**
      * **Kernal Interface :**
  10. Working Directory (chdir()) 
      * **Kernel object :**
      * **Kernal Interface :**
  11. cgroup_namespace
  12. time_namespace

| **S.No.**  | **Feature** | **Linux Interface** | **Purpose** |
|---|---|---|---|
|  | | | |
| 1 | PID namespace | `clone(CLONE_NEWPID)` | Isolate process IDs |
| 2 | UTS namespace | `clone(CLONE_NEWUTS)` | Separate hostname/domain name |
| 3 | Mount namespace | `clone(CLONE_NEWNS)` | Independent mount table |
| 4 | IPC namespace | `clone(CLONE_NEWIPC)` | Separate SysV IPC and POSIX message queues |
| 5 | User namespace | `clone(CLONE_NEWUSER)` | UID/GID remapping |
| 6 | Network namespace | `clone(CLONE_NEWNET)` | Separate network stack |
| 7 | Root filesystem | `chroot()` / `pivot_root()` | Change process root directory |
| 8 | Mount operations | `mount()` / `umount2()` | Mount `/proc`, bind mounts, tmpfs, etc. |
| 9 | Environment | `execve()` | Environment variables (`envp`) |
| 10 | Working directory | `chdir()` | Initial current directory |

2. Rsource control :
  1.
