namespace :encomu do
  desc "[encomu] Resend confirmation instructions to users"
  task :retry_confirmation_instructions, [:mlist] => :environment do |_t, args|
    target = if args[:mlist].present?
               User.where(email: args[:mlist].split(','))
             else
               User.where('confirmed_at is NULL AND confirmation_sent_at < ?', 1.day.ago)
             end

    if target.none?
      STDOUT.print "\nNo users left to be resent a confirmation email.\n\n"
    else
      STDOUT.print <<~MSG.strip
        About to resend confirmation email to the following #{target.size} users:

        #{target.pluck(:email).join("\n")}

        Continue? (y/n)
      MSG

      abort unless STDIN.gets.chomp == 'y'

      target.each do |user|
        STDOUT.puts "\nResending email to #{user.email}..."
        ConfirmationMailer.retry_confirmation_instructions(user).deliver_now

        sleep 10
      end
    end
  end
end
