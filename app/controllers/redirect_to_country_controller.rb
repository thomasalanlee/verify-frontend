require 'eidas_validation'

class RedirectToCountryController < ApplicationController
  include EidasValidation
  before_action :ensure_session_eidas_supported

  def index
    saml_message = SAML_PROXY_API.authn_request(session['verify_session_id'])
    @request = CountryRequest.new(saml_message)
  end

  def submit; end
end
