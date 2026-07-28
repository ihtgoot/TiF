package config

type RuntimeInit int

const (
	InternalRuntime RuntimeInit = iota
	TiniRuntime
)

type Runtime struct {
	Init   RuntimeInit `yaml:"Init"`
	Tty    bool        `yaml:"Tty"`
	Detach bool        `yaml:"Detach"`
}
