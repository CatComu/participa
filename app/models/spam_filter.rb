class SpamFilter < ApplicationRecord
  scope :active, -> { where(active:true) }

  after_initialize do |filter|
    if persisted?
      @proc = eval("Proc.new { |user, data| #{filter.code} }")
      @data = filter.data.split("\r\n")
    end
  end

  def process user
    @proc.call user, @data
  end


  def query_count
    User.verified_online.unverified_presentially.where(query).count
  end

  def run offset, limit
    matches = []
    User.verified_online.unverified_presentially.where(query).offset(offset).limit(limit).each do |user|
      matches << user if @proc.call user, @data
    end
    matches
  end

  def self.any? user
    SpamFilter.active.each do |filter|
      return filter.name if filter.process user
    end
    false
  end
end
