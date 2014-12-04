namespace :app do
  desc "Completely resets the database"
  task reset: :environment do
    `rake db:drop`
    `rake db:migrate`
    `rake db:seed`
  end

end
