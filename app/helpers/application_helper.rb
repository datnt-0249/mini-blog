module ApplicationHelper
  def full_title page_title
    base_title = t "layouts.header.title"
    page_title.blank? ? base_title : "#{page_title} | #{base_title}"
  end

  def show_errors object, field_name
    return unless object.errors.any?

    return if object.errors.messages[field_name].blank?

    object.errors.full_messages_for(field_name)[0]
  end
end
