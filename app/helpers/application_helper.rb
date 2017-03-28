module ApplicationHelper
  def account_update_tab
    user_params = params['user']
    return 'general' unless user_params

    return 'password' if user_params['password']
    return 'email' if user_params['email']

    'general'
  end

  # Like link_to but third parameter is an array of options for current_page?.
  def nav_menu_link_to name, icon, url, current_urls, html_options = {}
    html_options[:class] ||= ""
    html_options[:class] += " active" if current_urls.any? { |u| current_page?(u) }
    link_to(fa_icon(icon) + content_tag(:span, name), url, html_options)
  end

  def new_notifications_class
    # TODO: Implement check if there are any new notifications
    # If so, return "claim"
    ""
  end

  def info_box &block
    content = with_output_buffer(&block)
    render partial: 'application/info', locals: { content: content }
  end

  # Renders an alert with given title, and content given in a block.
  def alert_box title, &block
    render_flash 'application/alert', title, &block
  end

  # Renders an error with given title, content given in a block.
  def error_box title, &block
    render_flash 'application/error', title, &block
  end

  # Generalization from render_alert and render_error
  def render_flash partial_name, title, &block
    content = with_output_buffer(&block)
    render partial: partial_name, locals: {title: title, content: content}
  end

  def field_notice_box
    render partial: 'application/form_field_notice'
  end
  def errors_in_form resource
    render partial: 'application/errors_in_form', locals: {resource: resource}
  end
  def steps_nav current_step, *steps_text
    render partial: 'application/steps_nav',
           locals: { first_step: steps_text[0],
                     second_step: steps_text[1],
                     third_step: steps_text[2],
                     steps_text: steps_text,
                     current_step: current_step }
  end

  def body_class signed_in, controller, action
    if !signed_in && controller == "sessions" && action == "new"
      "logged-out"
    else
      "signed-in"
    end
  end
end
