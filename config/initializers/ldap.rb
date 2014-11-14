Warden::Strategies.add(:ldap) do 
  def valid? 
    # code here to check whether to try and authenticate using this strategy; 
    return true/false 
  end 

  def authenticate! 
    # code here for doing authentication; 
    # if successful, call  
    success!(resource) # where resource is the whatever you've authenticated, e.g. user;
    # if fail, call 
    fail!(message) # where message is the failure message 
  end 
end 