#
# JavaScript for translation form
#

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

    $.ajax {
      type: "POST",
      url: url,
      data: {_method: 'PUT', 'paragraph[body]': text},
      dataType: "html",
      success: (data, status) ->
        if status == "success"
          $(para).find(".current_text > div").removeClass("not_translated") \
                                             .addClass("translated") \
                                             .html(data)
          $(para).find(".original_text").click()
        else
          alert("could not update translation: #{status}")
      error: (jqXHR, textStatus, errorThrown) ->
        console.error(jqXHR, textStatus, errorThrown)
        alert("error on ajax")
    }

    false

$ ->
  add_handlers()
  $(document).on('pjax:end', add_handlers)
