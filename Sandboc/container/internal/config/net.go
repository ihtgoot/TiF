package config

type NetMode int

const (
	HostNetwork NetMode = iota
	NoneNetowork
)

type NetworkNamespace struct {
	Enable bool    `yaml:"Enable"`
	Mode   NetMode `yaml:"Mode"`
}
