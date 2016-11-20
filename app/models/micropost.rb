class Micropost < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true
  validates :picture, presence: true
  validate :picture_size

  def next
    self.class.where("id > ?", id).first
  end

  def previous
    self.class.where("id < ?", id).last
  end

  private
  def picture_size
    if picture.size > 5.megabytes
      errors.add :picture, I18n.t("micropost.uploader.validation")
    end
  end
end
