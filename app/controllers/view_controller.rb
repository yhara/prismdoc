class ViewController < ApplicationController
  def show
    @entry = Entry.find_by_fullname(params[:fullname])

  def show_class
    @entry = Entry.find_by_fullname!(params[:class])
    @document = find_document(@entry)
    @methods = Entry.where("fullname LIKE ?", @entry.fullname + "%")
  end

  def show_class_method
    query = "#{params[:class]}.#{params[:name]}"
    @entry = Entry.find_by_fullname(query)
    @document = find_document(@entry)
  end

  def show_instance_method
    query = "#{params[:class]}##{params[:name]}"
    @entry = Entry.find_by_fullname(query)
    @document = find_document(@entry)
  end

  # May return nil
  def find_document(entry)
    Document.where(entry_id: entry.id,
                   language_id: @language.id).first
  end
end
