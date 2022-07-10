package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"regexp"

	"go.bug.st/serial"
	"go.bug.st/serial/enumerator"
)

func main() {
	fmt.Println("Uploading fpga binary stream...")

	portDetails, err := enumerator.GetDetailedPortsList()
	if err != nil {
		log.Fatal(err)
	}
	if len(portDetails) == 0 {
		fmt.Println("No serial ports found!")
		return
	}

	rxpr, _ := regexp.Compile(`/dev/tty([A-Z]+)([0-9]+)`)

	var port *enumerator.PortDetails

	for _, aport := range portDetails {
		fields := rxpr.FindStringSubmatch(aport.Name)
		device := fields[1]
		if device == "ACM" {
			fmt.Printf("Found port: %s\n", aport.Name)
			if aport.IsUSB {
				fmt.Printf("   USB ID     %s:%s\n", aport.VID, aport.PID)
				fmt.Printf("   USB serial %s\n", aport.SerialNumber)
			}
			port = aport
			break
		}
	}

	if port == nil {
		log.Fatalln("No ACM port found")
	}

	portACM, err := serial.Open(port.Name, &serial.Mode{})
	if err != nil {
		log.Fatal(err)
	}

	// This Mode is ignored for ACM devices, so I create a blank one.
	mode := &serial.Mode{}

	if err := portACM.SetMode(mode); err != nil {
		log.Fatal(err)
	}

	bits, err := retrieveBinArry("hardware.bin")
	if err != nil {
		log.Fatal(err)
	}

	portACM.Write(bits)

	err = portACM.Close()
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("binary fpga stream uploaded...")
}

func retrieveBinArry(filename string) ([]byte, error) {
	file, err := os.Open(filename)

	if err != nil {
		return nil, err
	}
	defer file.Close()

	stats, statsErr := file.Stat()
	if statsErr != nil {
		return nil, statsErr
	}

	var size int64 = stats.Size()
	bytes := make([]byte, size)

	bufr := bufio.NewReader(file)
	_, err = bufr.Read(bytes)

	return bytes, err
}
