class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  scope :order_by_creation_time, -> {order created_at: :desc}
  scope :order_by_updated_time, -> {order updated_at: :desc}
end
