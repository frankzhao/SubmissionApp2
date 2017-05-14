class UploadsController < ApplicationController
  before_action :require_logged_in

  def download
    path = Rails.root.join('public', 'uploads', params[:path])
    
    begin
      child?(Rails.root.to_s, path.to_s)
    rescue ArgumentError
      flash_message :error, "Unknown path foubd"
      return redirect_to root_path
    end
    
    @file = File.open(path).read
    
    send_file @file, type: "application/octet-stream", :x_sendfile=>true 
  end

  private
  
  def child?(root, target)
    raise ArgumentError, "target.size=#{target.size} < #{root.size} = root.size"\
      if target.size < root.size

    target[0...root.size] == root &&
      (target.size == root.size || target[root.size] == ?/)
  end

end
