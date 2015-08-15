RoR Timetracking Application for Small Companies
===

[![Build Status](https://travis-ci.org/mbrugger/timetracking.svg)](https://travis-ci.org/mbrugger/timetracking)
[![Code Climate](https://codeclimate.com/github/mbrugger/timetracking/badges/gpa.svg)](https://codeclimate.com/github/mbrugger/timetracking)
[![Test Coverage](https://codeclimate.com/github/mbrugger/timetracking/badges/coverage.svg)](https://codeclimate.com/github/mbrugger/timetracking/coverage)

A lot of work still needs to be done but the current version of the application already serves its purpose for me and my 14 colleagues.
I created a list of issues I hopefully will be able to resolve soon.

Demo System
---
A demo installation is available at [Heroku](https://intense-reef-9620.herokuapp.com/)

- User: admin@example.com
- Password: admin1234

The system is available for testing and will be cleared frequently

Features
---
- Easy to install ruby on rails application
- Comfortable tracking of working hours for employees
- Integrated leave days/holidays management
- Create reports on a monthly basis
- Automatic reminders for missing/incomplete time entries
- Complies with Austrian legal requirements (still working on this one)
- Usable on mobile browsers thanks to [bootstrap](http://getbootstrap.com)
- REST API to develop your own mobile tracking application (already in work by one of my colleagues)

Installation instructions
---
Requirements:
- Mysql or Postgres
- Ruby 2.x

###Environment Configuration:

All necessary configuration can be done through environment variables so you can easily deploy the application to heroku without any code changes necessary

#####Mail settings(environments/production.yml):

    export SMTP_SERVER="smtp.example.com"
    export SMTP_PORT="465"
    export SMTP_DOMAIN="example.com"
    export SMTP_USER_NAME="myuser@example.com"
    export SMTP_PASSWORD="topsecretpassword"
    export SMTP_AUTHENTICATION="login"
    export SMTP_SSL="true"
    export MAIL_FROM="noreply@example.com"
    export MAIL_HOSTNAME="timetracking.example.com"

#####Security settings(secrets.yml):
    export SECRET_KEY_BASE="TOPSECRETTOPSECRETTOPSECRETTOPSECRETTOPSECRETTOPSECRET"
    export DEVISE_SECRET_KEY="TOPSECRETTOPSECRETTOPSECRETTOPSECRETTOPSECRETTOPSECRETTOPSECRET"

#####Database settings (database.yml):
See database.yml on how exactly the configuration values are used.
Run bundle install to install without the heroku (e.g. postgres) or mysql dependencies:

    bundle install --without heroku


######Mysql:
    export DATABASE_TYPE="mysql"
    export DATABASE_NAME="timetracking"
    export DATABASE_USERNAME="timetracking"
    export DATABASE_PASSWORD="timetracking"
    export DATABASE_HOST="localhost"
    export DATABASE_PORT="3306"
######Postgres:
    export DATABASE_TYPE="pg"
    export DATABASE_URL="postgres://user:pass@host:5432/database"

#####Used as company name on reports:
    export COMPANY_NAME="TT Ltd"
