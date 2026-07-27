module Api
  class ReportsController < BaseController
    def create
      report = Report.new(report_params)
      report.user_id = current_profile.id

      if report.save
        render json: report.as_json(only: [:id, :user_id, :post_id, :category, :description, :created_at]),
               status: :created
      else
        render json: { errors: report.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def report_params
      params.permit(:post_id, :category, :description)
    end
  end
end
