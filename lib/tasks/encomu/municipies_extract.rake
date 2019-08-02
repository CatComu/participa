namespace :encomu do
  desc "[encomu] Generate SQL commands for lists creation in Sendy"
  task :generate_sendy_lists => :environment do
    require 'municipy_extractor'

    sendy_lists = SendyListsUpdater.new Rails.application.secrets.sendy["appID"], Rails.application.secrets.sendy["userID"]

    sendy_lists.add_list "A - España", "m_"
    sendy_lists.add_list "A - Extranjero", "e_"

    #  50 provinces + 2 autonomous cities
    (01..52).each { |n| sendy_province "%02d" % n, sendy_lists }

    sendy_lists.close
  end

  desc "[encomu] Extract municipies information from INE"
  # http://www.ine.es/jaxi/menu.do?type=pcaxis&path=/t20/e245/codmun&file=inebase
  #    Relación de municipios y códigos por provincias a 01-01-2014
  #    http://www.ine.es/daco/daco42/codmun/codmunmapa.htm
  #
  # Extract municipies for a given province in the Carmen format,
  # * db/iso_data/base/world/es/#{prefix}.yml
  # * config/locales/carmen/es/#{prefix}.yml
  # where prefix is Carmen internal code, eg: "vi" for Alava
  #
  task :municipies_extract => :environment do
    require 'municipy_extractor'

    #  50 provinces + 2 autonomous cities
    (01..52).each { |n| carmen_province "%02d" % n }
  end

  def sendy_province number_province, sendy_lists
    #  Given a number (first column) like 01 or 52 parse the CSV file and
    # extract all the municipalities for that province.

    municipy_extractor = MunicipyExtractor.new(number_province)

    prefix = municipy_extractor.prefix
    municipies = municipy_extractor.municipies

    province_name = Carmen::Country.coded("ES").subregions.coded(prefix).name
    sendy_lists.add_list "B - #{province_name}", "m_#{number_province}"

    municipies.each do |mun|
      c = mun[0]
      sendy_lists.add_list "C - #{province_name} - #{mun[1]}", "#{c.downcase}"
    end
  end

  def carmen_province number_province
    #  Given a number (first column) like 01 or 52 parse the CSV file and
    # extract all the municipalities for that province.
    MunicipyExtractor.new(number_province).extract
  end

  class SendyListsUpdater
    def initialize(appID, userID)
      @appID = appID
      @userID = userID

      FileUtils.mkdir_p("tmp/sendy") unless File.directory?("tmp/sendy")
      @sendy_lists_file = File.open("tmp/sendy/update_lists.sql", 'w')

      @INSERT_TEMPLATE = ERB.new <<~QUERY
        INSERT INTO lists (app, userID, name, thankyou_message, goodbye_message, confirmation_email, custom_fields)
        SELECT <%= @appID %>, <%= @userID %>, "<%= name %> - <%= code %>", <%= @EMPTY_PAGE %>, <%= @EMPTY_PAGE %>, <%= @EMPTY_PAGE %>, NULL
        FROM lists WHERE NOT EXISTS(
          SELECT * FROM lists l WHERE l.name LIKE '% - <%= code %>'
        ) LIMIT 1;
      QUERY
      @EMPTY_PAGE = "'<html><head></head><body></body></html>'"
    end

    def add_list name, code
      @sendy_lists_file.puts @INSERT_TEMPLATE.result(binding)
    end

    def close
      @sendy_lists_file.puts("SELECT id FROM lists WHERE app = #{@appID} and userID = #{@userID};")
      @sendy_lists_file.close
    end
  end
end
