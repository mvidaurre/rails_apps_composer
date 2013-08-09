# Application template recipe for the rails_apps_composer. Change the recipe here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/frontend.rb

after_bundler do
  if prefer :javascript_mvc_framework, 'emberjs'
    insert_into_file 'config/environments/development.rb', "  config.ember.variant = :development\n", :after => "Application.configure do\n"
    insert_into_file 'config/environments/test.rb', "  config.ember.variant = :development\n", :after => "Application.configure do\n"
    insert_into_file 'config/environments/production.rb', "  config.ember.variant = :production\n", :after => "Application.configure do\n"
    generate 'ember:bootstrap -g --javascript-engine coffee'
    generate 'ember:install --head'
    if prefer :templates, 'haml'
      run 'bundle update emblem-source'
    end
    if File.exist?('vendor/assets/ember/development/ember-data.js')
      ember_data_first_line_file = File.open('vendor/assets/ember/development/ember-data.js') {|f| f.readline}
      puts "ember_data_first_line_file: #{ember_data_first_line_file}"
      ember_data_version = ember_data_first_line_file.scan(/Version: v0.(..)/).to_s
      puts "ember_data_version: #{ember_data_version}"
      gsub_file 'app/assets/javascripts/store.js.coffee',
          /11/,
          ember_data_version
    end
    run 'rake tmp:clear'
  elsif prefer :javascript_mvc_framework, 'angularjs'
    insert_into_file 'app/assets/javascripts/application.js', "//= require angular\n//= require angularjs/rails/resource\n", :after => "jquery_ujs\n"
  elsif prefer :javascript_mvc_framework, 'backbonejs'
    generate 'backbone:install'
  end
  ### GIT ###
  git :add => '-A' if prefer :git, true
  git :commit => '-qm "rails_apps_composer: javascript MV* framework"' if prefer :git, true
end # after_bundler

__END__

name: javascript_mvc_framework
description: "Install a Javascript MV* framework."
author: mvidaurre

requires: [setup, gems]
run_after: [setup, gems]
category: frontend
