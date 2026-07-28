package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"syscall"

	LandV "github.com/ihtgoot/TiF/Sandboc/container/internal/LoadAndvalidator"
)

// docker run image <cmd> <params>
// TiF run 			<cmd> <params>

func must(err error) {
	if err != nil {
		panic(err)
	}
}

//	func main() {
//		if len(os.Args) < 2 {
//			fmt.Println("Usage: tif run <cmd> [args...]")
//			os.Exit(1)
//		}
//		switch os.Args[1] {
//		case "run":
//			run()
//		case "child":
//			child()
//		default:
//			panic("bad command")
//		}
//	}
func main() {
	LandV.Load_Config()
}

// create namesapce
func run() {

	fmt.Printf("Running %v as %d\n", os.Args[2:], os.Getpid())

	cmd := exec.Command("/proc/self/exe", append([]string{"child"}, os.Args[2:]...)...)
	/*input*/ cmd.Stdin = os.Stdin
	/*output*/ cmd.Stdout = os.Stdout
	/*error*/ cmd.Stderr = os.Stderr
	/*namespace*/
	/*unix timae sharing ; lest us have out own host name*/
	hostUID := os.Getuid()
	cmd.Env = append(os.Environ(), fmt.Sprintf("TIF_HOST_UID=%d", hostUID))

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

	if rmErr := os.Remove("/sys/fs/cgroup/Sboc"); rmErr != nil {
		fmt.Println("warning: cgroup cleanup failed:", rmErr)
	}

	must(err)
}

func child() {

	fmt.Printf("Running %v as %d\n", os.Args[2:], os.Getpid())
	syscall.Sethostname([]byte("boc"))

	cg()

	must(syscall.Mount("", "/", "", syscall.MS_PRIVATE|syscall.MS_REC, ""))

	must(syscall.Chroot("../../rootfs"))
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

	cmd := exec.Command(os.Args[2], os.Args[3:]...)
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
