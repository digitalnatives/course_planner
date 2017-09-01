[![Build Status](https://travis-ci.org/digitalnatives/course_planner.svg?branch=master)](https://travis-ci.org/digitalnatives/course_planner)
[![codebeat badge](https://codebeat.co/badges/ddc1feb0-d6a0-451f-b77d-1196254ac024)](https://codebeat.co/projects/github-com-digitalnatives-course_planner-master)
[![Coverage Status](https://coveralls.io/repos/github/digitalnatives/course_planner/badge.svg?branch=master)](https://coveralls.io/github/digitalnatives/course_planner?branch=master)

# Course Planner

## Development Setup

### Local

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets; npm install; cd ..`
  * Start Phoenix endpoint with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Production Setup

### Heroku

First, be sure `MIX_ENV` is set to `heroku` during compilation

    heroku config:set MIX_ENV=heroku

Then, click the button!

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

### Gigalixir

For more details, see [the quick start](http://gigalixir.readthedocs.io/en/latest/main.html#getting-started-guide)

   1. `pip install gigalixir`
   2. `gigalixir login`
   3. `APP_NAME=$(gigalixir create --name course-planner)`
   4. `gigalixig set_config $APP_NAME DATABASE_URL $YOUR_DB_URL`
   5. `git push gigalixir master`
   6. `gigalixir migrate $APP_NAME`


