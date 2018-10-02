require 'spec_helper'

RSpec.describe PViewer do
  before do
    # disable finalize ensuring
    allow(Thread).to receive(:new)
    allow(PViewer::Database::Client).to receive(:new)
  end

  it 'has a version number' do
    expect(PViewer::VERSION).not_to be nil
  end

  describe '.init' do
    let(:app_conf) { { logging: false } }
    let(:db_conf) { { database: 'db_name' } }

    it 'create new PViewer' do
      expect(PViewer::Base).to receive(:new).with(db_conf, app_conf)
      PViewer.init(db_conf, app_conf)
    end
  end

  shared_examples 'a events handler caller' do |handler_type|
    let(:args) { { database: 'db' } }
    let(:expected) { { database: 'db', measurement: 'events' } }
    let(:handler) { double('handler') }
    let(:method) { handler_type.to_s.gsub('_handler', '').to_sym }

    it 'calls base #events handler' do
      expect_any_instance_of(PViewer::Base).to receive(handler_type)
        .with(expected).and_return(handler)
      expect(subject.send(method, 'events', args)).to be(handler)
    end
  end

  describe '.durations' do
    it_behaves_like 'a events handler caller', :durations_handler
  end

  describe '.values' do
    it_behaves_like 'a events handler caller', :values_handler
  end

  describe '.counters' do
    it_behaves_like 'a events handler caller', :counters_handler
  end

  describe '.finalize' do
    it 'calls base #finalize' do
      expect_any_instance_of(PViewer::Base).to receive(:finalize)
      subject.finalize
    end
  end

  describe '.initialized?' do
    context 'is initialized' do
      subject { described_class.init }
      it { is_expected.to be_truthy }
    end

    context 'not initialized' do
      subject { described_class }
      it { is_expected.to be_truthy }
    end
  end

  describe '.run_gui' do
    let(:args) { { port: 3001 } }
    subject { described_class.init }

    it 'calls base #run_gui with args' do
      expect_any_instance_of(PViewer::Base).to receive(:run_gui).with(args)
      expect_any_instance_of(PViewer::Base).to receive(:finalize)
      subject.run_gui(args)
    end
  end
end
