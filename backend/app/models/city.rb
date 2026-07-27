class City < ApplicationRecord
  has_many :profiles, foreign_key: :location_city_id, inverse_of: :city, dependent: nil
end
