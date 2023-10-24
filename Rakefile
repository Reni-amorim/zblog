# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks


namespace :db do
    desc "Create the production database"
    task create_production: :environment do
      Rake::Task["db:create"].invoke
    end
  end
