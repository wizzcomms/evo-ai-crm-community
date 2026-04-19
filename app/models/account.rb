class Account < ApplicationRecord
  has_many :contacts, dependent: :nullify
  has_many :inboxes, dependent: :nullify
  has_many :conversations, dependent: :nullify
  has_many :contact_inboxes, dependent: :nullify

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: { case_sensitive: false }

  before_validation :normalize_subdomain

  scope :default_account, -> { where(default: true) }

  def self.default
    default_account.first || first
  end

  private

  def normalize_subdomain
    self.subdomain = subdomain.to_s.downcase.strip
  end
end
