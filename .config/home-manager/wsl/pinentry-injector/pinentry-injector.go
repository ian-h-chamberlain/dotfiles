// A simple app to wrap `pinentry`, intercepting the description while looking
// for an email address; if found it will be injected into the real pinentry's
// title.
//
// This is probably insecure for some reason or other so use with care.

package main

import (
	"bufio"
	"errors"
	"fmt"
	"io"
	"os"
	"os/exec"
	"regexp"
)

func main() {
	err := run(os.Args[1], os.Args[1:]...)

	if err != nil {
		var exitErr *exec.ExitError
		if errors.As(err, &exitErr) {
			os.Exit(exitErr.ExitCode())
		} else {
			os.Exit(1)
		}
	}
}

var emailRegex = regexp.MustCompile(`(?:%22|")(?P<name>.+?) <(?P<email>.+?)>(?:%22|")`)

const emailAddressIndex = 2

func run(realPinentry string, pinentryArgs ...string) (err error) {
	pinentry := exec.Command(realPinentry, pinentryArgs...)

	pinentryStdin, err := pinentry.StdinPipe()
	if err != nil {
		return err
	}
	defer pinentryStdin.Close()

	pinentryStdout, err := pinentry.StdoutPipe()
	if err != nil {
		return err
	}
	defer pinentryStdout.Close()

	if err = pinentry.Start(); err != nil {
		return err
	}
	defer func() {
		err = errors.Join(err, pinentry.Wait())
	}()

	stdinScanner := bufio.NewScanner(os.Stdin)
	myStdin := make(chan string)
	go func() {
		for stdinScanner.Scan() {
			myStdin <- stdinScanner.Text()
		}
		close(myStdin)
	}()

	stdoutScanner := bufio.NewScanner(pinentryStdout)
	pinentryOut := make(chan string)
	go func() {
		for stdoutScanner.Scan() {
			pinentryOut <- stdoutScanner.Text()
		}
		close(pinentryOut)
	}()

loop:
	for {
		fmt.Fprintln(os.Stderr, "waiting for input...")
		select {
		case inLine, ok := <-myStdin:
			if !ok {
				// EOF from client, pass it along by closing the pipe
				_ = pinentryStdin.Close()
				break loop
			}

			fmt.Fprintf(os.Stderr, "Got input line: %q\n", inLine)
			if email := emailRegex.FindStringSubmatch(inLine); email != nil {
				fmt.Fprintln(os.Stderr, "matched mail regex")
				io.WriteString(pinentryStdin, fmt.Sprintf("SETTITLE pinentry: <%s>\n", email[emailAddressIndex]))
				response := <-pinentryOut
				if response != "OK" {
					os.Stderr.WriteString("failed to settitle")
					break
				}
			}
			io.WriteString(pinentryStdin, inLine+"\n")

		case outLine, ok := <-pinentryOut:
			if !ok {
				break loop
			}
			fmt.Fprintf(os.Stderr, "Got output line: %q\n", outLine)
			fmt.Println(outLine)
		}

	}
	err = errors.Join(stdinScanner.Err(), stdoutScanner.Err())
	if err != nil {
		fmt.Fprintf(os.Stderr, "Done: %s\n", err)
	}

	return err
}
