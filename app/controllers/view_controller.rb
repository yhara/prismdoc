class ViewController < ApplicationController
  before_filter :set_language, :prepare_menu
  layout "view/split"

  def show_class
    find_entry(params[:class]) do |entry|
      @entry = entry
      @document = find_document(@entry)
      @methods = Entry.where("fullname LIKE ?", @entry.fullname + "%")
    end
  end

  def show_class_method
    find_entry("#{params[:class]}.#{params[:name]}") do |entry|
      @entry = entry
      @document = find_document(@entry)
    end
  end

  def show_instance_method
    find_entry("#{params[:class]}##{params[:name]}") do |entry|
      @entry = entry
      @document = find_document(@entry)
    end
  end

  private

  def set_language
    @language = Language.from_short_name(params[:lang])
  end

  def prepare_menu
    @modules = Entry.classes_modules
    @libraries = Entry.libraries
  end

  def find_entry(fullname)
    if entry = Entry.find_by_fullname(fullname)
      yield entry
    else
      not_found
    end
  end

  # May return nil
  def find_document(entry)
    Document.where(entry_id: entry.id,
                   language_id: @language.id).first
  end
end
