$ ->
  substitute_version = (name) ->
    location.pathname.replace(/\d\.\d\.\d/, name)

  $("#version").change ->
    location.href = substitute_version $(this).val()

  substitute_language = (short_name) ->
    location.pathname.replace(/^\/[^\/]*/, "/" + short_name)

  $("#language").change ->
    location.href = substitute_language $(this).val()
