class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  scope :order_by_creation_time, -> {order created_at: :desc}

  protected
  def downcase_email
    email.downcase!
  end
end
