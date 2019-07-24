# frozen_string_literal: true

class ConfirmationsController < Devise::ConfirmationsController
  def show
    super do
      if resource.errors[:email].any?
        flash.now[:alert] = resource.errors[:email].first
      end
    end
  end
end
