package config

type UTSNamespace struct {
	Enable     bool   `yaml:"Enable"`
	Hostname   string `yaml:"HostName"`
	Domainname string `yaml:"DomainName"`
}
