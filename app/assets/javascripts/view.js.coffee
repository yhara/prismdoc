# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

PrismDoc = {}

init_tree_button = ->
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

init_search = ->
  search_class_or_methods = (q) ->
    $.grep PrismDoc.index, (name) ->
      if q.match(/[A-Z]/)
        name.indexOf(q) != -1
      else
        name.toLowerCase().indexOf(q) != -1

  search_in_class = (cname, mname, type='(\\.|#|::)') ->
    $.grep PrismDoc.index, (name) ->
      if cname.match(/[A-Z]/)
        name.match(new RegExp(cname+'(.*)'+type+'(.*)'+mname))
      else
        name.toLowerCase().match(new RegExp(cname+'(.*)'+type+'(.*)'+mname))

  search = (q) ->
    if q.indexOf(".") != -1
      [cname, mname] = q.split(".")
      search_in_class(cname, mname, "\\.")
    else if q.indexOf("#") != -1
      [cname, mname] = q.split("#")
      search_in_class(cname, mname, "#")
    else if q.indexOf(" ") != -1
      [cname, mname] = q.split(" ")
      search_in_class(cname, mname)
    else
      search_class_or_methods(q)

  href_to = (name) ->
    lang = location.pathname.match(/^\/([^\/]*)\//)[1]
    ver = location.pathname.match(/\/(.\..\..)/)[1]
    match = name.match(/([A-Za-z:]+)([\.\#])(.*)/)
    if match
      [_, klass_name, type_name, method_name] = match
      switch type_name
        when "#"
          "/#{lang}/#{ver}/#{encodeURIComponent(klass_name)}/#{encodeURIComponent(method_name)}"
        when "."
          "/#{lang}/#{ver}/#{encodeURIComponent(klass_name)}/.#{encodeURIComponent(method_name)}"
     else
       "/#{lang}/#{ver}/#{encodeURIComponent(name)}"

  make_li = (name, is_even) ->
    klass = if is_even then "even" else "odd"
    li = $('<li class="'+klass+'"><a></a></li>')
    li.find('a').attr('href', href_to(name))
    li.find('a').text(name)
    li

  _q = ''
  suggest = ->
    q = $('#search-box').val()
    return if q == _q
    _q = q

    if q
      $('#left_contents').hide()
      ul = $('#search_result')
      ul.empty()
      $.each search(q), (i, name) ->
        if i < 30
          ul.append make_li(name, i % 2 == 0)
        else if i == 30
          ul.append $('<li>...</li>')

    else
      $('#left_contents').show()

  $.getJSON "/index.json", (data) ->
    PrismDoc.index = data
  $('#search-box').keyup ->
    suggest()
  $('#search-box').focus ->
    $(this).select()

init_pjax = ->
  $('a').pjax('#doc', timeout: 2000)

$ ->
  init_tree_button()
  init_search()
  init_pjax()

