class IdentityDocument < ActiveRecord::Base
  has_attached_file :scanned_picture, styles: { large: "700x", thumb: "200x" }

  validates_attachment :scanned_picture,
    presence: true,
    content_type: { content_type: /\A(image\/.*|application\/pdf)\z/ }

  validates :user, presence: true

  belongs_to :user
end
