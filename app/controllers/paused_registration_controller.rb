class PausedRegistrationController < ApplicationController

  def index
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
    @transaction = {
      name: transaction_name,
      homepage: transaction_homepage
    }

    render :index
  end

  private

  def transaction_name
    current_transaction.rp_name
  end

  def transaction_homepage
    CONFIG_PROXY.transaction(current_transaction_entity_id).fetch('serviceHomepage')
  end
end