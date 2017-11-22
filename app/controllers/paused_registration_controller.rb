class PausedRegistrationController < ApplicationController
  # Validate the session manually within the action, as we don't want the normal 'no session' page.
  skip_before_action :validate_session
  skip_before_action :set_piwik_custom_variables

  def index
    if session_is_valid
      @idp_name = idp_name
      @transaction = {
          name: transaction_name,
          homepage: transaction_homepage
      }

      if idp_and_transaction_are_valid
        return render :with_user_session
      end
    end
    render :without_user_session
  end

  private

  def session_is_valid
    session_validator.validate(cookies, session).ok?
  end

  def idp_and_transaction_are_valid
    !@idp_name.nil? && !@transaction[:name].nil? && !@transaction[:homepage].nil?
  end

  def idp_name
    if session.key?(:selected_idp)
      return IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider).display_name
    end
    nil
  end

  def transaction_name
    current_transaction.rp_name
  end

  def transaction_homepage
    if current_transaction_entity_id
      transaction = CONFIG_PROXY.transaction(current_transaction_entity_id)
      return transaction.fetch('serviceHomepage', nil) if transaction
    end
    nil
  end
end