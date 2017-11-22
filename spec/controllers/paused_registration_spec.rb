require 'rails_helper'
require 'controller_helper'
require 'spec_helper'
require 'api_test_helper'

describe PausedRegistrationController do
  before(:each) do
    set_session_and_cookies_with_loa('LEVEL_2', 'test-rp')
    session[:selected_idp] = { 'entity_id' => 'http://idcorp.com', 'simple_id' => 'stub-idp-one', 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2) }
  end

  subject { get :index, params: { locale: 'en' } }

  it 'renders paused registration page' do
    stub_hub_request = stub_request(:get, "http://api.com:50240/config/transactions/http:%2F%2Fwww.test-rp.gov.uk%2FSAML2%2FMD/display-data").
        to_return(:status => 200, :body => '{"simpleId": "simpleId", "serviceHomepage":"www.example.com"}', :headers => {})
    expect(subject).to render_template(:index)
    expect(stub_hub_request).to have_been_made.once
  end

end