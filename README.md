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

  1. [![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy) Deploy with the previous Heroku button. Make sure to setup the environment variable `ENDPOINT_URL_HOST` in the deploy page. For example, if the selected `App name` is `course-planner`, then the `ENDPOINT_URL_HOST` should be `course-planner.herokuapp.com`.
  2. Create a SendGrid API Key and add it to the environment variable `SENDGRID_API_KEY` in the Heroku Settings tab.

### Gigalixir

For more details, see the Gigalixir [quick start](http://gigalixir.readthedocs.io/en/latest/main.html#getting-started-guide)

  1. Clone this repository
  ```bash
    git clone https://github.com/digitalnatives/course_planner.git
  ```

  2. Go to the project directory
  ```bash
    cd course_planner
  ```

  3. Install gigalixir CLI (requires python 2.7)
  ```bash
    pip install gigalixir
  ```

  4. Login with your Gigalixir account
  ```bash
    gigalixir login
  ```

   3. Create the application `your-app-name`, which should be unique
  ```bash
    APP_NAME=$(gigalixir create --name your-app-name)
  ```

  4. Create the database, and wait its state to become `AVAILABLE`.
  ```bash
    gigalixir create_database $APP_NAME
    gigalixir databases $APP_NAME
  ```

  5. Set the environment variables
  ```bash
    gigalixir set_config $APP_NAME DATABASE_URL $YOUR_DB_URL
    gigalixir set_config $APP_NAME SENDGRID_API_KEY $YOUR_SENDGRID_API_KEY
    gigalixir set_config $APP_NAME EMAIL_FROM_NAME $EMAIL_FROM_NAME
    gigalixir set_config $APP_NAME EMAIL_FROM_EMAIL $EMAIL_FROM_EMAIL
  ```

  5. Deploy the code
  ```bash
    git push gigalixir master
  ```

  6. Run the data seed
  ```bash
    gigalixir run $APP_NAME Elixir.CoursePlanner.ReleaseTasks seed
  ```
