# frozen_string_literal: true

class SpacesController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize! :show, :spaces
  end

  def download_census
    authorize! :show, :spaces
    position = current_user.positions.find(params[:position])
    if position&.downloader?
      send_data to_csv(position.territory_users),
                type: "text/csv; charset=utf-8",
                filename: "census-#{position.territory.name.parameterize}.csv"
    else
      flash[:notice] = "Can't download census"
      render :index
    end
  end

  private

  def to_csv(users)
    attributes = %w[first_name last_name born_at postal_code email]

    CSV.generate(headers: true) do |csv|
      csv << attributes

      users.each do |user|
        csv << attributes.map { |attr| user.send(attr) }
      end
    end
  end
end
