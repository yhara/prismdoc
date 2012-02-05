$ ->
  substitute_language = (short_name) ->
    location.pathname.replace(/^\/[^\/]*/, "/" + short_name)

  $("#language").change ->
    location.href = substitute_language $(this).val()
