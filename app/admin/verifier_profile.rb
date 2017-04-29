ActiveAdmin.register User, as: "VerifierProfile" do
  menu false

  actions :edit, :update, :index, :show

  permit_params verification_slots_attributes: [:id,
                                                :starts_at,
                                                :ends_at,
                                                :verification_center_id,
                                                :_destroy]

  controller do
    def show
      redirect_to admin_user_path(resource)
    end
  end

  form do |f|
    panel "Info" do
      div do
        status_tag \
          "Recuerda que los verificadores deben ser personas de confianza y que debes haber comprobado que hayan firmado el documento legal.",
          :ok
      end

      attributes_table_for f.object do
        row :full_name
        row :email

        row :status do
          render partial: "admin/verification_status", locals: { user: f.object }
        end
      end
    end

    panel "Ventanas de Verificación" do
      f.has_many :verification_slots, allow_destroy: true, heading: false do |slot|
        slot.input :verification_center, prompt: "Online"

        %i(starts_at ends_at).each do |datetime|
          slot.input datetime,
                     required: true,
                     as: :string,
                     input_html: { class: "js-datetime-picker",
                                   data: { locale: I18n.locale.to_s } }
        end
      end
    end

    f.actions do
      f.action :submit
      cancel_link admin_user_path(resource)
    end
  end
end
