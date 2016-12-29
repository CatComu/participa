module ConfirmationExtensions
  def self.included(base)
    base.class_eval do
      scope :microsoft, -> { where("email ~ '@(live|hotmail|outlook)\..*'") }

      scope :confirmation_sent_before, ->(date) do
        where('confirmation_sent_at < ?', date.to_s(:db))
      end
    end
  end
end
