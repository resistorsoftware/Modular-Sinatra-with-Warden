class User < ActiveRecord::Base
  include BCrypt
  attr_accessible :firstname, :lastname, :email, :password, :active, :admin
  validates_uniqueness_of :email, :message => "Email account is already registered."
  
  belongs_to :vendor
  
  def self.authenticate(email, password)
    @user = User.where(:email => email)
    return 'email' if @user.empty?                            # someone is up to no good, we did not even find their email address 
    @password = BCrypt::Password.new(@user.first.password)    # at least we found a user with an email address, so let's check their password now... 
    @password == password ? @user.first : 'password'          # if the password was found to be good, we can return the user object we found by email address
  end
  
  def to_h
    { 
      :firstname => firstname,
      :lastname => lastname,
      :email => email,
      :created_at => created_at
    }
  end
  
  def self.get(id)
    User.find(id)
  end
end