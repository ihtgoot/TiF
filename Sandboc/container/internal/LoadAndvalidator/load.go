package LandV

import (
	"fmt"
	"log"
	"os"
	"os/exec"

	"github.com/ihtgoot/TiF/Sandboc/container/internal/config"
	"go.yaml.in/yaml/v3"
)

func Load_Config(address os.FileInfo) (config.Container, error) {
	// Define config struct
	var cfg config.Container
	addr := address.Name()
	data, err := os.ReadFile(addr)
	// Read the file
	// Define config struct
	if err != nil {
		log.Fatalf("Error reading file: %v", err)
		return cfg, err
	}
	// else {
	// 	//fmt.Println(data)
	// }

	// 3. Unmarshal YAML into struct
	err = yaml.Unmarshal(data, &cfg)
	if err != nil {
		log.Fatalf("Error parsing YAML: %v", err)
		return cfg, err
	}

	return cfg, nil
}

func ExtractImage(image string) error {
	cmd := exec.Command("bash", "dockerFS.sh", image)

	output, err := cmd.CombinedOutput()
	if err != nil {
		log.Fatal("script didn not run:", string(output))
	}
	log.Printf("script output:\n%s", output)
	_, err = os.Stat("rootfs")

	return err
}

func CleanUP() {
	if rmErr := os.RemoveAll("rootfs"); rmErr != nil {
		fmt.Println("warnings: temp fs not deleted :\n", rmErr)
	}
	if rmErr := os.Remove("/sys/fs/cgroup/Sboc"); rmErr != nil {
		fmt.Println("warning: cgroup cleanup failed:", rmErr)
	}
}
