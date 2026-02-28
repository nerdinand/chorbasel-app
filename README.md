# ChorBasel-App

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
* tailwindcss: CSS framework.
* pundit: For authorization of all the features through user roles.

### Development

We aim to have a reasonable test coverage using these kinds of specs:

* features: high-level tests that simulate user interaction and test what the user can see
* models: low-level unit tests of individual methods in model classes
* helpers: same for helper methods
* mailers: same for mailers
* controllers: test individual controller actions

Run the specs with:
```
bundle exec rspec
```

### Deployment

TODO: Write about how to deploy this thing (kamal, S3).

### Scripts

TODO: Describe face script, import script.
