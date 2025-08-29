module V1
  class DepositsController < ApplicationController
    before_action :authorize_request

    def create
      target_id = params.require(:target_wallet_id)
      amount = params.require(:amount)
      currency = params.require(:currency)

      deposit = nil
      ActiveRecord::Base.transaction do
        # Lock target wallet to serialize balance-affecting operations
        target_wallet = Wallet.lock.find(target_id)

        deposit = Deposit.create!(
          target_wallet: target_wallet,
          amount: amount,
          currency: currency
        )
      end

      render json: serialize_transaction(deposit), status: :created
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Wallet not found" }, status: :not_found
    rescue ActionController::ParameterMissing => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    private

    def serialize_transaction(tx)
      {
        data: {
          id: tx.id,
          type: tx.class.name,
          amount: tx.amount.to_s,
          currency: tx.currency,
          source_wallet_id: tx.source_wallet_id,
          target_wallet_id: tx.target_wallet_id
        }
      }
    end
  end
end
