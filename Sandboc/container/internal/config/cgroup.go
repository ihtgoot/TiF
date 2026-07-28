package config

type CgroupNamespace struct {
	Enable bool   `yaml:"Enable"`
	Name   string `yaml:"name"`
	Sddr   string `yaml:"Sddr"`
}
