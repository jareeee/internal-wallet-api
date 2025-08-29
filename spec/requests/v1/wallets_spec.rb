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
      let!(:user_wallet) { user.create_wallet! }

      before { login_as(user) }

      it "returns own wallet with balance" do
        get "/v1/wallets/#{user_wallet.id}", headers: headers

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["data"]).to include(
          "id" => user_wallet.id,
          "owner_type" => "User",
          "owner_id" => user.id
        )
        expect(body["data"]).to have_key("balance")
      end

      it "returns 403 when accessing another user's wallet" do
        other = create(:user)
        other_wallet = other.create_wallet!

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
        wallet = user.create_wallet!

        get "/v1/wallets/#{wallet.id}", headers: headers

        expect(response.status).to satisfy { |s| [ 401, 403 ].include?(s) }
      end
    end
  end

  describe "GET /v1/wallets/by_owner" do
    context "when team member is logged in" do
      let!(:member) { create(:user) }
      let!(:team) { create(:team) }
      let!(:membership) { create(:team_membership, user: member, team: team, role: 'member') }
      let!(:team_wallet) { team.create_wallet! }

      before { login_as(member) }

      it "returns team wallet for a member" do
        get "/v1/wallet/by_owner", params: { owner_type: 'Team', owner_id: team.id }, headers: headers

        expect(response).to have_http_status(:ok)
      end

      it "returns 403 for non member" do
        other = create(:user)
        login_as(other)

        get "/v1/wallet/by_owner", params: { owner_type: 'Team', owner_id: team.id }, headers: headers

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
