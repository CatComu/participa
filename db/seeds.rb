require 'database_cleaner'

DatabaseCleaner.clean_with :truncation
pw = '111111'

puts "Creating Users"

admin = FactoryGirl.create(:user,
                           :admin,
                           :verifying_presentially,
                           password: pw,
                           email: "admin@example.com") 
puts "Creating admin user with email #{admin.email}"

presential_verifier = FactoryGirl.create(:user, :verifying_presentially)
puts "Creating presential verifier with email #{presential_verifier.email}"

superadmin = FactoryGirl.create(:user, :superadmin, password: pw, email: "superadmin@example.com") 
puts "Creating superadmin user with email #{superadmin.email}"

(0..5).each do |i|
  user = FactoryGirl.create(:user, password: pw, email: "unverified#{i}@example.org")
  puts "Creating unverified user with email #{user.email}"

  user = FactoryGirl.create(:user, password: pw, email: "verified#{i}@example.org")
  user.verify! admin
  puts "Creating verified user with email #{user.email}"

  user = FactoryGirl.create(:user,
                            :confirmed_by_sms,
                            password: pw,
                            email: "confirmed_by_sms#{i}@example.org")
  puts "Creating user confirmed_by_sms with email #{user.email}"
end
