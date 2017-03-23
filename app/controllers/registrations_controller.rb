class RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: :create
  before_action :configure_account_update_params, only: :update

  def regions_provinces
    # Dropdownw for AJAX on registrations edit/new
    #
    render \
      partial: 'subregion_select',
      locals: {
        catalonia_resident: cast_catalonia_resident(params[:user_catalonia_resident]),
        country: params[:user_country],
        province: params[:user_province],
        disabled: false,
        required: true,
        field: :province,
        title: "Provincia",
        options_filter: ((!current_user or current_user.can_change_vote_location?) ? User.blocked_provinces : nil)
      }
  end

  def regions_municipies
    # Dropdownw for AJAX on registrations edit/new
    #
    render \
      partial: 'municipies_select',
      locals: {
        country: params[:user_country],
        province: params[:user_province],
        town: params[:user_town],
        disabled: false,
        required: true,
        field: :town,
        title: "Municipio"
      }
  end

  def vote_municipies
    # Dropdownw for AJAX on registrations edit/new
    #
    render \
      partial: 'municipies_select',
      locals: {
        country: "ES",
        province: params[:user_vote_province],
        town: params[:user_vote_town],
        disabled: false,
        required: false,
        field: :vote_town,
        title: "Municipio de participación"
      }
  end

  def new
    if Features.inscriptions?
      super do |user|
        user.assign_attributes(country: "ES", catalonia_resident: "1")
      end
    else
      redirect_to root_path, flash: { notice: 'Registrations are not open.' }
    end
  end

  def create
    build_resource(sign_up_params)
    if resource.valid_with_captcha?
      super do
        if Features.elections?
          # If the user already had a location but deleted itself, he should have
          # his previous location
          #
          if resource.apply_previous_user_vote_location
            flash[:alert] = t("registration.message.existing_user_location")
          end
        end
      end
    else
      redirect_if_valid_dup(:document_vatid)
      return if performed?

      redirect_if_valid_dup(:email)
      return if performed?

      clean_up_passwords(resource)
      render :new
    end
  end

  private

  def cast_catalonia_resident(param)
    return unless param

    param == "1" ? true : false
  end

  def redirect_if_valid_dup(type)
    if valid_with_dup?(type)
      UsersMailer.remember_email(type, resource.public_send(type)).deliver_now
      redirect_to(root_path, notice: t("devise.registrations.signed_up_but_unconfirmed"))
    end
  end

  def valid_with_dup?(type)
    return false unless user_already_exists?(type)

    resource.errors.empty?
  end

  def user_already_exists?(type)
    # FIX for https://github.com/plataformatec/devise/issues/3540
    # Devise paranoid only works for passwords resets.
    # With the uniqueness validation on user.document_vatid and user.email
    # it's possible to do a user listing attack.
    #
    # If the email or document_vatid are already taken we should fail
    # silently (showing the same message as an OK creation or giving an
    # error for invalid validations) and send an email to the original
    # user.
    #
    # See test/features/users_are_paranoid_test.rb
    #
    if resource.errors.added? type, :taken
      resource.errors.messages[type] -= [ t('activerecord.errors.models.user.attributes.' + type.to_s + '.taken') ]
      resource.errors.delete(type) if resource.errors.messages[type].empty?
      return true
    else
      return false
    end
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: sign_up_permitted_keys)
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update,
                                      keys: account_update_permitted_keys)
  end

  def account_update_permitted_keys
    if current_user.can_change_vote_location?
      common_permitted_keys + %i(current_password vote_province vote_town)
    else
      common_permitted_keys + %i(current_password)
    end
  end

  def sign_up_permitted_keys
    common_permitted_keys +
      %i(
        document_type
        document_vatid
        terms_of_service
        age_restriction
        inscription
        vote_town
        vote_province
        captcha
        captcha_key
      )
  end

  def common_permitted_keys
    %i(
      first_name
      last_name
      email
      email_confirmation
      password
      password_confirmation
      born_at
      gender_identity
      wants_newsletter
      catalonia_resident
      country
      province
      town
      address
      postal_code
    )
  end
end
