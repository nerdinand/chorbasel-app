# Chorbasel-App

Deployed at [app.chorbasel.ch](https://app.chorbasel.ch/). 

## Features

* Passwordless login
* Benutzerverwaltung
  * Stammdatenverwaltung
  * Berechtigungssystem
* Absenzenmanagement
* Liederverwaltung (inkl. Medien)
* Namen-Ratespiel

### Geplante Features

* Lookbook?
* Lieder anstimmen (evtl. sogar offline verfügbar?)
* Liederliste für Konzerte (Download aller relevanten Medien für ein Konzert für eine:n Benutzer:in)

## Technical stuff

This is a standard Rails 8 app. We're using all the current best practices (maybe apart from RSpec instead of Minitest).

### Dependencies

These are the most important non-standard dependencies of the app:

* passwordless: For passwordless user login.
* arask: For running tasks regularly (updating calendar_events daily from the master Google calendar).
* tailwindcss: CSS framework.
* pundit: For authorization of all the features through user roles.

### Deployment

TODO: Write about how to deploy this thing (kamal, S3).

### Scripts

TODO: Describe face script, import script.
