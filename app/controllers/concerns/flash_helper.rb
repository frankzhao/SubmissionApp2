module FlashHelper
  extend ActiveSupport::Concern

  def flash_message(type, text)
    flash[type] ||= []
    flash[type] << text
  end
end