module V1
  class StockPricesController < ApplicationController
    before_action :authorize_request

    def index
      client = LatestStockPrice::Client.new

      if truthy?(params[:all])
        response = client.price_all
      elsif params[:indices].present?
        indices = params[:indices]
        if indices.is_a?(Array) || indices.to_s.include?(",")
          response = client.prices(indices)
        else
          response = client.price(indices)
        end
      else
        return render json: { error: "Missing parameter: provide indices or all=true" }, status: :bad_request
      end

      render json: parse_response(response)
    rescue StandardError => e
      render json: { error: e.message }, status: :internal_server_error
    end

    private

    def truthy?(value)
      %w[true 1 yes y].include?(value.to_s.downcase)
    end

    def parse_response(response)
      if response.respond_to?(:parsed_response)
        response.parsed_response
      else
        response
      end
    end
  end
end
