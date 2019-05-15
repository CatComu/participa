module Api
  class V1Controller < ApplicationController
    skip_before_action :verify_authenticity_token

    def gcm_registrate
      NoticeRegistrar.find_or_create_by(gcm_params)
      render json: nil, status: 201
    end

    def gcm_unregister
      registration = NoticeRegistrar.find(:registration_id)
      if registration
        registration.destroy
        render json: nil, status: 200
      else
        render json: nil, status: 404
      end
    end

    def get_location
      @data = params[:type].camelize.constantize.all
      render json: @data.select(:id, :name)
    end

    private

    def gcm_params
      params.require(:v1).permit(:registration_id)
    end
  end
end
