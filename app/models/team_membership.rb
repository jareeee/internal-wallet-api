class TeamMembership < ApplicationRecord
  belongs_to :user
  belongs_to :team

  ROLES = %w[owner admin member].freeze

  validates :role, presence: true, inclusion: { in: ROLES }
end
