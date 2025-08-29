require 'rails_helper'

RSpec.describe "V1::Wallets", type: :request do
  let(:headers) { { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' } }

  def login_as(user)
    post "/v1/auth", params: { email: user.email, password: "password123" }.to_json, headers: headers
    expect(response).to have_http_status(:created)
    cookies = response.headers['Set-Cookie']
    headers['Cookie'] = cookies if cookies
  end

  describe "GET /v1/wallets/:id" do
    context "when user is logged in" do
      let!(:user) { create(:user) }
      let!(:user_wallet) { user.create_wallet!(currency: 'IDR') }

      before { login_as(user) }

      it "returns own wallet with balance" do
        get "/v1/wallets/#{user_wallet.id}", headers: headers

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["data"]).to include(
          "id" => user_wallet.id,
          "owner_type" => "User",
          "owner_id" => user.id,
          "currency" => "IDR"
        )
        expect(body["data"]).to have_key("balance")
      end

      it "returns 403 when accessing another user's wallet" do
        other = create(:user)
        other_wallet = other.create_wallet!(currency: 'IDR')

        get "/v1/wallets/#{other_wallet.id}", headers: headers

        expect(response).to have_http_status(:forbidden)
      end

      it "returns 404 when wallet does not exist" do
        get "/v1/wallets/999999", headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is not logged in" do
      it "returns 401 unauthorized" do
        user = create(:user)
        wallet = user.create_wallet!(currency: 'IDR')

        get "/v1/wallets/#{wallet.id}", headers: headers

        expect(response.status).to satisfy { |s| [ 401, 403 ].include?(s) }
      end
    end
  end

  describe "GET /v1/users/:user_id/wallets" do
    let!(:user) { create(:user) }
    let!(:wallet_idr) { user.create_wallet!(currency: 'IDR') }
    let!(:wallet_usd) { user.create_wallet!(currency: 'USD') }

    it "returns 401/403 when not logged in" do
      get "/v1/users/#{user.id}/wallets", headers: headers
      expect([ 401, 403 ]).to include(response.status)
    end

    it "returns list of wallets for the user when logged in" do
      login_as(user)
      get "/v1/users/#{user.id}/wallets", headers: headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["data"]).to be_an(Array)
      currencies = body["data"].map { |w| w["currency"] }
      expect(currencies).to match_array([ "IDR", "USD" ])
    end
  end
end
