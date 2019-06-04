class CreateSupraMunicipalities < ActiveRecord::Migration[5.0]
  def change
    create_table :supra_municipalities do |t|
      t.string :name

      t.timestamps
    end

    create_join_table :catalan_towns, :supra_municipalities do |t|
      t.index [:catalan_town_id, :supra_municipality_id], name: :index_catalan_towns_supra_municipalities
    end
  end
end
