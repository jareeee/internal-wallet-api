require 'rails_helper'

RSpec.describe "V1::Sessions", type: :request do
  let(:headers) { { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' } }

  describe "POST /v1/auth" do
    let!(:user) do
      User.create!(
        name: "Main User",
        email: "login@example.com",
        password: "password123",
        password_confirmation: "password123"
      )
    end

    it "authenticates with valid credentials and sets session cookie" do
      post "/v1/auth", params: { email: user.email, password: "password123" }.to_json, headers: headers

      expect(response).to have_http_status(:created)

      body = JSON.parse(response.body)
      expect(body).to have_key("data")
      expect(body["data"]).to have_key("expiration_time")
      expect(body["data"]).to have_key("user")
      expect(body["data"]["user"]["email"]).to eq(user.email)

      # Session cookie should be present
      set_cookie = response.headers["Set-Cookie"]
      expect(set_cookie).to include("_wallet_api_session")
    end

    it "rejects invalid credentials" do
      post "/v1/auth", params: { email: user.email, password: "wrong" }.to_json, headers: headers

      expect(response).to have_http_status(:unauthorized)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Invalid email or password")
    end
  end

  describe "DELETE /v1/auth" do
    it "clears the session and returns success message" do
      # Log in first
      user = User.create!(
        name: "Main User",
        email: "logout@example.com",
        password: "password123",
        password_confirmation: "password123"
      )

      post "/v1/auth", params: { email: user.email, password: "password123" }.to_json, headers: headers
      expect(response).to have_http_status(:created)

      delete "/v1/auth", headers: headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["message"]).to eq("Logout successful")
    end
  end
end
