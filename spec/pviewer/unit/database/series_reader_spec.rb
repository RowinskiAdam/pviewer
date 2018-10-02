require 'spec_helper'

RSpec.describe PViewer::Database::SeriesReader do
  let(:data) { { 'values' => [['2015-08-18T00:12:00Z']] } }
  let(:db_client) { double('db_client', read: data) }

  subject(:series_reader) do
    described_class.new(database: 'db', measurement: 'ms',
                        resample: 5, db_client: db_client) do |data|
      data
    end
  end

  describe '#read' do
    subject do
      described_class.new(database: 'db', measurement: 'ms',
                          db_client: db_client) do |data|
        data
      end
    end

    context 'without options' do
      it 'calls database read and returns data' do
        expect(db_client).to receive(:read).with(subject.series, {})
        expect(subject.read).to eq data
      end
    end

    context 'with options' do
      it 'calls database read and returns data' do
        expect(db_client).to receive(:read).with(subject.series, {epoch: 'u'})
        expect(subject.read(epoch: 'u')).to eq data
      end
    end
  end

  describe '#==' do
    context 'same series' do
      subject { series_reader == series_reader }

      it { is_expected.to be_truthy }
    end

    context 'different series' do
      subject do
        diff = described_class.new(database: 'diff', measurement: 'ms',
                                   db_client: db_client)
        series_reader == diff
      end

      it { is_expected.to be_falsey }
    end
  end

  describe '#eql?' do
    context 'same series' do
      subject { series_reader.eql? series_reader }

      it { is_expected.to be_truthy }
    end

    context 'different series' do
      subject do
        diff = described_class.new(database: 'db', measurement: 'another',
                                   db_client: db_client)
        series_reader.eql? diff
      end

      it { is_expected.to be_falsey }
    end
  end
end
