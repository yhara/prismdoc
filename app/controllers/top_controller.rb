# TopController handles '/' and redirects to '/en', '/ja' etc.
# according to user's browser settings.
#
class TopController < ApplicationController
  def index
    given = request.env['HTTP_ACCEPT_LANGUAGE'][/^[a-z]{2}/]
    language = Language.find_by_short_name(given) || Language.default

    redirect_to "/#{language.short_name}/"
  end
end
