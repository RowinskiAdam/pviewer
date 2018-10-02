require 'spec_helper'

RSpec.describe PViewer::Handler::Counters do
  let(:db_client) { double('db') }
  let(:event_writer) { double('writer', add: nil) }
  let(:event_reader) { double('reader', read: nil) }

  subject(:counters) do
    args = { database: 'db', measurement: 'events', db_client: db_client }

    allow(db_client).to receive(:event_reader).and_return(event_reader)
    allow(db_client).to receive(:event_writer).and_return(event_writer)

    described_class.new(args)
  end

  let(:expected_args) do
    { database: 'db', measurement: 'events [counters]', db_client: db_client }
  end

  it 'creates new reader and writer with suffix' do
    expect(db_client).to receive(:event_reader).with(expected_args)
    expect(db_client).to receive(:event_writer).with(expected_args)
    counters
  end

  it 'allows to read counter events' do
    expect(event_reader).to receive(:read)
    counters.read
  end

  it 'allows to write counter events' do
    expect(event_writer).to receive(:add)
    counters.write
  end
end
