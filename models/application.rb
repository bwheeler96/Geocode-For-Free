# encoding: UTF-8

class Application < ActiveRecord::Base

  validates_uniqueness_of :email
  validates_presence_of :email

  before_create do
    self.api_key = Digest::MD5.hexdigest(self.email)
    self.confirmation = Digest::MD5.hexdigest(self.email + Time.now.to_s)
  end

  def confirmed?
    !!self.confirmed_at
  end

  def confirm!
    self.confirmed_at = Time.now.utc
    self.save!
  end

end
