# Script: devops-tasks.sh

A tool to query a Azure Devops / VSTS / TFS API for task details. It generates a count and a html table with active tasks.

![polybar](screenshots/polybar.png)

![zenity](screenshots/zenity.png)

# Dependencies

* vsts-cli: https://docs.microsoft.com/en-us/cli/vsts/overview?view=vsts-cli-latest

* zenity: https://help.gnome.org/users/zenity/

* jq: https://stedolan.github.io/jq/

# Getting started

# TODO

- add basic style / css
- error handling
- check dependencies

# Define fields in table

1. run custom query and check output for useful fields / information
2. change query

# Links

I used this script as a starting point: https://github.com/polybar/polybar-scripts/tree/master/polybar-scripts/popup-calendar. If you want to learn more about custom devops queries and other CLI options just go to https://docs.microsoft.com/en-us/cli/vsts/overview?view=vsts-cli-latest.
