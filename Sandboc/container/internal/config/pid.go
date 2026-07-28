package config

type PIDMode int

const (
	PrivatePid PIDMode = iota
	HostPid
)

type PIDNamespace struct {
	Enable    bool    `yaml:"Enable"`
	Mode      PIDMode `yaml:"Mode"`
	MountProc bool    `yaml:"MoutProc"`
}
