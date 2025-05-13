feat: add debug levels and help option to run script

- Add --debug=LEVEL option to control log verbosity
- Add --help option to display usage information
- Change default behavior to show no logs (level 0)
- Implement 4 debug levels:
  * Level 0: No logs (default)
  * Level 1: Application logs only
  * Level 2: Application logs + limited Qt logs
  * Level 3: All logs (application + full Qt logs)