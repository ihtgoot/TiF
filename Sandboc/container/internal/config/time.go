package config

type TimeNamespace struct {
	Enable          bool     `yaml:"Enable"`
	MonotonicOffset Duration `yaml:"MonotonicOffset"`
	BootOffset      Duration `yaml:"BootOffset"`
}

type Duration struct {
	Hour   int `yaml:"Hour"`
	Minute int `yaml:"Minute"`
	Second int `yaml:"Second"`
}
