require 'eidas_validation'

class ACountryPageController < ApplicationController
  include EidasValidation
  before_action :ensure_session_eidas_supported

  def index; end
end
