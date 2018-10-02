require 'spec_helper'

RSpec.describe PViewer::Database::SeriesWriter do
  let(:db_client) do
    double('base', database_name: 'db_name', write: nil,
                   metadata: nil, 'metadata=' => nil)
  end

  subject(:series_writer) do
    described_class.new(measurement: 'series', db_client: db_client)
  end

  context 'initialized without block' do
    it 'has standard method add' do
      expect(db_client).to receive(:write)
        .with([instance_of(PViewer::Database::Point)], database: 'db_name')
      expect(db_client).to receive(:metadata)
      series_writer.add(x: 5)
    end
  end

  context 'initialized with block' do
    subject(:gs) do
      described_class.new(measurement: 'series', db_client: db_client) do |data|
        data.each do |e|
          point e[:value], time: e[:time]
        end
        write
      end
    end

    it 'has custom method add' do
      expect(db_client).to receive(:write)
        .with([kind_of(PViewer::Database::Point)], database: 'db_name')
      expect(db_client).to receive(:metadata)

      subject.add([{ value: { x: 7 }, time: '2018-03-18T00:12:00Z' }])
    end
  end

  describe '#metadata=' do
    subject { series_writer.metadata = 'text' }

    it 'calls database client metadata' do
      expect(db_client).to receive(:metadata=).with(series_writer.series)
      subject
    end
  end

  let(:series_dup) { series_writer.dup }

  describe '#add' do
    subject { series_writer.add(x: 5) }

    it 'duplicate object calls write_data' do
      expect(db_client).to receive(:write)
        .with([kind_of(PViewer::Database::Point)], database: 'db_name')
      expect(series_writer).to receive(:dup).and_call_original
      expect_any_instance_of(described_class).to receive(:instance_variable_set)
        .with(:@points, []).and_call_original
      subject
    end
  end

  describe '#dup' do
    subject { series_writer.dup }
    it 'duplicate object and set instance variable points as empty array' do
      expect_any_instance_of(Object).to receive(:dup).and_return(series_dup)
      expect(series_dup).to receive(:instance_variable_set).with(:@points, [])
                                                           .and_call_original
      expect(subject).to eq series_dup
    end
  end
end
