class SmsValidatorController < ApplicationController
  include SimpleCaptcha::ControllerHelpers
  
  before_action :authenticate_user! 
  before_action :can_change_phone

  def can_change_phone
    unless current_user.can_change_phone?
      redirect_to root_path, flash: {error: "Ya has confirmado tu número en los últimos meses." }
    end
  end

  def step1 
    authorize! :step1, :sms_validator
  end

  def step2
    authorize! :step2, :sms_validator
    redirect_to sms_validator_step1_path if current_user.unconfirmed_phone.nil? 
    @user = current_user
  end

  def step3
    authorize! :step3, :sms_validator
    if current_user.unconfirmed_phone.nil? 
      redirect_to sms_validator_step1_path 
      return
    end
    if current_user.sms_confirmation_token.nil? 
      redirect_to sms_validator_step2_path
      return
    end
    @user = current_user
    render action: "step3"
  end

  def phone
    authorize! :phone, :sms_validator
    begin 
      phone = current_user.phone_normalize(phone_params[:unconfirmed_phone])
    rescue
      current_user.errors.add(:unconfirmed_phone, "Revisa el formato")
    end
    if phone.nil? 
      current_user.unconfirmed_phone = phone_params[:unconfirmed_phone]
    else
      current_user.unconfirmed_phone = phone
    end
    if current_user.save
      current_user.set_sms_token!
      redirect_to sms_validator_step2_path
    else
      render action: "step1"
    end
  end

  def captcha 
    authorize! :captcha, :sms_validator
    if simple_captcha_valid?
      current_user.send_sms_token!
      render action: "step3"
    else
      flash.now[:error] = t('sms_validator.phone.captcha_invalid') 
      render action: "step2"
    end
  end

  def valid
    authorize! :valid, :sms_validator
    #if current_user.check_sms_token(params[:sms_token][:sms_user_token])
    if current_user.check_sms_token(sms_token_params[:sms_user_token_given])
      flash[:notice] = t('sms_validator.phone.valid')

      if current_user.apply_previous_user_vote_location
        flash[:alert] = t('registration.message.existing_user_location')        
      end
      redirect_to authenticated_root_path
    else
      flash.now[:error] = t('sms_validator.phone.invalid') 
      render action: "step3"
    end
  end

  private

  def phone_params
    params.require(:user).permit(:unconfirmed_phone)
  end

  def sms_token_params
    params.require(:user).permit(:sms_user_token_given)
  end

end
