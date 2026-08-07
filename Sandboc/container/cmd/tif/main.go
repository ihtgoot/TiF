package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"syscall"

	LandV "github.com/ihtgoot/TiF/Sandboc/container/internal/LoadAndvalidator"
	"github.com/ihtgoot/TiF/Sandboc/container/internal/config"
)

type InternalConfig struct {
	userConfig config.Container
}

func must(err error) {
	if err != nil {
		panic(err)
	}
}

func main() {
	fmt.Println("\nMAIN START")
	fmt.Printf("%#v\n", os.Args)
	/*
		 	os.Args
			0 tif
			1 run
			2 /bin/bash
	*/
	if len(os.Args) < 2 {
		fmt.Println("usage: tif run [args...]")
		os.Exit(1)
	}

	if os.Args[1] == "child" {
		fmt.Print("child inside main")
		var cfg InternalConfig

		addr, err := os.Stat("Tif.yaml")
		must(err)

		cfg.userConfig, err = LandV.Load_Config(addr)
		must(err)

		cfg.child()
		return
	}

	addr, err := os.Stat("Tif.yaml")
	must(err)
	var cfg InternalConfig
	cfg.userConfig, err = LandV.Load_Config(addr)
	if err != nil {
		fmt.Println("fucker you didnot left main and seraching everywhere")
	}
	must(err)

	fmt.Printf("parse config : %v\n", cfg)

	Image := cfg.userConfig.Rootfs.Name
	must(LandV.ExtractImage(Image))

	switch os.Args[1] {
	case "run":
		cfg.run()
	default:
		panic("bad command")
	}
}

// create namesapce
func (cfg *InternalConfig) run() {
	fmt.Println("\nRUN START")
	fmt.Printf("%#v\n", os.Args)

	fmt.Printf("Running %v as %d\n", os.Args[1:], os.Getpid())

	fmt.Println("program =", os.Args[1])
	fmt.Println("argv    =", os.Args[1:])

	cmd := exec.Command("/proc/self/exe", append([]string{"child"}, os.Args[1:]...)...)
	/*input*/ cmd.Stdin = os.Stdin
	/*output*/ cmd.Stdout = os.Stdout
	/*error*/ cmd.Stderr = os.Stderr
	/*namespace*/
	/*unix timae sharing ; lest us have out own host name*/
	hostUID := os.Getuid()

	absRootfs, _ := filepath.Abs("rootfs")
	cmd.Env = append(os.Environ(),
		fmt.Sprintf("TIF_HOST_UID=%d", hostUID),
		fmt.Sprintf("TIF_ROOTFS=%s", absRootfs),
	)

	cmd.SysProcAttr = &syscall.SysProcAttr{
		Cloneflags: syscall.CLONE_NEWUTS | syscall.CLONE_NEWPID |
			syscall.CLONE_NEWNS | syscall.CLONE_NEWUSER,
		UidMappings: []syscall.SysProcIDMap{
			{ContainerID: 0, HostID: os.Getuid(), Size: 1},
		},
		GidMappings: []syscall.SysProcIDMap{
			{ContainerID: 0, HostID: os.Getgid(), Size: 1},
		},
		GidMappingsEnableSetgroups: false,
	}

	err := cmd.Run()
	LandV.CleanUP()
	must(err)
}

func (cfg *InternalConfig) child() {
	fmt.Println("\nCihild START")
	fmt.Printf("%#v\n", os.Args)

	fmt.Println("program =", os.Args[3])
	fmt.Println("argv    =", os.Args[3:])

	fmt.Printf("Running %v as %d\n", os.Args[3:], os.Getpid())
	syscall.Sethostname([]byte("boc"))

	cg()

	must(syscall.Mount("", "/", "", syscall.MS_PRIVATE|syscall.MS_REC, ""))

	rootfs := os.Getenv("TIF_ROOTFS")
	if rootfs == "" {
		rootfs = cfg.userConfig.Rootfs.Address // fallback to config
	}

	must(syscall.Chroot(rootfs))
	must(syscall.Chdir("/"))

	must(os.MkdirAll("/proc", 0555))
	must(syscall.Mount(
		"proc",
		"/proc",
		"proc",
		0,
		"",
	))
	defer func() {
		if err := syscall.Unmount("/proc", syscall.MNT_DETACH); err != nil {
			fmt.Println("warning: unmount /proc failed:", err)
		}
	}()

	cmd := exec.Command(os.Args[3], os.Args[4:]...)
	/*input*/ cmd.Stdin = os.Stdin
	/*output*/ cmd.Stdout = os.Stdout
	/*error*/ cmd.Stderr = os.Stderr

	must(cmd.Run())

}

func cg() {
	uid := os.Getenv("TIF_HOST_UID")
	base := fmt.Sprintf("/sys/fs/cgroup/user.slice/user-%s.slice/user@%s.service", uid, uid)
	cg := filepath.Join(base, "Sboc")
	_ = os.Remove(cg)

	// Create a new child cgroup
	must(os.Mkdir(cg, 0755))
	// Limit the maximum number of processes
	must(os.WriteFile(
		filepath.Join(cg, "pids.max"),
		[]byte("100"),
		0644,
	))

	// Move the current process into this cgroup
	must(os.WriteFile(
		filepath.Join(cg, "cgroup.procs"),
		[]byte(strconv.Itoa(os.Getpid())),
		0644,
	))

}

/*
 127 = command not found
 126 = command found but cannot be executed
*/
