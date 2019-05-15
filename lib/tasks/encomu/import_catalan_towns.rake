namespace :encomu do
  def normalize(code)
    full_width = format("%06d", code)

    "m_#{full_width[0..1]}_#{full_width[2..4]}_#{full_width[5]}"
  end

  desc "[encomu] Imports Catalonia geographical information from a CSV"
  task :import_catalan_towns => :environment do
    CSV.foreach('db/idescat/catalan_town_info.tsv', col_sep: "\t",
                                                    headers: true,
                                                    converters: :all) do |row|
      row["code"] = normalize(row["code"])

      CatalanTown.create!(row.to_hash)
    end
  end

  task import_catalan_models: :environment do
    CSV.foreach("db/idescat/catalan_town_info.tsv",
                col_sep: "\t",
                headers: true,
                converters: :all) do |row|
                  province = Province.where(code: row["provice_code"], name: row["province_name"]).first_or_create
                  vegueria = Vegueria.where(code: row["vegueria_code"], name: row["vegueria_name"]).first_or_create
                  province.veguerias << vegueria unless province.veguerias.exists?(vegueria.id)
                  district = District.where(code: row["comarca_code"], name: row["comarca_name"]).first_or_create
                  province.districts << district unless province.districts.exists?(district.id)
                  vegueria.districts << district unless vegueria.districts.exists?(district.id)
                end
  end
end
