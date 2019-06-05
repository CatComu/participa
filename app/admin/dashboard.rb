ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Información importante" do
          div "Esperamos que hayas recibido el sermón usual del Administrador. Normalmente se reduce a estas tres cosas" 
          ul do
            li "Respeta la privacidad de los otros."
            li "Piensa antes de hacer click."
            li "Un gran poder conlleva una gran responsabilidad."
          end
        end
      end
    end
    columns do
      column do
        panel "Últimos usuarios dados de alta" do
          columns do
            column do
              User.limit(30).map do |user|
                li link_to(user.full_name, admin_user_path(user)) + "- #{user.created_at}"
              end
            end
            column do
              User.limit(30).offset(30).map do |user|
                li link_to(user.full_name, admin_user_path(user)) + "- #{user.created_at}"
              end
            end
          end
        end
      end
    end
  end
end
