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
[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)
