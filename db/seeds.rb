# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "== Seeding database =="

ActiveRecord::Base.transaction do
	puts "Cleaning old data..."

	# Order matters due to FKs: dependent models first
	BalanceSnapshot.destroy_all
	Transaction.destroy_all
	Wallet.destroy_all
	TeamMembership.destroy_all
	Stock.destroy_all
	Team.destroy_all
	User.destroy_all

	puts "Creating main user..."
	main_user = User.create!(
		name: "Main User",
		email: "main@example.com",
		password: "password123",
		password_confirmation: "password123"
	)

	puts "Creating team..."
	team = Team.create!(name: "Alpha Team")

	puts "Linking user to team as owner..."
	TeamMembership.create!(user: main_user, team: team, role: "owner")

	puts "Creating stock for user..."
	stock = Stock.create!(symbol: "GOTO", user: main_user)

	puts "Creating wallets..."
	main_user.create_wallet!
	team.create_wallet!
	stock.create_wallet!

	puts "Seeding done."
	puts "Login with: email=main@example.com password=password123"
end

