ActiveAdmin.register Group do
  permit_params %i[name starts_at ends_at is_institutional has_location location_type description territory_holder territory_type territory_id]

  menu parent: "Users"

  index do
    id_column
    column :name
    column :starts_at
    column :ends_at
    actions
  end

  show do
    attributes_table do
      row :name
      row :starts_at
      row :ends_at
      row :is_institutional
      row :description
      row :has_location
      row :location_type
    end
    panel "Users" do
      if group.users.any?
        table_for group.users do
          column(t('user.name', scope: 'activerecord.attributes')) {|u| link_to u.full_name, admin_user_path(u) }
          column(t('position.name', scope: 'activerecord.attributes')) { |u| u.positions.find_by(group: group) }
        end
      end
    end
  end

  form partial: "form"
  # form do |f|
  #   f.semantic_errors
  #   inputs do
  #     f.input :name
  #     f.input :starts_at, as: :datepicker
  #     f.input :ends_at, as: :datepicker
  #     f.input :is_institutional
  #     f.input :description
  #     f.input :has_location
  #     f.input :location_type
  #   end
  #   actions
  # end
end
