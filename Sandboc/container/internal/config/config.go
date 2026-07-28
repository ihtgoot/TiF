package config

type Profile int

const (
	General Profile = iota
	Reserch
)

type Container struct {
	Name           string    `yaml:"Name"`
	Mode           Profile   `yaml:"Mode"` // 0=general|1=reserch (vtune is in general and other option is vtune+profinfer in reserch)
	Isolation      Isolation `yaml:"Isolation"`
	Control_vector [8]bool   `yaml:"Control_vector"`
}

type Isolation struct {
	PID     PIDNamespace     `yaml:"PID"`
	Runtime Runtime          `yaml:"Runtime"`
	UTS     UTSNamespace     `yaml:"UTS"`
	Mount   MountNamespace   `yaml:"Mount"`
	IPC     IPCNamespace     `yaml:"IPC"`
	User    UserNamespace    `yaml:"User"`
	Network NetworkNamespace `yaml:"Network"`
	Time    TimeNamespace    `yaml:"Time"`
	Cgroup  CgroupNamespace  `yaml:"Cgroup"`
}
