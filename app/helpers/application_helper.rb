require "anu-ldap"

module ApplicationHelper
  def url_prefix
    if ENV['RAILS_RELATIVE_URL_ROOT'].nil? || ENV['RAILS_RELATIVE_URL_ROOT'].strip == '/'
      ''
    else
      ENV['RAILS_RELATIVE_URL_ROOT'].strip
    end
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

  def title(page_title)
    content_for :title, page_title.to_s + " | SubmissionApp2"
  end
end
