require "tmpdir"
require "shellwords"

run "curl https://raw.githubusercontent.com/github/gitignore/master/Rails.gitignore -o .gitignore"

application <<EOF
  config.i18n.default_locale = :ja
  config.time_zone = "Asia/Tokyo"
EOF

if __FILE__ =~ %r{\Ahttps?://}
  source_paths.unshift(tmpdir = Dir.mktmpdir("rails-template"))
  at_exit { FileUtils.remove_entry(tmpdir) }
  git :clone => [
    "--quiet",
    "https://github.com/i544c/rails-template",
    tmpdir,
  ].map(&:shellescape).join(" ")
else
  source_paths.unshift(File.dirname(__FILE__))
end

copy_file ".gitignore"
copy_file "docker-compose.yml"
copy_file "config/database.yml"
copy_file "db/migrate/20180403124752_enable_pgcrypto_extension.rb"


@install_devise = yes?("Install devise? : ")
if @install_devise then
  gem "devise"
  gem "devise-i18n"
end

@install_haml   = yes?("Install haml? : ")
if @install_haml
  gem "haml"
  gem "haml-rails"
end

@install_onkcop = yes?("Install onkcop? : ")
if @install_onkcop then
  gem_group :development do
    gem "onkcop", require: false
  end
  copy_file ".rubocop.yml"
end

@install_rspec  = yes?("Install rspec? : ")
if @install_rspec then
  gem_group :development, :test do
    gem "rspec-rails"
  end
end


after_bundle do
  run "bundle exec spring stop"

  generate :controller, "Pages", "top", "about"
  route "root to: 'pages#top'"

  if @install_devise then
    generate "devise:install"
    inject_into_file "config/environments/development.rb",
      after: /action_mailer.perform_caching.*\n/ do <<-'TEXT'
  config.action_mailer.default_url_options = { host: "localhost" }
      TEXT
    end
    model_name = ask("devise model? [user]: ")
    model_name = "user" if model_name.blank?
    generate "devise", model_name
    generate "devise:views"
  end

  if @install_haml then
    run "HAML_RAILS_DELETE_ERB=true bundle exec rake haml:erb2haml"
  end

  if @install_rspec then
    generate "rspec:install"
  end
end
