class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  protected
  def downcase_email
    email.downcase!
  end
end
