module Features
  extend self

  def inscriptions?
    features["allow_inscription"]
  end

  def verifications?
    presential_verifications? || online_verifications?
  end

  def presential_verifications?
    features["verification_presencial"]
  end

  def online_verifications?
    features["verification_sms"]
  end

  def elections?
    features["elections"]
  end

  def collaborations?
    features["collaborations"]
  end

  def redsys_collaborations?
    features["collaborations_redsys"]
  end

  def blog?
    features["blog"]
  end

  def proposals?
    features["proposals"]
  end

  def participation_teams?
    features["participation_teams"]
  end

  def microcredits?
    features["microcredits"]
  end

  def background_jobs?
    features["use_resque"]
  end

  private

  def features
    Rails.application.secrets.features
  end
end
