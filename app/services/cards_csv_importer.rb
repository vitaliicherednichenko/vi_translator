require "csv"

class CardsCsvImporter
  Result = Struct.new(:imported, :skipped, :error, keyword_init: true) do
    def success?
      error.nil?
    end

    def summary
      message = I18n.t("import.flash.summary", count: imported)
      message += " " + I18n.t("import.flash.skipped", count: skipped) if skipped.positive?
      message
    end
  end


  def initialize(user, io, collection: nil)
    @user = user
    @io = io
    @collection = collection
  end

  def call
    @imported = 0
    @skipped = 0

    CSV.parse(io.read, headers: true) { |row| import_row(row) }

    Result.new(imported: @imported, skipped: @skipped)
  rescue CSV::MalformedCSVError
    Result.new(imported: @imported, skipped: @skipped, error: I18n.t("import.flash.parse_error"))
  end

  private

  attr_reader :user, :io, :collection

  def import_row(row)
    front  = row["front_text"].to_s.strip
    back   = row["back_text"].to_s.strip
    source = find_language(row["source_language"])
    target = find_language(row["target_language"])

    if front.blank? || back.blank? || source.nil? || target.nil?
      @skipped += 1
      return
    end

    collection = self.collection || user.collections.find_or_create_by!(name: collection_name(row)) do |c|
      c.language = source || user.native_language
    end

    card = user.cards.find_or_create_by!(
      collection: collection,
      front_text: front,
      back_text: back,
      source_language: source,
      target_language: target
    )

    if card.previously_new_record?
      @imported += 1
    else
      @skipped += 1
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
    @skipped += 1
  end

  def find_language(value)
    normalized = value.to_s.strip.downcase
    return nil if normalized.blank?

    Language.where("LOWER(name) = ?", normalized).first ||
      Language.where("LOWER(code) = ?", normalized).first
  end

  def collection_name(row)
    row["collection"].to_s.strip.presence || "Imported"
  end
end
