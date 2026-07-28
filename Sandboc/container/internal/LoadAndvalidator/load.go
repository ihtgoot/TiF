package LandV

import (
	"fmt"
	"log"
	"os"

	"github.com/ihtgoot/TiF/Sandboc/container/internal/config"
	"go.yaml.in/yaml/v3"
)

func Load_Config() {
	// Read the file
	data, err := os.ReadFile("./Tif.yaml")
	if err != nil {
		log.Fatalf("Error reading file: %v", err)
	} else {
		fmt.Println(data)
	}

	// Define config struct
	var cfg config.Container

	// 3. Unmarshal YAML into struct
	err = yaml.Unmarshal(data, &cfg)
	if err != nil {
		log.Fatalf("Error parsing YAML: %v", err)
	}

	fmt.Printf("Parsed Config: %+v\n", cfg)
}
