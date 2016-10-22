# Cocodrilo

This is the base application used at [CROCODΞ](http://www.crocode.mobi/). It uses **Rails 5** to manage the backend.
The purpose of this project is to:

- Provide a minimal and well-configured application generator.
- Improve some Rails defaults.
- Enforce **code style guidelines**.
- Provide _basic_ **security**.

This template does **NOT** aim to:

- Encourage having too many dependencies. Dependencies are not cheap, and each
  bundled tool must have a _good_ reason to be included.
- Provide "pattern" gems (e.g. decorator). Patterns are usually
  project-specific and most of them can be achieved **without** any gems or
  libraries.
- Be a silver bullet. This is tailored for the majority of Rails applications
  you may want to build, but we know it won't work sometimes.

## Pre-requisites

- [Ruby](https://www.ruby-lang.org) >= 2.3.1
- [Bundler](http://bundler.io/)
- [rvm](https://github.com/rvm/rvm)
- [Git](https://git-scm.com/)
- [PostgreSQL](https://www.postgresql.org/)
- [Redis](http://redis.io/) - primarily for use with [Sidekiq](http://sidekiq.org/)

## Installation

Install the gem:

```sh
gem install cocodrilo
```

This will make the `cocodrilo` command accessible throughout your `PATH`.

## Configuring your environment

### PostgreSQL

**development** and **test** databases are automatically setup for you.
While running the generator it's assumed that:

- The PostgreSQL server is running.
- You have a PostgreSQL user named after your UNIX login.
- Your PostgreSQL user has a _blank_ password.

It's OK if your PG settings happen to be different from this; DB creation will
fail, but you can do it manually thereafter.

At a basic level, here's how to setup PostgreSQL on Linux:

```sh
# Creates a user
sudo -u postgres createuser -s my_user_name

# Runs psql
sudo -u postgres psql

# Change your use password within psql. Leave it blank.
[local] local@user=# \password my_user_name
```

## Generating your app

You can generate a new app with the following command:

```sh
cocodrilo myapp
```

## Starting up your app

```sh
$ cd my_app_folder
$ foreman start
```

This command runs Rails server and Sidekiq all at once.
Note that Your redis server has to be up and running because of Sidekiq. To
customize these processes you can edit `Procfile`.

Now you can work as you'd usually work in any Rails application, with automatic
Ruby and JS file reloads out of the box.

## Basic hands-on guide

### App setup

Your team can use the following command after cloning the git repository:

```sh
bin/setup
```
### Deploy

Deploy your app with the following command:

```sh
# Replace `MY_ENV` with `production` or `staging`.
bin/deploy MY_ENV
```

This command pushes your code to Heroku, migrates your database and restarts
your dynos. It will work out of the box if you've generated your app with
`--heroku true`. If not, please create `staging` and `production` git remotes
pointing to the respective Heroku remotes.

### Health check

Check your app's health with the `rake health` command. It runs the following
tasks:

- `rspec` runs your Ruby and Rails specs.
- If you app happens to be below 90% test coverage the `rspec` command will fail.
- `bundle-audit` and `brakeman` check if your app does not have basic
  security holes.
- `rubocop` makes sure your code adheres to style guidelines.

### Testing

#### Ruby tests

Use the following command to run all your specs:

```sh
rspec
```

We use the following tools:

- [rspec](https://github.com/rspec/rspec)
- [capybara](https://github.com/jnicklas/capybara) and
  [database_cleaner](https://github.com/DatabaseCleaner/database_cleaner)
- [factory_girl](https://github.com/thoughtbot/factory_girl)
- [simplecov](https://github.com/colszowka/simplecov) for helping out with test
  coverage

Refer to the [rspec-rails](https://github.com/rspec/rspec-rails) to learn which
kinds of specs are available.

Note that you can require the following files to setup your tests:

- For light unit tests you can require `spec_helper.rb`. It won't boot up
  the Rails environment.
- For tests needing Rails you can require `rails_helper.rb`.
- For feature tests require `feature_helper.rb`. It will compile your assets
  and make feature tests run correctly.

Regarding feature tests, they are configured to run seamlessly with Webpack.

### Application server

We use [puma](https://github.com/puma/puma) as our application server, which
happens to be [Heroku's default
recommendation](https://devcenter.heroku.com/changelog-items/594).

### Background jobs

Our tool of choice is Sidekiq, which is configured as ActiveJob's backend. We
include a `sidekiq.yml` configuration file with default settings, but you are
encouraged to tune it to your application needs.

### Debugging

- [pry-rails](https://github.com/rweng/pry-rails)
- [pry-byebug](https://github.com/deivid-rodriguez/pry-byebug)
- [better-errors](https://github.com/charliesome/better_errors) instead of Web
  Console.

### Performance and Profiling

* [rack-mini-profiler](https://github.com/MiniProfiler/rack-mini-profiler) for
helping out with performance issues
* [spring](https://github.com/rails/spring) for fast Rails actions via
pre-loading
* [bullet](https://github.com/flyerhzm/bullet) yeah, it's very easy to miss out
N+1 queries, that's why we include this gem by default

Spring binstubs are automatically generated within the `bin` folder.

### Environment variables

* [Dotenv](https://github.com/bkeepers/dotenv) for loading environment variables

## Credits

The template uses the [Suspenders](https://github.com/thoughtbot/suspenders)
gem from Thoughtbot as starting point.

[![codeminer42](http://s3.amazonaws.com/cm42_prod/assets/logo-codeminer-horizontal-c0516b1b78a8713270da02c3a0645560.png)](http://codeminer42.com)
