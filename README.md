# Rails Application Template
My personal Rails Application Template. Geared towards hobby projects
running on Heroku and my own preferences.

## Usage
To create a new Rails app with this template (and the options it is
best suited for) run:

```
rails new hello-heroku --database=postgresql --webpack=stimulus --minimal --skip-sprockets --skip-test --template=https://raw.githubusercontent.com/tony-rowan/rails-application-template/main/template.rb
```

## Exaplanation
This template does a few things.

- Completely rewrites the Gemfile to make it easier on the eyes, but drops the Windows support
- Installs RSpec with sensible defaults
- Installs Rubocop with a sensible styles guide
- Installs factory_bot and sets the generator to have the postfix `_factory`
- Installs shoulda_matchers and includes the methods in all tests 
- Configures the project to use asdf - a `.tool-versions` file rather than a `.ruby-version` file
- Installs and configures Prettier
- Installs and configures husky and lint-staged to run Prettier and Rubocop on commit
- Installs Tailwindcss
- Removes sprockets and all non-webpack based assets entirely
- Adds a `docker-compose.yml` file so you don't have to run Postgres locally
- Adds a basic `Profile`
