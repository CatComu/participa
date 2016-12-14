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
    end
  end
end
