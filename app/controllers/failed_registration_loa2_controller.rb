class FailedRegistrationLoa2Controller < ApplicationController
  def index
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
    @transaction = current_transaction
    @custom_fail = !current_transaction.custom_fail_heading.nil?
    if CONTINUE_ON_FAILED_REGISTRATION_RPS.include?(current_transaction_simple_id)
      render 'failed_registration/index_continue_on_failed_registration_LOA2'
    else
      render 'failed_registration/index_LOA2'
    end
  end
end
