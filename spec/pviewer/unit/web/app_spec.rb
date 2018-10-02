require 'spec_helper'

RSpec.describe PViewer::Web::App do
  let(:http_env) do
    { 'HTTPS' => 'on',
      'rack.url_scheme' => 'https',
      'HTTP_HOST' => 'localhost',
      'PATH_INFO' => 'none',
      'QUERY_STRING' => '' }
  end

  let(:socket_env) do
    { 'HTTPS' => 'on',
      'rack.url_scheme' => 'https',
      'HTTP_HOST' => 'localhost',
      'PATH_INFO' => 'none',
      'QUERY_STRING' => '',
      'HTTP_CONNECTION' => 'upgrade',
      'REQUEST_METHOD' => 'GET',
      'HTTP_UPGRADE' => 'websocket' }
  end

  let(:database) { object_double('database') }
  let(:client) { instance_double(PViewer::Web::Client) }
  let(:command) { object_double('command') }

  subject(:app) do
    described_class.new(PViewer::Web::Config.new, database)
  end

  it { is_expected.to respond_to(:call).with(1).argument }

  describe '#call' do
    context 'HTTP request' do
      subject { app.call(http_env) }
      it {
        is_expected.to match [200, { 'Content-Type' => 'text/html' },
                              /html/]
      }
    end
    context 'socket request' do
      it 'adds new client and returns rack response' do
        expect(PViewer::Web::Client).to receive(:new).and_return(client)
        expect(client).to receive(:rack_response).and_return([-1, {}, []])
        expect(app.call(socket_env)).to eq [-1, {}, []]
      end
    end
  end

  describe '#execute' do
    let(:command) { double('command') }
    it 'executes the command by providing resources' do
      expect(command).to receive(:execute).with(kind_of(Hash))
      app.execute(double('client'), command)
    end
  end

  describe '#info' do
    subject { app.info }
    it { is_expected.to be_a(Hash) }
  end

  describe '#remove_client' do
    let(:app_clients) { app.instance_variable_get(:@resources)[:clients] }

    before { app_clients.push(client) }

    it 'removes client from app resources' do
      app.remove_client(client)
      expect(app_clients).not_to include(client)
    end
  end
end
