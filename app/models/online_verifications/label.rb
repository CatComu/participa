module OnlineVerifications
  class Label < ApplicationRecord
    def description
      I18n.t("online_verifications.label.#{code}")
    end
  end
end
