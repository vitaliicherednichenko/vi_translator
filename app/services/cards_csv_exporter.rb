require "csv"

class CardsCsvExporter
  HEADERS = %w[collection front_text back_text source_language target_language created_at].freeze

  def initialize(user)
    @user = user
  end

  def call
    CSV.generate(headers: true) do |csv|
      csv << HEADERS
      cards.each do |card|
        csv << [
          card.collection.name,
          card.front_text,
          card.back_text,
          card.source_language&.name,
          card.target_language&.name,
          card.created_at.iso8601
        ]
      end
    end
  end

  private

  attr_reader :user

  def cards
    user.cards.kept
        .includes(:collection, :source_language, :target_language)
        .order(:created_at)
  end
end
