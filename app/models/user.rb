class User < ApplicationRecord
  include Verificable

  apply_simple_captcha

  include FlagShihTzu

  include Rails.application.routes.url_helpers
  require 'phone'

  has_flags 1 => :banned,
            2 => :superadmin,
            4 => :finances_admin,
            6 => :impulsa_author,
            7 => :impulsa_admin,
            check_for_column: false

  # Include default devise modules. Others available are:
  # :omniauthable
  devise :database_authenticatable, :registerable, :confirmable, :timeoutable,
         :recoverable, :rememberable, :trackable, :lockable

  before_save :before_save

  acts_as_paranoid
  has_paper_trail

  has_many :votes, dependent: :destroy
  has_many :supports, dependent: :destroy
  has_one :collaboration, dependent: :destroy
  has_and_belongs_to_many :participation_team
  has_many :microcredit_loans

  belongs_to :catalan_town, foreign_key: :town, primary_key: :code

  extend Enumerize
  enumerize :gender_identity,
            in: %i(cis_man cis_woman trans_man trans_woman fluid)

  validates :password, presence: true, confirmation: true, if: :password_required?
  validates :password, length: { within: 6..128 }, allow_blank: true

  validates :email, presence: true, confirmation: { case_sensitive: false }, if: :email_required?
  validates :email, email: true, if: :email_changed?

  validates :first_name, :last_name, :document_type, :document_vatid, presence: true
  validates :postal_code, :born_at, presence: true
  validates :country, inclusion: { in: Carmen::Country.all.map(&:code) }
  validates :province,
            inclusion: { in: proc { |u| u.province_codes }, unless: :in_mini_country? },
            absence: { if: :in_mini_country? }
  validates :town, presence: { if: :in_spain? }, absence: { unless: :in_spain? }
  validates :catalan_town, presence: { if: :in_catalonia? }, absence: { unless: :in_catalonia? }
  validates :terms_of_service, acceptance: true
  validates :age_restriction, acceptance: true
  validates :document_type, inclusion: { in: [1, 2, 3] }, allow_blank: true
  validates :document_vatid, valid_nif: true, if: :is_document_dni?
  validates :document_vatid, valid_nie: true, if: :is_document_nie?
  validates :born_at, date: true, allow_blank: true # gem date_validator
  validates :born_at, inclusion: { in: Date.civil(1900, 1, 1)..Date.current-16.years }, allow_blank: true
  validates :phone, numericality: true, allow_blank: true
  validates :unconfirmed_phone, numericality: true, allow_blank: true

  validates :email, uniqueness: {case_sensitive: false, scope: :deleted_at }, allow_blank: true, if: :email_changed?
  validates :document_vatid, uniqueness: {case_sensitive: false, scope: :deleted_at }
  validates :phone, uniqueness: {scope: :deleted_at}, allow_blank: true, allow_nil: true
  validates :unconfirmed_phone, uniqueness: {scope: :deleted_at}, allow_blank: true, allow_nil: true

  validate :validates_postal_code, if: -> { self.postal_code.present? }
  validate :validates_phone_format, if: -> { self.phone.present? }
  validate :validates_unconfirmed_phone_format, if: -> { self.unconfirmed_phone.present? }
  validate :validates_unconfirmed_phone_uniqueness, if: -> { self.unconfirmed_phone.present? }

  def password_required?
    new_record? || password || password_confirmation
  end

  def email_required?
    new_record?
  end

  def validates_postal_code
    if in_spain?
      if (self.postal_code =~ /^\d{5}$/) != 0
        self.errors.add(:postal_code, :bad_spanish_postal_code_length)
      else
        province = spanish_regions.coded(self.province)
        if province and self.postal_code[0...2] != province.subregions[0].code[2...4]
          self.errors.add(:postal_code, :bad_spanish_postal_code_province)
        end
      end
    end
  end

  def validates_unconfirmed_phone_uniqueness
    if User.confirmed_by_sms.where(phone: self.unconfirmed_phone).exists?
      self.errors.add(:phone, :duplicated_phone)
    end
  end

  def validates_phone_format
    self.errors.add(:phone, :invalid_phone) unless Phoner::Phone.valid?(self.phone)
  end

  def validates_unconfirmed_phone_format
    if in_spain? and not (self.unconfirmed_phone.starts_with?('00346') or self.unconfirmed_phone.starts_with?('00347'))
      self.errors.add(:unconfirmed_phone, :bad_spanish_phone_number)
    elsif !Phoner::Phone.valid?(self.unconfirmed_phone)
      self.errors.add(:unconfirmed_phone, :invalid_phone)
    end
  end

  attr_accessor :sms_user_token_given
  attr_accessor :login

  scope :wants_newsletter, -> {where(wants_newsletter: true)}
  scope :created, -> { where(deleted_at: nil)  }
  scope :deleted, -> { where.not(deleted_at: nil) }
  scope :admins, -> { where(admin: true) }
  scope :unconfirmed_mail, -> { where(confirmed_at: nil)  }
  scope :confirmed_mail, -> { where.not(confirmed_at: nil) }
  scope :signed_in, -> { where.not(sign_in_count: nil) }
  scope :participation_team, -> { includes(:participation_team).where.not(participation_team_at: nil) }
  scope :has_circle, -> { where.not(circle: nil) }

  scope :has_collaboration, -> { joins(:collaboration).where.not(collaborations: { user_id: nil }) }
  scope :has_collaboration_credit_card, -> { joins(:collaboration).where(collaborations: { payment_type: 1 }) }
  scope :has_collaboration_bank_national, -> { joins(:collaboration).where(collaborations: { payment_type: 2 }) }
  scope :has_collaboration_bank_international, -> { joins(:collaboration).where(collaborations: { payment_type: 3 }) }

  ransacker :vote_province, formatter: proc { |value|
    spanish_subregion_for(value).subregions.map {|r| r.code }
  } do |parent|
    parent.table[:vote_town]
  end

  ransacker :vote_autonomy, formatter: proc { |value|
    Podemos::GeoExtra::AUTONOMIES.map { |k,v| spanish_subregion_for(k).subregions.map {|r| r.code } if v[0]==value } .compact.flatten
  } do |parent|
    parent.table[:vote_town]
  end

  ransacker :vote_island, formatter: proc { |value|
    Podemos::GeoExtra::ISLANDS.map {|k,v| k if v[0]==value} .compact
  } do |parent|
    parent.table[:vote_town]
  end

  DOCUMENTS_TYPE = [["DNI", 1], ["NIE", 2], ["Pasaporte", 3]]

  # Based on
  # https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign-in-using-their-username-or-email-address
  # Check if login is email or document_vatid to use the DB indexes
  #
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      login_key = login.downcase.include?("@") ? "email" : "document_vatid"
      where(conditions).where(["lower(#{login_key}) = :value", { :value => login.downcase }]).take
    else
      where(conditions).first
    end
  end

  def get_or_create_vote election_id
    v = Vote.new({election_id: election_id, user_id: self.id})
    if Vote.find_by_voter_id( v.generate_message )
      return v
    else
      v.save
      return v
    end
  end

  def previous_user(force_refresh=false)
    remove_instance_variable :@previous_user if force_refresh and @previous_user
    @previous_user ||= User.with_deleted.where("lower(email) = ?", self.email.downcase).where("deleted_at > ?", 3.months.ago).last ||
                      User.with_deleted.where("lower(document_vatid) = ?", self.document_vatid.downcase).where("deleted_at > ?", 3.months.ago).last
                      User.with_deleted.where("phone = ?", self.phone).where("deleted_at > ?", 3.months.ago).last
    @previous_user
  end

  def apply_previous_user_vote_location
    if self.previous_user(true) and self.previous_user.has_verified_vote_town? and (self.vote_town != self.previous_user.vote_town)
      self.update(vote_town: self.previous_user.vote_town)
      true
    else
      false
    end
  end

  def document_vatid=(val)
    self[:document_vatid] = val.upcase.strip
  end

  def is_document_dni?
    self.document_type == 1
  end

  def is_document_nie?
    self.document_type == 2
  end

  def is_passport?
    self.document_type == 3
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def full_name_and_id
    "#{self.full_name} (#{self.document_type_name} #{self.document_vatid})"
  end

  def full_address
    "#{self.address}, #{self.town_name}, #{self.province_name}, CP #{self.postal_code}, #{self.country_name}"
  end

  def is_admin?
    self.admin
  end

  def self.blocked_provinces
    Rails.application.secrets.users["blocked_provinces"]
  end

  #
  # Region in Spain whose code matches xx in a +code+ of the form ..xx.*
  #
  def self.spanish_subregion_for(code)
    spanish_regions[code[2..3].to_i-1]
  end

  delegate :spanish_subregion_for, to: :class

  def can_change_vote_location?
    # use database version if vote_town has changed
    !self.has_verified_vote_town? or !self.persisted? or
      (Rails.application.secrets.users["allows_location_change"] and !User.blocked_provinces.member?(vote_province_persisted))
  end

  def phone_normalize(phone_number, country_iso=nil)
    Phoner::Country.load
    cc = country_iso.nil? ? self.country : country_iso
    country = Phoner::Country.find_by_country_isocode(cc.downcase)
    phoner = Phoner::Phone.parse(phone_number, :country_code => country.country_code)
    phoner.nil? ? nil : "00" + phoner.country_code + phoner.area_code + phoner.number
  end

  def unconfirmed_phone_number
    Phoner::Country.load
    country = Phoner::Country.find_by_country_isocode(self.country.downcase)
    if Phoner::Phone.valid?(self.unconfirmed_phone)
      phoner = Phoner::Phone.parse(self.unconfirmed_phone, :country_code => country.country_code)
      phoner.area_code + phoner.number
    else
      nil
    end
  end

  def phone_prefix
    if self.country.length < 3
      Phoner::Country.load
      begin
        Phoner::Country.find_by_country_isocode(self.country.downcase).country_code
      rescue
        "34"
      end
    else
      "34"
    end
  end

  def phone_country_name
    if Phoner::Phone.valid?(self.phone)
      Phoner::Country.load
      country_code = Phoner::Phone.parse(self.phone).country_code
      Carmen::Country.coded(Phoner::Country.find_by_country_code(country_code).char_3_code).name
    else
      Carmen::Country.coded(self.country).name
    end
  end

  def phone_no_prefix
    phone = Phoner::Phone.parse(self.phone)
    phone.area_code + phone.number
  end

  def document_type_name
    User::DOCUMENTS_TYPE.select{|v| v[1] == self.document_type }[0][0]
  end

  def self.spanish_regions
    Carmen::Country.coded("ES").subregions
  end

  delegate :spanish_regions, to: :class

  def in_spain?
    self.country=="ES"
  end

  def in_catalonia?
    %w(B T L GI).include?(province) && in_spain?
  end

  def in_mini_country?
    provinces.empty?
  end

  def country_name
    _country ? _country.name : ""
  end

  def province_name
    _province ? _province.name : ""
  end

  delegate :comarca_code, :comarca_name, :vegueria_code, :vegueria_name, :amb,
           to: :catalan_town,
           allow_nil: true

  def province_code
    self.in_spain? && _province ? "p_%02d" % + _province.index : ""
  end

  def catalonia_resident
    @catalonia_resident ||= in_catalonia?
  end

  def catalonia_resident=(value)
    @catalonia_resident = value == '1' ? true : false
  end

  def town_name
    _town ? _town.name : ""
  end

  def town_idescat_code
    town ? town.gsub(/[m_]/, '').to_i : ""
  end

  def autonomy_code
    if self.in_spain? and _province
      Podemos::GeoExtra::AUTONOMIES[self.province_code][0]
    else
      ""
    end
  end

  def autonomy_name
    if self.in_spain? and _province
      Podemos::GeoExtra::AUTONOMIES[self.province_code][1]
    else
      ""
    end
  end

  def island_code
    if self.in_spanish_island?
      Podemos::GeoExtra::ISLANDS[self.town][0]
    else
      ""
    end
  end

  def island_name
    if self.in_spanish_island?
      Podemos::GeoExtra::ISLANDS[self.town][1]
    else
      ""
    end
  end

  def in_spanish_island?
    (self.in_spain? and Podemos::GeoExtra::ISLANDS.has_key? self.town) or false
  end

  def vote_in_spanish_island?
    (Podemos::GeoExtra::ISLANDS.has_key? self.vote_town) or false
  end

  def has_vote_town?
    not self.vote_town.nil? and not self.vote_town.empty?
  end

  def has_verified_vote_town?
    self.has_vote_town? and self.vote_town[0]=="m"
  end

  def vote_autonomy_code
    if _vote_province
      Podemos::GeoExtra::AUTONOMIES[self.vote_province_code][0]
    else
      ""
    end
  end

  def vote_autonomy_name
    if _vote_province
      Podemos::GeoExtra::AUTONOMIES[self.vote_province_code][1]
    else
      ""
    end
  end

  def vote_town_name
    _vote_town ? _vote_town.name : ""
  end

  def vote_province_persisted
    prov = _vote_province
    if self.vote_town_changed?
      begin
        previous_province = spanish_subregion_for(self.vote_town_was)
        prov = previous_province if previous_province
      rescue
      end
    end

    prov ? prov.code : ""
  end

  def vote_province
    _vote_province ? _vote_province.code : ""
  end

  def vote_province= value
    if value.nil? or value.empty? or value == "-"
      self.vote_town = nil
    else
      prefix = "m_%02d_"% (spanish_regions.coded(value).index)
      if self.vote_town.nil? or not self.vote_town.starts_with? prefix then
        self.vote_town = prefix
      end
    end
  end

  def vote_province_code
    _vote_province ? "p_%02d" % + _vote_province.index : ""
  end

  def vote_province_name
    _vote_province ? _vote_province.name : ""
  end

  def vote_island_code
    if self.vote_in_spanish_island?
      Podemos::GeoExtra::ISLANDS[self.vote_town][0]
    else
      ""
    end
  end

  def vote_island_name
    if self.vote_in_spanish_island?
      Podemos::GeoExtra::ISLANDS[self.vote_town][1]
    else
      ""
    end
  end

  def vote_autonomy_numeric
    _vote_province ? self.vote_autonomy_code[2..-1] : "-"
  end

  def vote_province_numeric
    _vote_province ? "%02d" % + _vote_province.index : ""
  end

  def vote_town_numeric
    _vote_town ? _vote_town.code.split("_")[1,3].join : ""
  end

  def vote_island_numeric
    self.vote_in_spanish_island? ? self.vote_island_code[2..-1] : ""
  end

  def self.ban_users ids, value
    t = User.arel_table
    User.where(id:ids).where(t[:admin].eq(false).or(t[:admin].eq(nil))).update_all User.set_flag_sql(:banned, value)
  end

  def before_save
    # Spanish users can't set a different town for vote, except when blocked
    if self.in_spain? and self.can_change_vote_location?
      self.vote_town = self.town
    end
  end

  def admin_permalink
    admin_user_path(self)
  end

  def _country
    Carmen::Country.coded(self.country)
  end

  def _province
    provinces.coded(self.province) if self.province and not provinces.empty?
  end

  def _town
    towns.coded(self.town) if self.town and not towns.empty?
  end

  def _vote_province
    if self.has_vote_town?
      spanish_subregion_for(self.vote_town)
    elsif in_spain?
      _province
    end
  end

  def _vote_town
    if self.has_vote_town?
      _vote_province.subregions.coded(self.vote_town)
    elsif in_spain?
      _town
    end
  end

  def provinces
    _country ? _country.subregions : []
  end

  def towns
    _province ? _province.subregions : []
  end

  def province_codes
    provinces.map(&:code)
  end

  def can_request_sms_check?
    Time.zone.now > next_sms_check_request_at
  end
  
  def can_check_sms_check?
    sms_check_at.present? && (Time.zone.now < (sms_check_at + eval(Rails.application.secrets.users["sms_check_valid_interval"])))
  end

  def next_sms_check_request_at
    if sms_check_at.present?
      sms_check_at + eval(Rails.application.secrets.users["sms_check_request_interval"])
    else
      Time.zone.now - 1.second
    end
  end
  
  def send_sms_check!
    require 'sms'
    if can_request_sms_check?
      self.update_attribute(:sms_check_at, Time.zone.now)
      SMS::Sender.send_message(self.phone, self.sms_check_token)
      true
    else
      false
    end
  end

  def valid_sms_check? value
    sms_check_at and value.upcase == sms_check_token
  end

  def sms_check_token
    Digest::SHA1.digest("#{sms_check_at}#{id}#{Rails.application.secrets.users['sms_secret_key'] }")[0..3].codepoints.map { |c| "%02X" % c }.join if sms_check_at
  end
end
