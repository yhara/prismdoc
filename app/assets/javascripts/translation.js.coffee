$ ->
  # Show edit form
  $('.paragraph > .current_text, .paragraph > .original_text').click ->
    para = $(this).closest(".paragraph")
    $(para).children(".current_text").toggle()
    $(para).children(".original_text").toggle()
    $(para).children("form").toggle()


