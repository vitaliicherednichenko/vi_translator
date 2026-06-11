class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :configure_permitted_parameters, if: :devise_controller?
  around_action :switch_locale

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :native_language_id, :preferred_language_id ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :native_language_id, :preferred_language_id ])
  end

  private

  def user_not_authorized
    flash[:alert] = t("flash.not_authorized")
    redirect_back fallback_location: root_path
  end

  def switch_locale(&action)
    if params[:locale].present? && available_locale?(params[:locale])
      session[:locale] = params[:locale]
    end

    locale = session[:locale].presence ||
             user_native_locale ||
             I18n.default_locale

    I18n.with_locale(locale, &action)
  end

  def user_native_locale
    code = current_user&.native_language&.code
    code if code && available_locale?(code)
  end

  def available_locale?(locale)
    I18n.available_locales.map(&:to_s).include?(locale.to_s)
  end
end
