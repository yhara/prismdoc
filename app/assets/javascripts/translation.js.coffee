$ ->
  $('.paragraph').click ->
    $(this).children(".current_text").toggle()
    $(this).children(".original_text").toggle()
    $(this).children("form").toggle()

