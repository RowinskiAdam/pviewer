require 'spec_helper'

RSpec.describe PViewer::Web::Client do
  let(:app) { double(PViewer::Web::App) }

  subject do
    env = { 'HTTPS' => 'on',
            'rack.url_scheme' => 'https',
            'HTTP_HOST' => 'localhost',
            'PATH_INFO' => 'none',
            'QUERY_STRING' => '',
            'HTTP_CONNECTION' => 'upgrade',
            'REQUEST_METHOD' => 'GET',
            'HTTP_UPGRADE' => 'websocket' }

    described_class.new(app, env)
  end

  after(:each) { EventMachine::stop_event_loop }

  it { is_expected.to respond_to(:send) }

  describe 'websocket response' do

    it 'returns appropriate array' do
      expect(subject.rack_response).to eq [ -1, {}, [] ]
    end
  end

end
