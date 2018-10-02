require 'spec_helper'

RSpec.describe PViewer::Web::Client do
  let(:app) { double(PViewer::Web::App) }
  let(:socket) { double('socket', on: nil, rack_response: [-1, {}, []]) }
  let(:message) do
    cmd = PViewer::Web::Command.new(:read_scheme, database: 'db_name')
    PViewer::Web::Message.new([cmd])
  end

  subject(:client) do
    env = { 'HTTPS' => 'on',
            'rack.url_scheme' => 'https',
            'HTTP_HOST' => 'localhost',
            'PATH_INFO' => 'none',
            'QUERY_STRING' => '',
            'HTTP_CONNECTION' => 'upgrade',
            'REQUEST_METHOD' => 'GET',
            'HTTP_UPGRADE' => 'websocket' }

    allow(Faye::WebSocket).to receive(:new).and_return(socket)
    described_class.new(app, env)
  end

  it 'register websocket events' do
    expect(socket).to receive(:on).with(:close)
    expect(socket).to receive(:on).with(:message)
    client
  end

  describe '#send' do
    it 'calls send on websocket' do
      expect(socket).to receive(:send).with(message.to_json)
      client.send(message)
    end
  end

  let(:reader) do
    client = double('client').as_null_object
    hash = { database: 'db',
             measurement: 'ms',
             time: '2015-08-18T00:12:00Z' }

    PViewer::Database::SeriesReader.new(hash.merge(db_client: client))
  end

  describe '#rack_response' do
    it 'returns rack response' do
      expect(client.rack_response).to eq [-1, {}, []]
    end
  end
end
