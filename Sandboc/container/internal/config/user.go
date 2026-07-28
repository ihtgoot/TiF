package config

type IDmap struct {
	ConatainerID int `yaml:"ConatainerID"`
	HostID       int `yaml:"HostID"`
	Size         int `yaml:"Size"`
}

type UserNamespace struct {
	Enable bool  `yaml:"Enable"`
	UidMap IDmap `yaml:"UidMap"`
	GidMap IDmap `yaml:"GidMap"`
}
