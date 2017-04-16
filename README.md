[![Build Status](https://travis-ci.org/digitalnatives/course_planner.svg?branch=master)](https://travis-ci.org/digitalnatives/course_planner)

# Course Planner

## Development Setup

### Docker

  * Install Elixir dependencies with `docker-compose run web mix deps.get`
  * Setup your database (create, migrate and seed) with `docker-compose run web mix ecto.setup`
  * Install Node.js dependencies with `docker-compose run web npm install`
  * Start Phoenix endpoint (db and web containers) with `docker-compose up`

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
