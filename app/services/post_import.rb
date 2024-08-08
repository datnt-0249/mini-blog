class PostImport < ApplicationService
  attr_reader :input_file, :user

  def initialize input_file, user
    @input_file = input_file
    @user = user
  end

  def call
    column_mapping = {
      "Title" => :title,
      "Content" => :content,
      "Status" => :status
    }

    validate_file_format @input_file
    xlsx = Roo::Excelx.new @input_file
    sheet = xlsx.sheet(0)
    headers = sheet.row(1)
    header_mapping = headers.map{|header| column_mapping[header]}

    rows = read_sheet header_mapping, sheet

    @user.posts.insert_all rows
  end

  private

  def read_sheet header_mapping, sheet
    rows = []
    (Settings.import.header_row + 1..sheet.last_row).each do |row_index|
      row = Hash[[header_mapping, sheet.row(row_index)].transpose]
      begin
        validate_row! row
        rows << row unless row.values.all?(&:nil?)
      rescue ArgumentError => e
        raise ArgumentError, "#{I18n.t("services.line_error", row: row_index)} #{e.message}"
      end
    end
    rows
  end

  def validate_row! row
    post = @user.posts.build row

    return if post.valid?
    raise ArgumentError, post.errors.full_messages.join(", ")
  end

  def validate_file_format file
    ext = File.extname(file.original_filename)
    return if %w[.xls .xlsx].include? ext

    raise Zip::Error, t(".invalid_file")
  end
end
