require 'spec_helper'
require_relative 'shared_command_examples'

RSpec.describe PViewer::Web::Commands::ReadScheme do
  it_behaves_like 'a command', 'read_scheme'

  describe '#response_command' do
    subject { described_class.new.response_command }
    it { is_expected.to be :display_scheme }
  end

  describe '#execute' do
    let(:database) { double('database', scheme: ['name1']) }
    let(:client) { double('client', send: nil) }

    subject do
      resources = { client: client, database: database }
      described_class.new({}).execute(resources)
    end

    it 'read data from database and send it' do
      expect(database).to receive(:scheme).with({})
      expect(client).to receive(:send)
      subject
    end
  end
end
