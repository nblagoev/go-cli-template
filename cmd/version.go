package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

var (
	version       string
	revision      string
	buildDate     string
	flagBuildInfo bool
)

func init() {
	versionCmd.Flags().BoolVarP(&flagBuildInfo, "build-info", "b", false, "Show additional version information")
	rootCmd.AddCommand(versionCmd)
}

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Print the version number",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("gotmpl %s\n", version)

		if flagBuildInfo {
			fmt.Printf("build date:\t%s\n", buildDate)
			fmt.Printf("git revision:\t%s\n", revision)
		}
	},
}
