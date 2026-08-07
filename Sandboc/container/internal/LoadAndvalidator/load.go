package LandV

import (
	"log"
	"os"

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
