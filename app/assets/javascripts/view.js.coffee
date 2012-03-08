# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $(".tree_button").click ->
    li = $(this).parent("li")
    if $(this).text() == "[+]"
      $(li).children("ul").show()
      $(this).text("[-]")
    else
      $(li).children("ul").hide()
      $(this).text("[+]")

    false

  $("#builtin_exceptions .tree_button").each ->
    if $(this).next().text().match(/^(SystemCallError|EncodingError|Exception)$/)
      $(this).click()

  $("#standard_libraries .tree_button").each ->
    $(this).click()

