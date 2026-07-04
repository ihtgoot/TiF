package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"slices"
	"strings"
	"sync"
)

var cpusA int = runtime.NumCPU() * 4 / 5

type Result struct {
	SourceDir string
	ExitCode  int
	Log       string
	Muation   bool
}

func countTC(path string) (int, []string) {
	tc, err := os.ReadDir(path)
	if err != nil {
		log.Fatal(err)
	}
	theTC := make([]string, 0, len(tc))
	for _, i := range tc {
		theTC = append(theTC, path+"/"+i.Name())
	}
	slices.Sort(theTC)
	return len(tc), theTC
}

func runVerilator(path string) ([]byte, error) {
	fmt.Println("test running : ", path)
	_, err := os.Stat(path)
	if err != nil {
		return nil, err
	}
	cmd := exec.Command(
		"verilator",
		"--lint-only",
		"-Wall",
		"--timing",
		"--assert",
		"--error-limit", "0",
		path,
	)

	return cmd.CombinedOutput()
}

func job(path string, id int) {
	Log, err := runVerilator(path)
	exitCode := 0
	if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			exitCode = exitErr.ExitCode()
			fmt.Printf("[Worker %d] exited with code %d\n", id, exitCode)
		} else {
			fmt.Printf("[Worker %d] failed to start verlator : %v\n", id, err)
			return
		}
	}
	dir := filepath.Dir(path)
	output := Result{
		SourceDir: dir,
		ExitCode:  exitCode,
		Log:       string(Log),
		Muation:   false,
	}
	base := strings.TrimSuffix(filepath.Base(path), filepath.Ext(path))
	jsonPath := filepath.Join(dir, base+".json")
	data, err := json.MarshalIndent(output, "", "  ")
	if err := os.WriteFile(jsonPath, data, 0644); err != nil {
		fmt.Println("error saving log")
		return
	}
	_, err = os.Stat(jsonPath)
	if err != nil {
		fmt.Println("error writing to file")
		return
	}
	fmt.Printf("file saved %s \n", jsonPath)
}

func worker(id int, jobs <-chan string, wg *sync.WaitGroup) {
	defer wg.Done()
	for path := range jobs {
		fmt.Printf("[Worker %d] stated for tc %s\n", id, path)
		job(path, id)
		fmt.Printf("[Worker %d] finished job %s\n", id, path)
	}
	fmt.Printf("[Worker %d] exiting\n", id)
}

func Runner(TC []string) {
	numJobs := len(TC)
	numWorker := min(numJobs, cpusA)
	runtime.GOMAXPROCS(numWorker)
	jobs := make(chan string, numWorker)

	var wg sync.WaitGroup

	// start workers
	fmt.Printf("spawnned %d [Workers] for %d [Jobs]", numWorker, numJobs)
	for i := 1; i <= numWorker; i++ {
		wg.Add(1)
		go worker(i, jobs, &wg)
	}
	//send jobs
	for j := 0; j < numJobs; j++ {
		fmt.Printf("[Runner] sending Job %d for %s \n", j, TC[j])
		jobs <- TC[j]
	}
	close(jobs)
	wg.Wait()
	fmt.Println("all done.")
}

func main() {

	if len(os.Args) != 2 {
		fmt.Println("no more than 1 dir at a time")
		return
	}

	datasetPath := os.Args[1]
	numTC, TC := countTC(datasetPath)
	fmt.Println("this is the dir: ", datasetPath)

	if numTC != 0 {
		fmt.Println("no. of testcases : ", numTC)
		fmt.Println("below are the test cases: \n", TC)
		Runner(TC)
	} else {
		fmt.Println("no test case to run buddy")
	}
}
