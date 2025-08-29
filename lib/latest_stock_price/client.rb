require "httparty"

module LatestStockPrice
  class Client
    include HTTParty

    base_uri "https://latest-stock-price.p.rapidapi.com"

    def initialize
      @api_key = fetch_api_key!
      @options = {
        headers: {
          "X-RapidAPI-Host" => "latest-stock-price.p.rapidapi.com",
          "X-RapidAPI-Key" => @api_key,
          "Accept" => "application/json"
        }
      }
    end

    def price(indices)
      HTTParty.get("#{self.class.base_uri}/price", query: { Indices: indices }, **@options)
    end

    def prices(indices_list)
      indices_param = indices_list.is_a?(Array) ? indices_list.join(",") : indices_list.to_s
      HTTParty.get("#{self.class.base_uri}/prices", query: { Indices: indices_param }, **@options)
    end

    def price_all
      HTTParty.get("#{self.class.base_uri}/price_all", **@options)
    end

    private

    def fetch_api_key!
      key = if defined?(Rails) && Rails.application.credentials.dig(:latest_stock_price, :rapidapi_key).present?
              Rails.application.credentials.dig(:latest_stock_price, :rapidapi_key)
      else
              ENV["RAPIDAPI_KEY"]
      end

      raise "Missing RapidAPI key for Latest Stock Price (set credentials.latest_stock_price.rapidapi_key or ENV['RAPIDAPI_KEY'])" if key.to_s.strip.empty?
      key
    end
  end
end
