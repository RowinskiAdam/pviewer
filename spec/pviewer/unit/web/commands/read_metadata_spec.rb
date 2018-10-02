require 'spec_helper'
require_relative 'shared_command_examples'

RSpec.describe PViewer::Web::Commands::ReadMetadata do
  it_behaves_like 'a command', 'read_metadata'

  let(:arguments) { { database: 'db', measurement: 'ms' } }

  describe '#response_command' do
    subject { described_class.new(arguments).response_command }
    it { is_expected.to be :display_metadata }
  end

  describe '#execute' do
    let(:database) { double('database', metadata: {}) }
    let(:client) { double('client', send: nil) }

    subject do
      described_class.new(arguments).execute(client: client, database: database)
    end

    it 'send to client fetched metadata' do
      expect(database).to receive(:metadata)
        .with(kind_of(PViewer::Database::Series)).and_return('metadata')
      expect(client).to receive(:send)
      subject
    end
  end
end
