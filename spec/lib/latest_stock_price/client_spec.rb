require "rails_helper"

RSpec.describe LatestStockPrice::Client do
  let(:api_key) { "test-key" }
  let(:headers) do
    {
      "X-RapidAPI-Host" => "latest-stock-price.p.rapidapi.com",
      "X-RapidAPI-Key" => Rails.application.credentials.dig(:latest_stock_price, :rapidapi_key),
      "Accept" => "application/json"
    }
  end

  before do
    allow(ENV).to receive(:[]).with("RAPIDAPI_KEY").and_return(api_key)
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("RAPIDAPI_KEY").and_return(api_key)
  end

  describe "#price" do
    it "calls HTTParty.get with correct URL, query, and headers" do
      client = described_class.new
      expected_url = "https://latest-stock-price.p.rapidapi.com/price"
      expected_query = { Indices: "NIFTY 50" }

      expect(HTTParty).to receive(:get).with(
        expected_url,
        hash_including(query: expected_query, headers: headers)
      ).and_return(double(parsed_response: [ { "symbol" => "NIFTY" } ]))

      response = client.price("NIFTY 50")
      expect(response).to respond_to(:parsed_response)
    end
  end

  describe "#prices" do
    it "joins array indices and calls HTTParty.get with correct params" do
      client = described_class.new
      expected_url = "https://latest-stock-price.p.rapidapi.com/prices"
      list = [ "NIFTY 50", "NIFTY BANK" ]
      expected_query = { Indices: "NIFTY 50,NIFTY BANK" }

      expect(HTTParty).to receive(:get).with(
        expected_url,
        hash_including(query: expected_query, headers: headers)
      ).and_return(double(parsed_response: [ { "symbol" => "NIFTY" } ]))

      client.prices(list)
    end

    it "passes through string indices and calls HTTParty.get" do
      client = described_class.new
      expected_url = "https://latest-stock-price.p.rapidapi.com/prices"
      indices = "NIFTY 50,NIFTY BANK"

      expect(HTTParty).to receive(:get).with(
        expected_url,
        hash_including(query: { Indices: indices }, headers: headers)
      ).and_return(double(parsed_response: []))

      client.prices(indices)
    end
  end

  describe "#price_all" do
    it "calls HTTParty.get to /price_all with headers only" do
      client = described_class.new
      expected_url = "https://latest-stock-price.p.rapidapi.com/price_all"

      expect(HTTParty).to receive(:get).with(
        expected_url,
        hash_including(headers: headers)
      ).and_return(double(parsed_response: []))

      client.price_all
    end
  end
end
