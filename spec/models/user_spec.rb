require 'spec_helper'
require 'ldap'
describe User do
  before(:each) do
    LDAP::Conn.any_instance.stub(:bind).with('david','security').and_return(LDAP::Conn.new)
    LDAP::Conn.any_instance.stub(:bind).with("ittest01@company.com","Abc$1234").and_yield( LDAP::Conn.new)

    LDAP::Conn.any_instance.stub(:unbind)
    LDAP::Conn.any_instance.stub(:search2).and_return([{'uSNCreated'=>['1101'],'displayName'=>['david'],'department'=>['IT department'],'mail'=>['test@test.com'],'msExchMailboxGuid'=>['3wsr3s']}])
  end
  describe 'authenticate' do
    it "return user when user exists and password is correct"  do
      username="david"
      password="security"
      user=User.authenticate(username,password)
      user.should_not  be_nil
      user.name.should==username
    end

    it "return nil when user or password is not correct"  do
      username="david"
      password="wrongsecurity"
      LDAP::Conn.any_instance.stub(:bind).with('david','wrongsecurity').and_raise("password is invalid")
      user=User.authenticate(username,password)
      user.should  be_nil
    end
  end


  describe 'authenticate_with_salt' do
    it "return user when id and salt matched"  do
      user=User.authenticate_with_salt('1101','3wsr3s')
      user.should_not be_nil and user.name.should=='david'
    end
  end



  describe 'bound_search' do
    it "return an arry of users" do
      users=User.send(:bound_search,"uSNCreated",'1101')
      users.should_not be_nil or be_empty
      users.first.name='david'

    end

  end

  describe "search" do
    it "return an array of users" do
      conn=LDAP::Conn.new

      users=User.send(:search,conn,"uSNCreated=1101")
      users.should_not be_nil
      users.first.name='david'
    end
  end


end
