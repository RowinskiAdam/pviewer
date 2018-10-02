require 'spec_helper'

RSpec.describe PViewer::Database::Client do



  describe '#series_writer' do
    let(:db_client) { double('database').as_null_object }
    let(:series_writer) { double('SeriesWriter').as_null_object }

    subject { described_class.new('test', {}).series_writer }

    it 'returns series writer instance' do
      allow_any_instance_of(described_class).to receive(:new_client)
        .and_return(db_client)
      allow(PViewer::Database::SeriesWriter).to receive(:new)
        .and_return(series_writer)
      expect_any_instance_of(described_class).to receive(:series_writer)
        .and_return(series_writer)
      is_expected.to be series_writer
    end
  end

  let(:reader_hash) do
    { database: 'db', measurement: 'ms', db_client: db_client }
  end

  let(:db_client) { double('database').as_null_object }

  describe '#series_reader' do
    subject { described_class.new('test', {}).series_reader }

    it 'returns series writer instance' do
      allow_any_instance_of(described_class).to receive(:new_client)
        .and_return(db_client)
      expect_any_instance_of(described_class).to receive(:series_reader)
        .and_return(PViewer::Database::SeriesReader.new(reader_hash))
      is_expected.to be_a(PViewer::Database::SeriesReader)
    end
  end

  describe '#event_writer' do
    let(:writer) { double('EventWriter').as_null_object }

    subject { described_class.new('test', {}).event_writer }

    it 'returns series writer instance' do
      allow_any_instance_of(described_class).to receive(:new_client)
        .and_return(db_client)
      allow(PViewer::Database::EventWriter).to receive(:new)
        .and_return(writer)
      expect_any_instance_of(described_class).to receive(:event_writer)
        .and_return(writer)
      is_expected.to be writer
    end
  end

  describe '#event_reader' do

    subject { described_class.new('test', {}).event_reader }

    it 'returns series writer instance' do
      allow_any_instance_of(described_class).to receive(:new_client)
        .and_return(db_client)
      expect_any_instance_of(described_class).to receive(:event_reader)
        .and_return(PViewer::Database::EventReader.new(reader_hash))
      is_expected.to be_a(PViewer::Database::EventReader)
    end
  end

  describe '#finalize' do
    let(:writer1) { double('writer1') }
    let(:writer2) { double('writer2') }

    subject do
      client = described_class.new('test', {})
      described_class.class_variable_set(:@@writers, [writer1, writer2])
      allow(client).to receive(:sleep)
      client
    end

    it 'finalize each writer' do
      allow_any_instance_of(described_class).to receive(:new_client)
        .and_return(db_client)
      expect(writer1).to receive(:finalize)
      expect(writer2).to receive(:finalize)
      subject.finalize
    end
  end
end
