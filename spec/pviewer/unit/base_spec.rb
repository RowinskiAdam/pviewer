require 'spec_helper'

RSpec.describe PViewer::Base do
  let(:app) { double('App', add_notifier: nil) }
  let(:database) { double('Database') }
  let(:server) { double('Server', start: nil, stop: nil) }

  # disable finalize ensuring
  before { allow(Thread).to receive(:new) }

  subject(:base) do
    allow(PViewer::Web::Server).to receive(:new).and_return(server)
    allow(PViewer::Database::Client).to receive(:new).and_return(database)
    allow(PViewer::Web::App).to receive(:new).and_return(app)
    described_class.new({}, logging: false, gui: true)
  end

  context 'default start without gui' do
    it 'creates only database client' do
      expect(PViewer::Database::Client).to receive(:new)
      expect(PViewer::Web::Server).not_to receive(:new)
      described_class.new(logging: false)
    end
  end

  context 'with gui' do
    it 'creates database client, app and starts new server with app' do
      expect(PViewer::Database::Client).to receive(:new)
      expect(PViewer::Web::App).to receive(:new).and_return(app)
      expect(PViewer::Web::Server).to receive(:new)
        .with(kind_of(PViewer::Web::Config), app).and_return(server)
      expect(server).to receive(:start)
      described_class.new({}, logging: false, gui: true)
    end
  end

  shared_examples 'a events handler creator' do |obj_class|
    let(:handler) { double('handler') }
    let(:args) { { database: 'db', measurement: 'events' } }
    let(:expected_args) { args.merge(db_client: database) }
    let(:method) { obj_class.name.split('::').last.downcase + '_handler' }

    it 'returns handler' do
      expect(obj_class).to receive(:new).with(expected_args).and_return(handler)
      expect(base.send(method, args)).to be(handler)
    end
  end

  describe '#durations_handler' do
    it_behaves_like 'a events handler creator', PViewer::Handler::Durations
  end

  describe '#values_handler' do
    it_behaves_like 'a events handler creator', PViewer::Handler::Values
  end

  describe '#counters_handler' do
    it_behaves_like 'a events handler creator', PViewer::Handler::Counters
  end

  describe '#run_gui' do
    context 'server is running' do
      subject { described_class }
      it 'returns false' do
        allow(server).to receive('running?').and_return(true)
        expect(base.run_gui).to be_falsey
      end
    end

    context 'server is not running' do
      let(:config) { double('config') }
      let(:args) { { port: 3001 } }

      before { base.instance_variable_get(:@server).stop }

      it 'starts server' do
        allow(server).to receive('running?').and_return(false)
        expect(server).to receive(:start)
        base.run_gui(args)
      end
    end
  end

  describe '#finalize' do
    it 'calls database finalize' do
      expect(database).to receive(:finalize)
      base.finalize
    end
  end
end
