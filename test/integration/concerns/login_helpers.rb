module Participa
  module Test
    module LoginHelpers
      include Capybara::DSL

      def login user, password = nil
        visit new_user_session_path
        fill_in 'user[login]', with: user.email
        fill_in 'user[password]', with: password || user.password
        click_button 'Iniciar sesión'
      end

      def logout
        click_link 'Cerrar sesión'
        assert_content "Has cerrado la sesión satisfactoriamente"
      end
    end
  end
end
