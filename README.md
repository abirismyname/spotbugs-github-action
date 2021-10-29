# SpotBugs GitHub Action

Run [SpotBugs](https://spotbugs.readthedocs.io/en/latest/) as a Github action.

```yaml
name: SpotBugs

on: [push, pull_request]

jobs:
  spotbugs-analyze:
    name: Analyze
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Run SpotBugs
        uses: spotbugs/spotbugs-github-action@v1
        with:
          arguments: '-sarif'
          target: './HelloWorld.jar'
          output: 'results.sarif'
          spotbugs-version: 'latest'

      - name: Upload analysis results to GitHub Security tab
        uses: github/codeql-action/upload-sarif@v1
        with:
          sarif_file: ${{github.workspace}}/results.sarif
```
