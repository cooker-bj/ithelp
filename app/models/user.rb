require 'ldap'

   # following attributes are used for query domain attributes and they can be added with more attributes
   Ldap_attributes={:id=>'uSNCreated',:name=>'displayName',:department=>'department',:email=>'mail',:salt=>'msExchMailboxGuid'}


class User<Struct.new(*(Ldap_attributes.keys))
  #follwoing class variables are used to make connection with domain server

  @@host=Rails.configuration.ldap_config['host']
  @@port=Rails.configuration.ldap_config['port']
  @@dn=Rails.configuration.ldap_config['dn']
  @@username=Rails.configuration.ldap_config['username']
  @@password=Rails.configuration.ldap_config['password']




  def self.authenticate(login,password)
    begin
      conn=build_conn
      conn.bind(login,password)
      ActiveRecord::Base.logger.info "conn bound"
      user= login_search(conn,login)
    rescue => e
      ActiveRecord::Base.logger.info "authenticated error:authenticate #{e}"
      user= nil
    ensure
      conn.unbind unless conn.nil?
      user
    end

  end


  def self.authenticate_with_salt(id,salt)
    user=find(id)
    (user&&user.salt==salt)?user: nil

  end



   def self.find(id)
    return bound_search(Ldap_attributes[:id],id).first
  end



  def self.method_missing(method,*args,&block)
    if (m=/^find_by_(\w+)$/.match(method.to_s)) && (Ldap_attributes.has_key?(m[1].to_sym))
         self.send :define_singleton_method,method do |*args|
           bound_search(Ldap_attributes[m[1].to_sym],args[0]).first
      end
      send(method,args)
    elsif   (m=/^find_users_by_(\w+)$/.match(method.to_s)) && (Ldap_attributes.has_key?(m[1].to_sym) )
      self.send :define_singleton_method,method do |*args|
        bound_search(Ldap_attributes[m[1].to_sym],args[0])
      end
      send(method,args)
    else
      super
    end


  end
  private
  def self.build_conn
    conn=LDAP::Conn.new(@@host,@@port)
    conn.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3)
    conn.set_option(LDAP::LDAP_OPT_REFERRALS, 0)
    conn
  end

  def self.singular?(str)
    str.pluralize!=str and str.singularize==str
  end



  def self.search(conn,query)
    result=conn.search2(@@dn,LDAP::LDAP_SCOPE_SUBTREE,query,Ldap_attributes.values)
    result.inject([]) do |li,item|
      li<< User.new(*(Ldap_attributes.collect{|key,value| singular?(key.to_s) ? get_value(item[value]).first : get_value(item[value])}))
    end
  end



  def self.login_search(conn,myvalue)
     search(conn,"(|(mail=#{myvalue})(userPrincipalName=#{myvalue}))").first
  end



  def self.bound_search(mykey,myvalue)
    bound_conn=build_conn
    result=nil
    begin
      bound_conn.bind(@@username,@@password)  do |myconn|
        result=search(myconn,"#{mykey}=#{myvalue}")
      end
    rescue =>e
      ActiveRecord::Base.logger.info "bound_search error: #{e} :error_end"
      result=[]
    end
    result
  end



  def self.get_value(v)
    m=v.collect{|v|v.force_encoding("UTF-8")}

  end
end