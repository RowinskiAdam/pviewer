require 'spec_helper'

RSpec.describe PViewer::Web::Server do
  let(:app) { double('app') }
  let(:config) { PViewer::Web::Config.new(logging: false) }
  let(:thin_server) { double('thin', 'daemonize=' => nil) }

  subject do
    allow(Thin::Server).to receive(:new).and_return(thin_server)
    described_class.new(config, app)
  end

  it 'loads faye websocket thin adapter' do
    expect(Faye::WebSocket).to receive(:load_adapter).with('thin')
    subject
  end

  describe '#start' do
    it 'starts server' do
      allow(Thread).to receive(:new) { thin_server.start }
      expect(thin_server).to receive(:start)
      subject.start
    end
  end

  describe '#stop' do
    it 'stops server' do
      expect(thin_server).to receive(:stop)
      subject.stop
    end
  end

end
