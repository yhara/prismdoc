class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :force_load_models, :set_locale

  # XXX: This is needed so that 'ModuleEntry.all' returns class entries too
  def force_load_models
    ClassEntry
    SingletonMethodEntry
    InstanceMethodEntry
  end
   
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def not_found
    render file: "public/404.html", status: 404, layout: false
  end
end
