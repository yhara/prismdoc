class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_locale
   
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def not_found
    render file: "public/404.html", status: 404, layout: false
  end
end
