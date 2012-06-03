class MainController < ApplicationController
  before_filter :set_language, :set_version, :prepare_menu
  layout :set_layout

  def show_language_top
    # render view
  end

  def show_library
    find_entry(params[:library]) do |entry|
      @entry = entry
      @document = find_document(@entry)
      #@methods = Entry.where(version_id: @version.id, "fullname LIKE ?", @entry.fullname + "%")
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

    render "show_method"
  end

  def show_instance_method
    find_entry("#{params[:library]};#{params[:module]}##{params[:name]}") do |entry|
      @entry = entry
      @document = find_document(@entry)
    end

    render "show_method"
  end

  def show_constant
    find_entry("#{params[:library]};#{params[:module]}::#{params[:name]}") do |entry|
      @entry = entry
      @document = find_document(@entry)
    end

    render "show_method"
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

  def set_version
    @version = Version[params[:version]] || Version.latest
  end

  def prepare_menu
    #@modules = [[],[]]; @libraries = []; return
    unless pjax?
      @modules = Entry.builtin_modules(@version)
      @libraries = [] #Entry.libraries(@version)
    end
  end

  def find_entry(fullname)
    if entry = Entry.where(fullname: fullname, version_id: @version.id).first
      yield entry
    else
      not_found
    end
  end

  # May return nil
  def find_document(entry)
    load './lib/document_extractor.rb'
    #return RubyApi::DocumentExtractor.for(@language, @version).extract_document(entry)

    Document.where(entry_id: entry.id,
                   language_id: @language.id).first
  end
end
