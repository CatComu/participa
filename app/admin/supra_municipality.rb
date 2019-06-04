# frozen_string_literal: true

ActiveAdmin.register SupraMunicipality do
  menu parent: "Users"

  member_action :add_municipality, method: :get
  member_action :save_municipality, method: :patch, if: -> { can? :manage, SupraMunicipality }
  member_action :remove_municipality, method: :delete, if: -> { can? :manage, SupraMunicipality }

  controller do
    def add_municipality
      @supra_municipality = SupraMunicipality.find(params[:id])
    end

    def save_municipality
      @supra_municipality = SupraMunicipality.find(params[:id])
      @municipality = CatalanTown.find(params[:supra_municipality][:municipality_ids])
      @supra_municipality.municipalities << @municipality
      flash[:notice] = t("supra_municipality.saved", scope: "activerecord.attributes")
      redirect_to action: :show
    end

    def remove_municipality
      supra_municipality = SupraMunicipality.find(params[:id])
      municipality = CatalanTown.find(params[:municipality_id])
      supra_municipality.municipalities.delete(municipality)
      flash[:notice] = t("supra_municipality.deleted", scope: "activerecord.attributes")
      redirect_to action: :show
    end
  end

  index do
    id_column
    column :name
    actions
  end

  show do
    attributes_table do
      row :name
    end

    panel "#{t('catalan_town.other', count: supra_municipality.municipalities.count, scope: "activerecord.models")}" do
      header_action link_to t("supra_municipality.add_municipality", scope: "activerecord.attributes"), add_municipality_admin_supra_municipality_path(supra_municipality)
      if supra_municipality.municipalities.any?
        table_for supra_municipality.municipalities do
          column(t('supra_municipality.municipality', scope: 'activerecord.attributes')) { |municipality| municipality.name }
          column do |municipality|
            link_to t("supra_municipality.remove", scope: "activerecord.attributes"),
              remove_municipality_admin_supra_municipality_path(
                supra_municipality,
                municipality_id: municipality.id),
              method: :delete, data: { confirm: "are you sure?" }
          end
        end
      end
    end
  end
end
