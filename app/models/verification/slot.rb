class Verification::Slot < ApplicationRecord
  belongs_to :verification_center, class_name: 'Verification::Center', foreign_key: 'verification_center_id'
  belongs_to :user

  validates :starts_at, :ends_at, presence: true
  validate :proper_interval

  scope :active, -> do
    now = Time.zone.now

    where("starts_at <= ? AND ends_at >= ?", now, now)
  end

  scope :past_or_current, -> { where("starts_at <= ?", Time.zone.now) }

  scope :presential, -> { where.not(verification_center: nil) }
  scope :online, -> { where(verification_center: nil) }

  scope :for_center, -> { where(user: nil) }

  def as_opening_time
    if starts_at.to_date == ends_at.to_date
      date = I18n.l(starts_at, format: :date_short)
      start_time = I18n.l(starts_at, format: :time)
      end_time = I18n.l(ends_at, format: :time)
      from = I18n.t("verification.from")
      to = I18n.t("verification.to")

      "#{date} #{from} #{start_time} #{to} #{end_time}"
    else
      from = I18n.t("verification.from_with_article")
      to = I18n.t("verification.to_with_article")
      start_time = I18n.l(starts_at, format: :short)
      end_time = I18n.l(ends_at, format: :short)

      "#{from} #{start_time} #{to} #{end_time}"
    end
  end

  private

  def proper_interval
    return unless starts_at && ends_at

    errors.add(:ends_at, I18n.t("ends_at_before_starts_at")) if starts_at >= ends_at
  end
end
