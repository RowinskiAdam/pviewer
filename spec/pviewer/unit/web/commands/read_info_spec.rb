require 'spec_helper'
require_relative 'shared_command_examples'

RSpec.describe PViewer::Web::Commands::ReadInfo do
  it_behaves_like 'a command', 'read_info'

  describe '#response_command' do
    subject { described_class.new({}).response_command }
    it { is_expected.to be :display_info }
  end

  describe '#execute' do
    let(:database) { double('database', info: {}) }
    let(:app) { double('app', info: { version: PViewer::VERSION }) }
    let(:client) { double('client', send: nil) }

    subject do
      resources = { client: client, app: app, database: database }
      described_class.new({}).execute(resources)
    end

    it 'should get app and database info, and send it to client' do
      expect(app).to receive(:info)
      expect(database).to receive(:info)
      expect(client).to receive(:send)
      subject
    end
  end
end
