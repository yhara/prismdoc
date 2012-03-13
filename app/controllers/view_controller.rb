class ViewController < ApplicationController
  before_filter :set_language, :prepare_menu
  layout :set_layout

  def show_language_top
    # render view
  end

  def show_library
    find_entry(params[:library]) do |entry|
      @entry = entry
      @document = find_document(@entry)
      #@methods = Entry.where("fullname LIKE ?", @entry.fullname + "%")
    end
  end

  def show_module
    find_entry("#{params[:library]};#{params[:module]}") do |entry|
      @entry = entry
      @document = find_document(@entry)
      @singleton_methods = @entry.singleton_methods
      @instance_methods = @entry.instance_methods
      @constants = @entry.constants
    end
  end

  def show_class_method
    find_entry("#{params[:library]};#{params[:module]}.#{params[:name]}") do |entry|
      @entry = entry
      @document = find_document(@entry)
    end
  end

  def show_instance_method
    find_entry("#{params[:library]};#{params[:module]}##{params[:name]}") do |entry|
      @entry = entry
      @document = find_document(@entry)
    end
  end

  def show_constant
    find_entry("#{params[:library]};#{params[:module]}::#{params[:name]}") do |entry|
      @entry = entry
      @document = find_document(@entry)
    end
  end

  private

  def pjax?
   request.headers['X-PJAX']
  end

  def set_layout
   if pjax? then false else "view" end
  end

  def set_language
    @language = Language.from_short_name(params[:lang])
  end

  def prepare_menu
    unless pjax?
      @modules = Entry.builtin_modules
      @libraries = Entry.libraries
    end
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
    load './lib/document_extractor.rb'
    #RubyApi::DocumentExtractor.for(@language).extract_document(entry)

    Document.where(entry_id: entry.id,
                   language_id: @language.id).first
  end
end
