require 'spec_helper'

RSpec.describe PViewer::Web::App do
  def new_server(app)
    Faye::WebSocket.load_adapter('thin')
    Thin::Logging.level = :warn
    Thin::Server.new('localhost', 3790, app)
  end

  describe '#call' do
    before :all do
      db = double('database')
      @app = described_class.new(PViewer::Web::Config.new, db)
      @server = new_server(@app)
      Thread.new {@server.start}
    end

    context 'when HTTP request' do
      let(:uri) {URI('http://localhost:3790')}
      let!(:response) do
        Net::HTTP.get_response(uri)
      end
      it 'returns html in string instance and code 200' do
        expect(response.body).to be_an_instance_of(String)
        expect(response.code).to eq '200'
      end
    end


    context 'when web socket request' do
      let(:client_double) { instance_double(PViewer::Web::Client) }
      it 'creates new websocket connection' do
        expect(PViewer::Web::Client).to receive(:new).and_return(client_double)
        allow(client_double).to receive(:send)
        expect(client_double).to receive(:rack_response)
        Faye::WebSocket::Client.new('ws://localhost:3790')
        sleep 0.1
      end
    end

    after :all do
      @server.stop!
    end
  end
end
