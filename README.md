[![Build Status](https://travis-ci.org/digitalnatives/course_planner.svg?branch=master)](https://travis-ci.org/digitalnatives/course_planner)
[![codebeat badge](https://codebeat.co/badges/ddc1feb0-d6a0-451f-b77d-1196254ac024)](https://codebeat.co/projects/github-com-digitalnatives-course_planner-master)

# Course Planner

## Development Setup

### Docker

  * Copy the docker-compose sample file
    `cp docker-compose.yml.sample docker-compose.yml`
  * Copy the docker-compose-up sample script
    `cp ./scripts/docker-compose-up.sh.sample ./scripts/docker-compose-up.sh`
  * Create and seed database, then start Phoenix
    `docker-compose up`

  You may change your local `docker-compose.yml` and `./scripts/docker-compose-up.sh` according to your preferences, if you want to use a local database for example.

### Local

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
