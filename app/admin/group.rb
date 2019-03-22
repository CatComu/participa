ActiveAdmin.register Group do
  permit_params %i[name starts_at ends_at is_institutional has_locations location_type has_spaces space_type]

  menu parent: "Users"

  index do
    id_column
    column :name
    column :starts_at
    column :ends_at
    actions
  end

  form do |f|
    f.semantic_errors
    inputs do
      f.input :name
      f.input :starts_at, as: :datepicker
      f.input :ends_at, as: :datepicker
      f.input :is_institutional
      f.input :has_space
      f.input :space_type
      f.input :has_location
      f.input :location_type
    end
    actions
  end
end
