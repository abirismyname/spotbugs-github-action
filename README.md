# SpotBugs GitHub Action

Run [SpotBugs](https://spotbugs.readthedocs.io/en/latest/) as a Github action.

## Inputs

### outputType

Output type for the report. It can be 'xml', 'html', 'sarif', 'emacs'
or 'xdocs'. Default value is 'sarif' as it is the used by GitHub Advanced
Security.

> default: 'sarif' <br/>
> required: true

### packages

Comma separated list of packages to scan. It will fill the 
-onlyAnalyze parameter in spotbugs. It can contain the wildcards '\*' and
'-': com.example.\* for single package or com.example.- for all
subpackages.

> If not specified, it will scan all packages.

See more at https://spotbugs.readthedocs.io/en/stable/running.html#text-ui-options

### arguments

A string with any additional command arguments to be sent to [spotbugs](https://spotbugs.readthedocs.io/en/stable/running.html#text-ui-options)

### output

The output filename. If not specified, it will use the default name 'results.[EXTENSION]'

### target

It can be a file or a directory, it is usually the ./target folder where you compiled your project.      

### dependenciesPath

Path to the dependencies folder. For example, for Maven it is usually stored
in the `~/.m2`  folder.

### basePath

The basePath is used as a prefix in the sarif file to help GitHub find the
right file of the issue. It is tipically something like 'src/main/java'.

## Example usage

This workflow would analyze a Java application that builds a set of
packages under the com.example package name and outputs the results in
sarif format to upload it to the GitHub Security tab:

```yaml
name: SpotBugs

on: [push, pull_request]

jobs:
  spotbugs-analyze:   
    name: Analyze
    runs-on: ubuntu-latest
    steps:      

      # checkout and build the project
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up JDK 11
        uses: actions/setup-java@v3
        with:
          java-version: '11'
          distribution: 'temurin'
          cache: maven
      - name: Build with Maven
        run: mvn clean package -B -Dmaven.test.skip 

      # Run SpotBugs and upload the SARIF file
      - name: Run SpotBugs action
        if: always()
        uses: abirismyname/spotbugs-github-action@v2
        with:
          packages: com.example.-
          target: ./target
          dependenciesPath: ~/.m2
          basePath: src/main/java         

      - name: Upload analysis results to GitHub Security tab
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: ${{github.workspace}}/results.sarif
```
