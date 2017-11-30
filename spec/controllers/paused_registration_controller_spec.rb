require 'rails_helper'
require 'controller_helper'
require 'spec_helper'
require 'api_test_helper'

describe PausedRegistrationController do
  before(:each) do
    session[:selected_idp] = { 'entity_id' => 'http://idcorp.com', 'simple_id' => 'stub-idp-one', 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2) }
    set_session_and_cookies_with_loa('LEVEL_2', 'test-rp')
  end

  subject { get :index, params: { locale: 'en' } }

  it 'renders paused registration page' do
    stub_hub_request = stub_request(:get, 'http://api.com:50240/config/transactions/http:%2F%2Fwww.test-rp.gov.uk%2FSAML2%2FMD/display-data').
        to_return(status: 200, body: '{"simpleId": "simpleId", "serviceHomepage":"www.example.com"}')
    expect(subject).to render_template(:with_user_session)
    expect(stub_hub_request).to have_been_made.once
  end

  it 'should render paused registration without session page when there is no transaction name' do
    session.delete(:transaction_simple_id)

    expect(subject).to render_template(:without_user_session)
  end

  it 'should render paused registration without session page when there is no transaction homepage' do
    stub_hub_request = stub_request(:get, 'http://api.com:50240/config/transactions/http:%2F%2Fwww.test-rp.gov.uk%2FSAML2%2FMD/display-data').
        to_return(status: 200, body: '{"simpleId": "simpleId"}')
    expect(subject).to render_template(:without_user_session)
    expect(stub_hub_request).to have_been_made.once
  end

  it 'should render paused registration without session page when there is no idp selected' do
    session.delete(:selected_idp)

    stub_hub_request = stub_request(:get, 'http://api.com:50240/config/transactions/http:%2F%2Fwww.test-rp.gov.uk%2FSAML2%2FMD/display-data').
        to_return(status: 200, body: '{"simpleId": "simpleId", "serviceHomepage":"www.example.com"}')
    expect(subject).to render_template(:without_user_session)
    expect(stub_hub_request).to have_been_made.once
  end
end
