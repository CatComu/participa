module OnlineVerifications
  class Document < ApplicationRecord
    has_attached_file :scanned_picture, styles: { thumb: "x200" }

    validates_attachment :scanned_picture,
                         presence: true,
                         content_type: { content_type: /\A(image\/.*|application\/pdf)\z/ }

    validates :upload, presence: true

    belongs_to :upload

    def pdf?
      scanned_picture_content_type == "application/pdf"
    end

    def image?
      scanned_picture_content_type =~ /\Aimage\/.*\z/
    end
  end
end
