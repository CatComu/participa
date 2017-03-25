class Page < ApplicationRecord

  validates :id_form, presence: true, :numericality => { :greater_than_or_equal_to => 0 }
  validates :slug, uniqueness: { case_sensitive: false, scope: :deleted_at }, presence: true
  validates :title, presence: true

  acts_as_paranoid

end
