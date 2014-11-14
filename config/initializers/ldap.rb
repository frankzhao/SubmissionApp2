module Devise
  module Strategies
    class Ldap < Base

      def valid?
        true
      end 

      def authenticate!
        # Don't use LDAP when logging in as admin
        if params[:uid] == "u0000000"
          fail()
          return
        else
          # Use LDAP
          if params[:user][:uid]
            uid = params[:user][:uid]
            pass = params[:user][:password]
          
            if AnuLdap.authenticate(uid, pass)
              ldap_user = AnuLdap.find_by_uni_id(uid)
            
              # Create and update first time users
              if not User.find_by_uid(ldap_user[:uni_id])
                u = User.create(:uid => ldap_user[:uni_id],
                  :name => ldap_user[:given_name] + " " + ldap_user[:surname])
              else
                u = User.find_by_uid(ldap_user[:uni_id])
                if !u.has_logged_in_once
                  u.update_attribute(:has_logged_in_once, true)
                  u.update_attribute(:name, ldap_user[:given_name] + " " + ldap_user[:surname])
                end
              end
              
              logmsg "AUTHENTICATED " + uid + " " + ldap_user[:full_name]
              success!(u)
            else
              fail!("Could not log you in!")
            end
          end
        end
          
      end
      
    end
  end
end