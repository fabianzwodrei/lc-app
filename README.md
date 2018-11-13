# Law Clinic App

[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0/)
[![Build Status](https://travis-ci.org/fabianzwodrei/lc-app.svg?branch=master)](https://travis-ci.org/fabianzwodrei/lc-app)

### Setup
 * Install Imagemagick
 * Install Redis: `brew install redis` (on mac os x)
 * Run `bundle install`
 * Run `rails db:drop db:setup` 
 * Copy `config/app_environment_variables_example.rb` to `config/app_environment_variables.rb` and replace placeholders with your (mail-)configuration

### Running in local Dev
 * Start Redis: `redis-server`
 * Start Sidekiq for Emails and ActionCable-Broadcasting: `bundle exec sidekiq`
 * Start Server `rails server`


### Test-Users by Seeding (seeds.rb)

the password for all members is `password1`
  
* tina@interneorga.com - member of `Interne Organisation` 
* sabine@mandatsverwaltung.com - member of `Mandatsverwaltung` 
* hans@mandatsverwaltung.com - member of `Mandatsverwaltung` in the role of `Sachstandsanfragenbeauftrager`
* leif@finanzen.com - member of `Finanzen`
* sonja@schulungen.com - member of `Schulungen`
* leonie@netzwerk.com - member of `Netzwerk`
* tim@mitglieder.com - represents members not associated to specific departments. Tim has all necessary (full) qualifications to apply for mandates
* svenja@mitglieder.com - represents members not associated to specific departments
* martha@sprechstunde.com - member of `Sprechstunde`
* fatima@rechteverwaltung.com - member of `Rechteverwaltung`
* olga@vorstand.com - member of `Vorstand`