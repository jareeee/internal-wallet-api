require "rails_helper"

RSpec.describe "V1::StockPrices", type: :request do
  let(:headers) { { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' } }

  def login_as(user)
    post "/v1/auth", params: { email: user.email, password: "password123" }.to_json, headers: headers
    expect(response).to have_http_status(:created)
    cookies = response.headers['Set-Cookie']
    headers['Cookie'] = cookies if cookies
  end

  describe "GET /v1/stock_prices" do
    let!(:user) { create(:user) }

    context "when authenticated" do
      before { login_as(user) }

      it "calls price_all when all=true and renders the payload" do
        payload = [ { "symbol" => "XYZ", "lastPrice" => 123.45 } ]
        fake = instance_double(LatestStockPrice::Client)
        expect(fake).to receive(:price_all).and_return(payload)
        allow(LatestStockPrice::Client).to receive(:new).and_return(fake)

        get "/v1/stock_prices", params: { all: true }, headers: headers

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body).to eq(JSON.parse(payload.to_json))
      end

      it "calls price when a single indices is provided" do
        payload = [ { "symbol" => "NIFTY", "lastPrice" => 100.0 } ]
        fake = instance_double(LatestStockPrice::Client)
        expect(fake).to receive(:price).with("NIFTY 50").and_return(payload)
        allow(LatestStockPrice::Client).to receive(:new).and_return(fake)

        get "/v1/stock_prices", params: { indices: "NIFTY 50" }, headers: headers

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body).to eq(JSON.parse(payload.to_json))
      end

      it "calls prices when a comma separated indices list is provided" do
        list = "NIFTY 50,NIFTY BANK"
        payload = [ { "symbol" => "NIFTY" }, { "symbol" => "BANK" } ]
        fake = instance_double(LatestStockPrice::Client)
        expect(fake).to receive(:prices).with(list).and_return(payload)
        allow(LatestStockPrice::Client).to receive(:new).and_return(fake)

        get "/v1/stock_prices", params: { indices: list }, headers: headers

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body).to eq(JSON.parse(payload.to_json))
      end

      it "calls prices when indices is an array" do
        list = [ "NIFTY 50", "NIFTY BANK" ]
        payload = [ { "symbol" => "NIFTY" }, { "symbol" => "BANK" } ]
        fake = instance_double(LatestStockPrice::Client)
        expect(fake).to receive(:prices).with(list).and_return(payload)
        allow(LatestStockPrice::Client).to receive(:new).and_return(fake)

        get "/v1/stock_prices", params: { indices: list }, headers: headers

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body).to eq(JSON.parse(payload.to_json))
      end

      it "returns 400 when missing all and indices params" do
        allow(LatestStockPrice::Client).to receive(:new).and_return(double("Client"))
        get "/v1/stock_prices", headers: headers

        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body).to include("error")
      end
    end

    context "when unauthenticated" do
      it "returns 401 unauthorized" do
        get "/v1/stock_prices", headers: headers
        expect([ 401, 403 ]).to include(response.status)
      end
    end
  end
end
