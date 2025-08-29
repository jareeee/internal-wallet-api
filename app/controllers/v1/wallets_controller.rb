module V1
  class WalletsController < ApplicationController
    before_action :authorize_request

    def show
      wallet = Wallet.find_by(id: params[:id])

      return render json: { error: "Wallet not found" }, status: :not_found unless wallet
      return render json: { error: "You are not authorized to view this wallet" }, status: :forbidden unless authorized_for_wallet?(wallet)

      render json: serialize_wallet(wallet), status: :ok
    end

    def index
      owner = find_owner_from_params
      return render json: { error: "Owner not found" }, status: :not_found unless owner

      unless owner.respond_to?(:wallet_accessible_by?) && owner.wallet_accessible_by?(current_user)
        return render json: { error: "You are not authorized to view these wallets" }, status: :forbidden
      end

      wallets = owner.wallets
      render json: serialize_wallets(wallets), status: :ok
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
          currency: wallet.currency,
          balance: wallet.calculate_balance.to_s
        }
      }
    end

    def serialize_wallets(wallets)
      {
        data: wallets.map { |w| serialize_wallet(w)[:data] }
      }
    end

    def find_owner_from_params
      if params[:user_id]
        User.find_by(id: params[:user_id])
      elsif params[:team_id]
        Team.find_by(id: params[:team_id])
      elsif params[:stock_id]
        Stock.find_by(id: params[:stock_id])
      end
    end
  end
end
