module DocumentDecorator
  def text
    case
    when self.body
      self.body
    when self.paragraph_id_list
      self.paragraphs.map(&:text).join("\n\n")
    else
      "(no document available)"
    end
  end
end
