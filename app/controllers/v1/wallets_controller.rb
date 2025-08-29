module V1
  class WalletsController < ApplicationController
    before_action :authorize_request

    def show
      wallet = Wallet.find_by(id: params[:id])

      return render json: { error: "Wallet not found" }, status: :not_found unless wallet
      return render json: { error: "You are not authorized to view this wallet" }, status: :forbidden unless authorized_for_wallet?(wallet)

      render json: serialize_wallet(wallet), status: :ok
    end

    def by_owner
      owner_type = params[:owner_type]
      owner_id = params[:owner_id]

      wallet = Wallet.find_by(walletable_type: owner_type, walletable_id: owner_id)

      return render json: { error: "Wallet not found" }, status: :not_found unless wallet
      return render json: { error: "You are not authorized to view this wallet" }, status: :forbidden unless authorized_for_wallet?(wallet)

      render json: serialize_wallet(wallet), status: :ok
    end

    private

    def authorized_for_wallet?(wallet)
      owner = wallet.walletable
      return false unless owner.respond_to?(:wallet_accessible_by?)

      owner.wallet_accessible_by?(current_user)
    end

    def serialize_wallet(wallet)
      {
        data: {
          id: wallet.id,
          owner_type: wallet.walletable_type,
          owner_id: wallet.walletable_id,
          balance: wallet.calculate_balance.to_s
        }
      }
    end
  end
end
