require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'

describe CancelledRegistrationLoa2Controller do
  subject { get :index, params: { locale: 'en' } }

  before :each do
    session[:selected_idp] = { 'entity_id' => 'http://idcorp.com', 'simple_id' => 'stub-idp-one', 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2) }
  end

  it 'renders the cancelled registration LOA2 template when LEVEL_2 is the requested LOA' do
    set_session_and_cookies_with_loa('LEVEL_2')

    expect(subject).to render_template(:cancelled_registration_LOA2)
  end
end
