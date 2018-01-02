require 'redirect_with_see_other'
require 'cookies/cookies'
require 'user_characteristics'
require 'user_errors'

class ApplicationController < ActionController::Base
  include DeviceType
  include UserErrors
  include UserCharacteristics

  before_action :validate_session
  before_action :set_visitor_cookie
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_locale
  before_action :store_originating_ip
  before_action :set_piwik_custom_variables
  after_action :store_locale_in_cookie, if: -> { request.method == 'GET' }

  helper_method :transaction_taxon_list
  helper_method :transactions_list
  helper_method :loa1_transactions_list
  helper_method :loa2_transactions_list
  helper_method :public_piwik

  rescue_from StandardError, with: :something_went_wrong unless Rails.env == 'development'
  rescue_from Errors::WarningLevelError, with: :something_went_wrong_warn
  rescue_from Api::SessionError, with: :session_error
  rescue_from Api::UpstreamError, with: :something_went_wrong_warn
  rescue_from Api::SessionTimeoutError, with: :session_timeout

  prepend RedirectWithSeeOther

private

  def transaction_taxon_list
    TRANSACTION_TAXON_CORRELATOR.correlate(CONFIG_PROXY.transactions)
  end

  def transactions_list
    DATA_CORRELATOR.correlate(CONFIG_PROXY.transactions)
  end

  def loa1_transactions_list
    Display::Rp::TransactionFilter.new.filter_by_loa(transactions_list, 'LEVEL_1')
  end

  def loa2_transactions_list
    Display::Rp::TransactionFilter.new.filter_by_loa(transactions_list, 'LEVEL_2')
  end

  def current_transaction
    @current_transaction ||= RP_DISPLAY_REPOSITORY.fetch(current_transaction_simple_id)
  end

  def current_transaction_simple_id
    session[:transaction_simple_id]
  end

  def current_transaction_entity_id
    session[:transaction_entity_id]
  end

  def current_transaction_homepage
    session[:transaction_homepage]
  end

  def store_locale_in_cookie
    cookies.signed[CookieNames::VERIFY_LOCALE] = {
      value: I18n.locale,
      httponly: true,
      secure: Rails.configuration.x.cookies.secure
    }
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def validate_session
    validation = session_validator.validate(cookies, session)
    unless validation.ok?
      logger.info(validation.message)
      render_error(validation.type, validation.status)
    end
  end

  def set_visitor_cookie
    cookies[CookieNames::PIWIK_USER_ID] = SecureRandom.hex(8) unless cookies.has_key? CookieNames::PIWIK_USER_ID
  end

  def set_secure_cookie(name, value)
    cookies[name] = {
      value: value,
      httponly: true,
      secure: Rails.configuration.x.cookies.secure
    }
  end

  def set_journey_hint(idp_entity_id)
    cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = { entity_id: idp_entity_id }.to_json
  end

  def session_validator
    SESSION_VALIDATOR
  end

  def public_piwik
    PUBLIC_PIWIK
  end

  def store_originating_ip
    OriginatingIpStore.store(request)
  end

  def selected_identity_provider
    selected_idp = session[:selected_idp]
    if selected_idp.nil?
      raise(Errors::WarningLevelError, 'No selected IDP in session')
    else
      IdentityProvider.from_session(selected_idp)
    end
  end

  def current_identity_providers_for_loa
    CONFIG_PROXY.get_idp_list_for_loa(session[:transaction_entity_id], session[:requested_loa]).idps
  end

  def current_identity_providers_for_sign_in
    CONFIG_PROXY.get_idp_list_for_sign_in(session[:transaction_entity_id]).idps
  end

  def report_to_analytics(action_name)
    FEDERATION_REPORTER.report_action(current_transaction, request, action_name)
  end

  def select_viewable_idp_for_sign_in(entity_id)
    for_viewable_idp(entity_id, current_identity_providers_for_sign_in) do |decorated_idp|
      session[:selected_idp] = decorated_idp.identity_provider
      yield decorated_idp
    end
  end

  def select_viewable_idp_for_loa(entity_id)
    for_viewable_idp(entity_id, current_identity_providers_for_loa) do |decorated_idp|
      session[:selected_idp] = decorated_idp.identity_provider
      yield decorated_idp
    end
  end

  def for_viewable_idp(entity_id, identity_provider_list)
    matching_idp = identity_provider_list.detect { |idp| idp.entity_id == entity_id }
    idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(matching_idp)
    if idp.viewable?
      yield idp
    else
      logger.error 'Unrecognised IdP simple id'
      render_not_found
    end
  end

  def set_piwik_custom_variables
    @piwik_custom_variables = [
        Analytics::CustomVariable.build_for_js_client(:rp, current_transaction.analytics_description),
        Analytics::CustomVariable.build_for_js_client(:loa_requested, session[:requested_loa])
    ]
  end
end
