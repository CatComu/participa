ActiveAdmin.register Position do
  menu parent: "Users"
  permit_params %i[name position_type group_id]

  index do
    column(:name) { |position| link_to position.name, admin_position_path(position) }
    column :position_type
    column :group
    actions
  end

  form do |f|
    f.semantic_errors
    inputs do
      f.input :name
      f.input :position_type
      f.input :group
    end
    actions
  end
end
