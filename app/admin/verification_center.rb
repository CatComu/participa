ActiveAdmin.register Verification::Center do
  menu :parent => "Users"

  permit_params :name,
                :street,
                :postalcode,
                :city,
                :latitude,
                :longitude,
                verification_slots_attributes: [:id, :starts_at, :ends_at, :_destroy]

  filter :name
  filter :address

  index do
    selectable_column
    id_column
    column :name
    column :address
    column :latitude
    column :longitude
    column :created_at
    column :updated_at
    actions
  end

  show do
    div id: "verification_center",
        :"data-name" => resource.name,
        :"data-address" => resource.address,
        :"data-longitude" => resource.longitude,
        :"data-latitude" => resource.latitude do
      attributes_table do
        row :name
        row :address
        row :latitude
        row :longitude
      end
    end
    panel "Mapa" do
      div id: "js-verification-map", style: "width: 100%; height: 400px"
    end
    active_admin_comments
  end

  sidebar I18n.t("activerecord.models.verification/slot.other"), only: :show do
    table_for resource.verification_slots do
      column :starts_at
      column :ends_at
    end
  end

  form html: { id: "verification_center" } do |f|
    tabs do
      tab "Localización" do
        f.inputs "Información" do
          f.input :name
          f.input :street
          f.input :postalcode
          f.input :city
          a "Buscar", "#", class: "button", id: "js-verification-map-search", style: "margin: 2em 0 1em 1em; cursor: pointer;"
        end
        panel "Mapa" do
          div id: "js-verification-map-error", class: "flash flash_error hide" do
            "No se ha encontrado esta dirección. Corrigela y busca de nuevo o pon su latitud y longitud manualmente."
          end
          div id: "js-verification-map", style: "width: 100%; height: 400px"
        end
        f.inputs "Coordenadas" do
          f.input :latitude, required: true
          f.input :longitude, required: true
        end
      end
      tab "Horarios" do
        f.inputs "Horarios" do
          f.has_many :verification_slots, allow_destroy: true, heading: false do |slot|
            %i(starts_at ends_at).each do |datetime|
              slot.input datetime,
                         required: true,
                         as: :string,
                         input_html: { class: "js-datetime-picker",
                                       data: { locale: I18n.t("meta.flatpickr_code") } }
            end
          end
        end
      end
    end
    f.actions
  end
end
