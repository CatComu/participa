# frozen_string_literal: true

#
# Writes INE information of a Spanish province to a set of files understood by
# carmen gem
#
class MunicipyExtractor
  def initialize(ine_code)
    @ine_code = ine_code
  end

  # http://www.ine.es/jaxi/menu.do?type=pcaxis&path=/t20/e245/codmun&file=inebase
  # Relacion de provincias con sus codigos
  # http://www.ine.es/daco/daco42/codmun/cod_provincia.htm
  #
  def prefix
    case @ine_code
    when "01" then "VI"
    when "02" then "AB"
    when "03" then "A"
    when "04" then "AL"
    when "05" then "AV"
    when "06" then "BA"
    when "07" then "IB"
    when "08" then "B"
    when "09" then "BU"
    when "10" then "CC"
    when "11" then "CA"
    when "12" then "CS"
    when "13" then "CR"
    when "14" then "CO"
    when "15" then "C"
    when "16" then "CU"
    when "17" then "GI"
    when "18" then "GR"
    when "19" then "GU"
    when "20" then "SS"
    when "21" then "H"
    when "22" then "HU"
    when "23" then "J"
    when "24" then "LE"
    when "25" then "L"
    when "26" then "LO"
    when "27" then "LU"
    when "28" then "M"
    when "29" then "MA"
    when "30" then "MU"
    when "31" then "NA"
    when "32" then "OR"
    when "33" then "O"
    when "34" then "P"
    when "35" then "GC"
    when "36" then "PO"
    when "37" then "SA"
    when "38" then "TF"
    when "39" then "S"
    when "40" then "SG"
    when "41" then "SE"
    when "42" then "SO"
    when "43" then "T"
    when "44" then "TE"
    when "45" then "TO"
    when "46" then "V"
    when "47" then "VA"
    when "48" then "BI"
    when "49" then "ZA"
    when "50" then "Z"
    when "51" then "CE"
    when "52" then "ML"
    end
  end

  # Extract all municipies on a list like
  # [ ["m_01_001_4", "Alegria-Dulantzi"], ["m_01_002_9", "Amurrio"], ...]
  #
  def municipies
    municipies = []
    raw = CSV.read("db/ine/16codmun.csv")
    raw.each do |a|
      if a[0] == @ine_code
        municipies << ["m_#{a[0]}_#{a[1]}_#{a[2]}", a[3]]
      end
    end
    municipies
  end

  def extract
    File.open(data_filename, "w") { |f| f.write(data_file_content) }
    File.open(i18n_filename, "w") { |f| f.write(i18n_file_content) }
  end

  private

  def province
    prefix.downcase
  end

  def data_filename
    File.join(base_data_dirname, "#{province}.yml")
  end

  def base_data_dirname
    "db/iso_data/base/world/es"
  end

  def i18n_filename
    File.join(base_i18n_dirname, "#{province}.yml")
  end

  def base_i18n_dirname
    "config/locales/carmen/es"
  end

  def data_file_content
    "---\n#{municipies_data_chunk.join}"
  end

  def i18n_file_content
    common = <<~YAML
      ---
      es:
        world:
          es:
            #{province}:
    YAML

    common + municipies_i18n_chunk.join.gsub(/^/, " " * 8)
  end

  def municipies_data_chunk
    municipies.map do |m|
      <<~YAML
        - code: #{m[0].downcase}
          type: municipality
      YAML
    end
  end

  def municipies_i18n_chunk
    municipies.map do |m|
      <<~YAML
        #{m[0].downcase}:
          name: "#{m[1]}"
      YAML
    end
  end
end
