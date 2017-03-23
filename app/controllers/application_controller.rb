class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_locale
  before_action :banned_user
  before_action :verified_user
  before_action :configure_sign_in_params, if: :devise_controller?
  before_action :allow_iframe_requests
  before_action :admin_logger

  def allow_iframe_requests
    response.headers.delete('X-Frame-Options')
  end

  def admin_logger
    if params["controller"].starts_with? "admin/"
      tracking = Logger.new(File.join(Rails.root, "log", "activeadmin.log"))
      if user_signed_in?
        tracking.info "** #{current_user.full_name} ** #{request.method()} #{request.path}"
      else
        tracking.info "** Anonymous ** #{request.method()} #{request.path}"
      end
      tracking.info params.to_s
      #tracking.info request
    end
  end

  def default_url_options(options={})
    { locale: I18n.locale }
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def after_sign_in_path_for(user)
    cookies.permanent[:cookiepolicy] = 'hide'

    super    
  end
  
  def banned_user
    if current_user and current_user.banned?
      name = current_user.full_name
      sign_out_and_redirect current_user
      flash[:notice] = t("podemos.banned", full_name: name)
    end
  end

  def verified_user
    return unless current_user && !current_user.is_verified? && !allowed_for_unverified?

    if Features.online_verifications?
      if params["controller"] == "sms_validator"
        flash.now[:alert] = t("issues.confirm_sms")
      else
        redirect_to sms_validator_step1_path
      end
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def access_denied exception
    redirect_to root_url, :alert => exception.message
  end

  def authenticate_admin_user!
    unless signed_in? && (current_user.is_admin? || current_user.finances_admin? || current_user.impulsa_admin?)
      redirect_to root_url, flash: { error: t('podemos.unauthorized') }
    end
  end 

  def user_for_papertrail
    user_signed_in? ? current_user : "Unknown user"
  end

  protected

  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: sign_in_permitted_keys)
  end

  def sign_in_permitted_keys
    %i(login document_vatid email password remember_me)
  end

  def allowed_for_unverified?
      params[:controller] == 'devise/sessions' or
      params[:controller] == "registrations" or
      params[:controller].start_with? "admin/"
  end
end
