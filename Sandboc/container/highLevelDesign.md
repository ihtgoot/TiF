```                            TiF Platform
================================================================================

                                 Client
                                   │
                     CLI / gRPC / REST / Dashboard
                                   │
                                   ▼
                          API / Admission Layer
                                   │
                     Validate YAML + Authenticate
                                   │
                                   ▼
                            Scheduler / Queue
                         (Ring Buffer + Workers)
                                   │
                    Create Execution Request
                                   │
        ┌──────────────────────────┴──────────────────────────┐
        │                                                     │
        ▼                                                     ▼
 Runtime Controller                                   Metadata Service
 (Orchestrator)                                       (SQLite)
        │                                                     │
        │ create execution record                             │
        │                                                     │
        ▼                                                     │
 ┌────────────────────────────────────────────────────────────┘
 │
 ▼
 Container Runtime
 ├── Namespace Manager
 ├── Mount Manager
 ├── User Namespace
 ├── PID Namespace
 ├── Network Namespace
 ├── IPC Namespace
 ├── Time Namespace
 ├── Cgroup Manager
 ├── RootFS Manager
 └── Process Launcher
            │
            │ exec()
            ▼
      Container Process
            │
            │
            ├──────────────┐
            │              │
            ▼              ▼
    Resource Manager    Profiler Manager
            │              │
            │              │
            ▼              ▼
 Linux Controls      Telemetry Collection
            │              │
            │              │
            ▼              ▼
       cgroups            perf
       affinity           eBPF
      scheduler           VTune
            |           ProfInfer
            |             procfs
            │              │
            └──────┬───────┘
                   ▼
            Metrics Collector
                   │
                   ▼
              SQLite Database
                   │
        Execution Finished Event
                   │
                   ▼
         Python Analysis Service
         ├── Pandas
         ├── Plotly
         ├── Jinja2
         ├── Statistics
         └── PDF Generator
                   │
                   ▼
              PDF Report
```
