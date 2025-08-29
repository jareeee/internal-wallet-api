require 'rails_helper'

RSpec.describe "V1::Deposits", type: :request do
  let(:headers) { { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' } }

  def login_as(user)
    post "/v1/auth", params: { email: user.email, password: "password123" }.to_json, headers: headers
    expect(response).to have_http_status(:created)
    cookies = response.headers['Set-Cookie']
    headers['Cookie'] = cookies if cookies
  end

  describe "POST /v1/wallet/deposits" do
    let!(:user) { create(:user) }

    context "when authenticated" do
      before { login_as(user) }

      it "creates a deposit (201) with valid payload" do
        target = create(:user).create_wallet!

        expect do
          post "/v1/wallet/deposits",
               params: { target_wallet_id: target.id, amount: "100.50", currency: "IDR" }.to_json,
               headers: headers
        end.to change { Deposit.count }.by(1)

        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["data"]).to include(
          "type" => "Deposit",
          "amount" => "100.5",
          "currency" => "IDR",
          "target_wallet_id" => target.id
        )
      end

      it "returns 404 when target wallet not found" do
        post "/v1/wallet/deposits",
             params: { target_wallet_id: 999_999, amount: "10", currency: "IDR" }.to_json,
             headers: headers

        expect(response).to have_http_status(:not_found)
      end

      it "returns 422 when amount is invalid (<= 0)" do
        target = create(:user).create_wallet!

        post "/v1/wallet/deposits",
             params: { target_wallet_id: target.id, amount: 0, currency: "IDR" }.to_json,
             headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when unauthenticated" do
      it "returns 401/403" do
        target = create(:user).create_wallet!

        post "/v1/wallet/deposits",
             params: { target_wallet_id: target.id, amount: 10, currency: "IDR" }.to_json,
             headers: headers

        expect([ 401, 403 ]).to include(response.status)
      end
    end
  end
end
