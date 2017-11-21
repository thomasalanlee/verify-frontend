class PausedRegistrationController < ApplicationController

  def index
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
    @transaction = {
        name: current_transaction.rp_name,
        homepage: CONFIG_PROXY.transaction(current_transaction_entity_id).fetch('serviceHomepage')
    }

    render :index
  end
end