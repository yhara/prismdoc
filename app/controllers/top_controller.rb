# TopController handles '/' and redirects to '/en', '/ja' etc.
# according to user's browser settings.
#
class TopController < ApplicationController
  def index
    accept_language = request.env['HTTP_ACCEPT_LANGUAGE']
    if accept_language
      given = accept_language[/^[a-z]{2}/]
      language = Language.find_by_short_name(given) || Language.default
    else
      language = Language.default
    end

    redirect_to "/#{language.short_name}/"
  end
end
