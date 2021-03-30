remove_file 'Gemfile'

file 'Gemfile', <<~RUBY
  ruby '#{RUBY_VERSION}'

  source 'https://rubygems.org'
  git_source(:github) { |repo| "https://github.com/\#{repo}.git" }

  gem 'rails'

  gem 'bcrypt'
  gem 'bootsnap', require: false
  gem 'pg'
  gem 'puma'
  gem 'turbolinks'
  gem 'webpacker'

  group :development, :test do
    gem 'byebug'
    gem 'factory_bot_rails'
    gem 'rspec-rails'
  end

  group :test do
    gem 'capybara'
    gem 'capybara-screenshot'
    gem 'launchy'
    gem 'selenium-webdriver'
    gem 'shoulda-matchers'
    gem 'webdrivers'
  end

  group :development do
    gem 'listen'
    gem 'rubocop'
    gem 'rubocop-rails'
    gem 'rubocop-rspec'
    gem 'spring'
    gem 'web-console'
  end
RUBY

initializer 'generators.rb', <<~RUBY
  Rails.application.config.generators do |g|
    g.test_framework :rspec,
      fixtures: false,
      view_specs: false,
      helper_specs: false,
      routing_specs: false,
      request_specs: false,
      controller_specs: false
    g.stylesheets :false
    g.helper :false
    g.factory_bot suffix: 'factory'
  end
RUBY

inject_into_file 'bin/setup', after: "puts \"\\n== Preparing database ==\"\n" do
  "  system! 'docker-compose up -d'\n"
end
file 'docker-compose.yml', <<-YML
  version: "3.9"

  services:
    db:
      image: postgres
      volumes:
        - ./tmp/db:/var/lib/postgresql/data
      environment:
        POSTGRES_PASSWORD: password
      ports:
        - "5432:5432"
YML
inject_into_file 'config/database.yml', after: "adapter: postgresql\n" do
  <<-YML
  host: 0.0.0.0
  username: postgres
  password: password
  YML
end
file '.rubocop.yml', <<~YML
  inherit_from:
    - https://raw.githubusercontent.com/tony-rowan/.rubocop.yml/main/.rubocop.yml
YML

remove_file '.ruby-version'
file '.tool-versions', "ruby #{RUBY_VERSION}"

remove_dir 'app/assets'
add_file 'app/javascript/images/.keep'

run 'yarn add --dev --exact prettier'
file '.prettierrc.json', <<~JS
  {}
JS
file '.prettierignore', <<~IGNORE
  node_modules
  public/packs
  public/packs-test
  tmp
IGNORE

run 'yarn add --dev lint-staged husky'
run 'npx husky-init && yarn'
gsub_file '.husky/pre-commit', "npm test\n", <<~SH
  bin/yarn lint-staged
  bin/rspec
SH

file '.lintstagedrc', <<~JSON
  {
    "**/*": [
      "bin/yarn prettier --write --ignore-unknown",
      "bin/bundle exec rubocop --auto-correct --only-recognized-file-types --force-exclusion"
    ]
  }
JSON

run 'yarn add tailwindcss@npm:@tailwindcss/postcss7-compat @tailwindcss/postcss7-compat postcss@^7 autoprefixer@^9'
file 'tailwind.config.js', <<~JS
  module.exports = {
    purge: ["./app/helpers/**/*", "./app/views/**/*"],
    darkMode: false, // or 'media' or 'class'
    theme: {
      extend: {},
    },
    variants: {
      extend: {
        borderColor: ["hover"],
      },
    },
    plugins: [],
  };
JS
file 'app/javascript/packs/application.css', <<-CSS
  @import "tailwindcss/base";
  @import "tailwindcss/components";
  @import "tailwindcss/utilities";
CSS
prepend_file 'app/javascript/packs/application.js', 'import "./application.css";'

after_bundle do
  generate 'rspec:install'
  remove_file '.rspec'
  file '.rspec', <<~RSPEC
    --format documentation
    --order random
    --require spec_helper
  RSPEC
  run 'bundle binstubs rspec-core'

  git :init
  git add: '.'
  git commit: "-m 'Initial commit' --no-verify"

  run 'bin/setup'
end
