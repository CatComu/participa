ActiveAdmin.register Position do
  permit_params %i[name position_type group_id downloader]

  menu parent: "Organización"

  index do
    column(:name) { |position| link_to position.name, admin_position_path(position) }
    column :position_type
    column :group
    column :users do |position|
      table_for position.users do
        column do |user|
           link_to user.full_name, admin_user_path(user)
        end
      end
    end
    actions
  end

  form do |f|
    f.semantic_errors
    inputs do
      f.input :name
      f.input :position_type
      f.input :downloader
      f.input :group
    end
    actions
  end
end
