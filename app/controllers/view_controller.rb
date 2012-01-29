class ViewController < ApplicationController
  def show
    @entry = Entry.find_by_fullname(params[:fullname])

    @document = Document.where(entry_id: @entry.id,
                               language_id: Language["English"].id).first

    if @entry.type == "class"
      # TODO: dangerous splat
      @methods = Entry.where("fullname LIKE '#{@entry.fullname}%'")
    end

  end
end
