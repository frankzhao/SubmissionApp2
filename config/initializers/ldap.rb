require 'anu-ldap'
module Devise
  module Strategies
    class Ldap < Base

      def valid?
        params[:uid] != "u0000000"
      end 

      def authenticate!
        # Don't use LDAP when logging in as admin
        if params[:uid] == "u0000000"
          fail()
          return
        else
          # Use LDAP
          if params[:user] && params[:user][:uid]
            uid = params[:user][:uid]
            pass = params[:user][:password]

            if AnuLdap.authenticate(uid, pass)
              ldap_user = AnuLdap.find_by_uni_id(uid)

              # Create and update first time users
              if not User.find_by_uid(ldap_user[:uni_id])
                fail()
                return
              else
                u = User.find_by_uid(ldap_user[:uni_id])
                if !u.has_logged_in_once
                  u.update_attribute(:has_logged_in_once, true)
                  u.update_attribute(:firstname, ldap_user[:given_name])
                  u.update_attribute(:surname,   ldap_user[:surname])
                  u.update_attribute(:full_name, ldap_user[:full_name])
                end
              end

              u.password = pass
              u.save

              logmsg "AUTHENTICATED " + uid + " " + ldap_user[:full_name]
              success!(u)
            else
              fail("Could not log you in!")
            end
          end
        end

      end

    end
  end
end
