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
    user=find_by_id(id)
    (user&&user.salt==salt)?user: nil

  end



  def self.build_conn
    conn=LDAP::Conn.new(@@host,@@port)
    conn.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3)
    conn.set_option(LDAP::LDAP_OPT_REFERRALS, 0)
    conn
  end



  def self.build_bind_conn
    conn=build_conn
    conn.bind(@@username,@@password)
    conn

  end

  def self.find_by_id(id)
    return bound_search("uSNCreated",id).first
  end



  def self.find_by_name(name)
    return bound_search("displayName",name).first
  end



  def self.find_by_mail(email)
    return bound_search("mail",email).first
  end



  def self.find_users_by_department(dep)
    return bound_search("department",dep)
  end

  private

  def self.search(conn,query)
    result=conn.search2(@@dn,LDAP::LDAP_SCOPE_SUBTREE,query,Ldap_attributes.values)
    result.inject([]) do |li,item|
      li<< User.new(*(Ldap_attributes.values.collect{|value| get_value(item[value])}))
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
    m.length>1 ? m : m.first
  end
end