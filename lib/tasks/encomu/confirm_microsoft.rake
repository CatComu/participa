require 'tasks/encomu/confirmation_extensions'

namespace :encomu do
  desc "[encomu] Resend confirmations for Microsoft users"
  task :confirm_microsoft => :environment do
    User.include(ConfirmationExtensions)

    target = User.confirmation_sent_before(DateTime.new(2016,12,27)).microsoft

    if target.none?
      raise "No Microsoft users left to be sent a confirmation email"
    end

    already_confirmed = target.where.not(confirmed_at: nil)

    if already_confirmed.any?
      raise <<~MSG
        The following target users are already confirmed, so emails
        shoudn't be sent to them:

        #{already_confirmed.pluck(:email).join("\n")}
      MSG
    end

    STDOUT.print <<~MSG.strip

      About to resend confirmation email to:

      #{target.pluck(:email).join("\n")}

      Continue? (y/n)
    MSG

    abort unless STDIN.gets.chomp == 'y'

    target.each(&:send_confirmation_instructions)
  end
end
