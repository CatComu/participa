class VerificationController < ApplicationController
  before_action :load_user, only: %i(result_ok result_ko)

  def show
    authorize! :show, :verification
  end

  def step1
    authorize! :step1, :verification
  end

  def step2
    authorize! :step2, :verification
  end

  def result_ok
    authorize! :result_ok, :verification

    @user.verify! current_user
  end

  def result_ko
    authorize! :result_ko, :verification
  end

  def search
    authorize! :search, :verification

    @user = User.find_by_email(search_params[:email])
    if @user
      if @user.confirmed_at.nil?
        @user.send_confirmation_instructions
        flash.now[:alert] = unconfirmed_email_alert
        render :step1
      elsif @user.is_verified_presentially? 
        flash.now[:notice] = already_verified_alert
        render :step1
      else
        render :step2
      end
    else 
      flash.now[:error] = t('verification.alerts.not_found', query: search_params[:email])
      render :step1
    end
  end

  private

  def load_user
    @user = User.find params[:id]
  end

  def search_params
    params.require(:user).permit(:email)
  end

  def already_verified_alert
    t('verification.alerts.already_presencial', document: @user.document_vatid,
                                                by: @user.verified_by.full_name,
                                                when: @user.verified_at)
  end

  def unconfirmed_email_alert
    view_context.raw t('verification.alerts.unconfirmed_html', email: @user.email)
  end
end
