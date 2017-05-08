namespace :encomu do
  desc "[encomu] Remove users with unconfirmed email after an elapsed time"
  task :clear_unconfirmed => :environment do
    max_unconfirmed_hours = Rails.application.secrets.users["max_unconfirmed_hours"]
    User.where(confirmed_at: nil).where("confirmation_sent_at < ?", Time.zone.now - max_unconfirmed_hours.hours).destroy_all
  end
end
