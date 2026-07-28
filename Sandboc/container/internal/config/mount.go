package config

type MountPropagation int

const (
	PrivateMount MountPropagation = iota
	SharedMount
	SlaveMount
	UnbindableMount
)

type MountNamespace struct {
	Enable      bool             `yaml:"Enable"`
	Propagation MountPropagation `yaml:"Propagation"`
	Mounts      []Mount          `yaml:"Mount_vector"`
	/*  mounts:
	    - type: proc
	      target: /proc
	    - type: sysfs
	      target: /sys
	    - type: tmpfs
	      target: /tmp
	      size: 128M
	    - type: bind
	      source: ./data
	      target: /data
	      readonly: true
	    - type: bind
	      source: /dev/null
	      target: /dev/null
	*/
}
type MountType int

const (
	Proc MountType = iota
	Sysfs
	Tmpfs
	Bind
)

type Mount struct {
	Type     MountType `yaml:"Kind"`
	Target   string    `yaml:"Target"`
	Size     int       `yaml:"Size"` // size in MB
	Readonly bool      `yaml:"Readonly"`
}
