require 'rails_helper'

RSpec.describe "V1::Transfers", type: :request do
  let(:headers) { { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' } }

  def login_as(user)
    post "/v1/auth", params: { email: user.email, password: "password123" }.to_json, headers: headers
    expect(response).to have_http_status(:created)
    cookies = response.headers['Set-Cookie']
    headers['Cookie'] = cookies if cookies
  end

  def seed_deposit(wallet, amount: 100, currency: 'IDR')
    Deposit.create!(target_wallet: wallet, amount: amount, currency: currency)
  end

  describe "POST /v1/wallet/transfers" do
    let!(:user) { create(:user) }
    let!(:user_wallet) { user.create_wallet!(currency: 'IDR') }

    context "when authenticated" do
      before do
        seed_deposit(user_wallet, amount: 150)
        login_as(user)
      end

      it "creates a transfer (201) when authorized and sufficient funds (same currency)" do
        target_wallet = create(:user).create_wallet!(currency: 'IDR')

        expect do
          post "/v1/wallet/transfers",
               params: { source_wallet_id: user_wallet.id, target_wallet_id: target_wallet.id, amount: 75, currency: "IDR" }.to_json,
               headers: headers
        end.to change { Transfer.count }.by(1)

        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["data"]).to include(
          "type" => "Transfer",
          "amount" => "75.0",
          "currency" => "IDR",
          "source_wallet_id" => user_wallet.id,
          "target_wallet_id" => target_wallet.id
        )
      end

      it "allows transfer from team wallet when user is a member (same currency)" do
        team = create(:team)
        create(:team_membership, team: team, user: user, role: 'member')
        team_wallet = team.create_wallet!(currency: 'IDR')
        seed_deposit(team_wallet, amount: 50)
        target_wallet = create(:user).create_wallet!(currency: 'IDR')

        post "/v1/wallet/transfers",
             params: { source_wallet_id: team_wallet.id, target_wallet_id: target_wallet.id, amount: 25, currency: "IDR" }.to_json,
             headers: headers

        expect(response).to have_http_status(:created)
      end

      it "returns 403 when not authorized for source wallet" do
        other_wallet = create(:user).create_wallet!(currency: 'IDR')
        seed_deposit(other_wallet, amount: 100)

        post "/v1/wallet/transfers",
             params: { source_wallet_id: other_wallet.id, target_wallet_id: user_wallet.id, amount: 10, currency: "IDR" }.to_json,
             headers: headers

        expect(response).to have_http_status(:forbidden)
      end

      it "returns 404 when source or target wallet not found" do
        post "/v1/wallet/transfers",
             params: { source_wallet_id: user_wallet.id, target_wallet_id: 999_999, amount: 10, currency: "IDR" }.to_json,
             headers: headers
        expect(response).to have_http_status(:not_found)

        post "/v1/wallet/transfers",
             params: { source_wallet_id: 999_999, target_wallet_id: user_wallet.id, amount: 10, currency: "IDR" }.to_json,
             headers: headers
        expect(response).to have_http_status(:not_found)
      end

      it "returns 422 when amount is invalid (<= 0)" do
        target_wallet = create(:user).create_wallet!(currency: 'IDR')

        post "/v1/wallet/transfers",
             params: { source_wallet_id: user_wallet.id, target_wallet_id: target_wallet.id, amount: 0, currency: "IDR" }.to_json,
             headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns 422 when funds are insufficient" do
        target_wallet = create(:user).create_wallet!(currency: 'IDR')

        post "/v1/wallet/transfers",
             params: { source_wallet_id: user_wallet.id, target_wallet_id: target_wallet.id, amount: 999_999, currency: "IDR" }.to_json,
             headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Insufficient funds")
      end

      it "returns 422 for cross-currency transfer attempts" do
        target_wallet = create(:user).create_wallet!(currency: 'USD')

        post "/v1/wallet/transfers",
             params: { source_wallet_id: user_wallet.id, target_wallet_id: target_wallet.id, amount: 10, currency: "IDR" }.to_json,
             headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Cross-currency transfers are not supported")
      end
    end

    context "when unauthenticated" do
      it "returns 401/403" do
        target_wallet = create(:user).create_wallet!

        post "/v1/wallet/transfers",
             params: { source_wallet_id: user_wallet.id, target_wallet_id: target_wallet.id, amount: 10, currency: "IDR" }.to_json,
             headers: headers

        expect([ 401, 403 ]).to include(response.status)
      end
    end
  end
end
