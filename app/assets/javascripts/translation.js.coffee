add_handlers = ->
  # Show edit form
  $('.paragraph > .current_text, .paragraph > .original_text').click ->
    para = $(this).closest(".paragraph")
    $(para).children(".current_text").toggle()
    $(para).children(".original_text").toggle()
    $(para).children("form").toggle()

  # Submit translation
  $('.update_paragraph').click ->
    para = $(this).closest(".paragraph")
    url = $(this).data('url')
    text = $(para).find('textarea').val()

    $.post url, {_method: 'PUT', 'paragraph[body]': text}, (data, status) ->
      if status == "success"
        $(para).find(".current_text > pre").removeClass("not_translated") \
                                           .addClass("translated") \
                                           .html(text)
        $(para).find(".original_text").click()
      else
        alert("could not update translation: #{status}")
    false

$ ->
  add_handlers()
  $(document).on('pjax:end', add_handlers)
