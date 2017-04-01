module OnlineVerifications
  class Upload < Event
    has_many :documents, inverse_of: :upload
    accepts_nested_attributes_for :documents, reject_if: :all_blank

    def pdfs
      documents.select(&:pdf?)
    end

    def images
      documents.select(&:image?)
    end

  end
end
