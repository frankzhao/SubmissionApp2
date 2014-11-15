require "anu-ldap"

module ApplicationHelper
  def require_logged_in
    unless current_user
      flash[:errors] = ["You don't have permission to access that page."]
      redirect_to '/'
    end
  end

  # Multiple flash messages
  def flash_message(type, text)
    flash[type] ||= []
    flash[type] << text
  end

  def flash_errors
    flashes = []
    flash.each do |type, messages|
      if messages.is_a?(String)
        flashes << render(partial: 'layouts/flash',
          locals: {:type => type, :message => messages})
      else
        messages.each do |m|
          flashes << render(partial: 'layouts/flash',
            locals: {:type => type, :message => m}) unless m.blank?
        end
      end
    end
    flashes.join('').html_safe
  end

end
