require 'podemos_export'

namespace :encomu do
  desc "[encomu] Fill data of users in a file"
  task :fill_data_file, [:input_file] => :environment do |t, args|
    args.with_defaults(:input_file => nil)

    fill_data args.input_file, User.confirmed_mail
  end
end
