require 'spec_helper'
require_relative 'shared_command_examples'

RSpec.describe PViewer::Web::Commands::ReadData do
  it_behaves_like 'a command', 'read_data'

  let(:arguments) do
    { database: 'db_name', measurement: 'measurement_name',
      tags:  { tag: ['water'] }, time: '2015-08-18T00:12:00Z' }
  end

  describe '#response_command' do
    subject { described_class.new(arguments).response_command }
    it { is_expected.to be :display_data }
  end

  describe '#execute' do
    let(:data) do
      [{ 'columns' => {}, 'values' => [['2015-08-18T00:12:00Z', 2]] }]
    end
    let(:database) { double('database', read: data) }
    let(:client) { double('client', send: nil) }
    let(:reader) { double('reader') }

    subject do
      described_class.new(arguments).execute(client: client, database: database)
    end

    it 'creates series reader, adds it to client and send retrieved data' do
      expect(database).to receive(:event_reader).and_return(reader)
      expect(reader).to receive(:read).and_return(data)
      #expect(client).to receive(:add_reader).with(reader)
      subject
    end
  end
end
