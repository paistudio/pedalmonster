module Api
  class CitiesController < BaseController
    def index
      render json: City.order(:name).as_json(only: [:id, :name, :province, :lat, :lng])
    end
  end
end
