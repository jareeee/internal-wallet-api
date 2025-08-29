require 'rails_helper'

RSpec.describe "V1::Withdrawals", type: :request do
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

  describe "POST /v1/wallet/withdrawals" do
    let!(:user) { create(:user) }
    let!(:user_wallet) { user.create_wallet!(currency: 'IDR') }

    context "when authenticated" do
      before do
        seed_deposit(user_wallet, amount: 200)
        login_as(user)
      end

      it "creates a withdrawal (201) when user owns the wallet and has sufficient funds" do
        expect do
          post "/v1/wallet/withdrawals",
               params: { source_wallet_id: user_wallet.id, amount: 50, currency: "IDR" }.to_json,
               headers: headers
        end.to change { Withdrawal.count }.by(1)

        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["data"]).to include(
          "type" => "Withdrawal",
          "amount" => "50.0",
          "currency" => "IDR",
          "source_wallet_id" => user_wallet.id
        )
      end

      it "returns 403 when user is not authorized for the source wallet" do
        other = create(:user)
  other_wallet = other.create_wallet!(currency: 'IDR')
        seed_deposit(other_wallet, amount: 100)

        post "/v1/wallet/withdrawals",
             params: { source_wallet_id: other_wallet.id, amount: 10, currency: "IDR" }.to_json,
             headers: headers

        expect(response).to have_http_status(:forbidden)
      end

      it "returns 404 when source wallet not found" do
        post "/v1/wallet/withdrawals",
             params: { source_wallet_id: 999_999, amount: 10, currency: "IDR" }.to_json,
             headers: headers

        expect(response).to have_http_status(:not_found)
      end

      it "returns 422 when amount is invalid (<= 0)" do
        post "/v1/wallet/withdrawals",
             params: { source_wallet_id: user_wallet.id, amount: 0, currency: "IDR" }.to_json,
             headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns 422 when funds are insufficient" do
        post "/v1/wallet/withdrawals",
             params: { source_wallet_id: user_wallet.id, amount: 999_999, currency: "IDR" }.to_json,
             headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Insufficient funds")
      end
    end

    context "when unauthenticated" do
      it "returns 401/403" do
        post "/v1/wallet/withdrawals",
             params: { source_wallet_id: user_wallet.id, amount: 10, currency: "IDR" }.to_json,
             headers: headers

        expect([ 401, 403 ]).to include(response.status)
      end
    end
  end
end
