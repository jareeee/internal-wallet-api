module V1
  class TransfersController < ApplicationController
    before_action :authorize_request

    def create
      source_wallet_id = params.require(:source_wallet_id)
      target_wallet_id = params.require(:target_wallet_id)
      amount_param = params.require(:amount)
      currency = params.require(:currency)

      unauthorized = false
      insufficient = false
      transfer = nil

      ActiveRecord::Base.transaction do
        ids = [ source_wallet_id.to_i, target_wallet_id.to_i ].sort
        locked = Wallet.lock.where(id: ids).index_by(&:id)
        source_wallet = locked[source_wallet_id.to_i]
        target_wallet = locked[target_wallet_id.to_i]

        raise ActiveRecord::RecordNotFound unless source_wallet && target_wallet

        unless authorized_for_wallet?(source_wallet)
          unauthorized = true
          raise ActiveRecord::Rollback
        end

        amount = BigDecimal(amount_param.to_s)
        current_balance = source_wallet.calculate_balance
        if current_balance < amount
          insufficient = true
          raise ActiveRecord::Rollback
        end

        transfer = Transfer.create!(
          source_wallet: source_wallet,
          target_wallet: target_wallet,
          amount: amount,
          currency: currency
        )
      end

      return render json: { error: "You are not authorized to transfer from this wallet" }, status: :forbidden if unauthorized
      return render json: { error: "Insufficient funds" }, status: :unprocessable_entity if insufficient

      render json: serialize_transaction(transfer), status: :created
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Wallet not found" }, status: :not_found
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    rescue ActionController::ParameterMissing => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    private

    def authorized_for_wallet?(wallet)
      owner = wallet.walletable
      return false unless owner.respond_to?(:wallet_accessible_by?)

      owner.wallet_accessible_by?(current_user)
    end

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
