require 'spec_helper'

RSpec.describe PViewer::Database::Clients::Influx do
  let(:test_db) { 'test_database' }
  let(:test_ms) { 'test_measurement' }
  let(:point) { PViewer::Database::Point.new(test_ms, {x: 2}, tags: { y: 2 }, time: 33) }
  let(:series) { PViewer::Database::Series.new(database: test_db, measurement: test_ms) }
  let(:influx) { InfluxDB::Client.new }

  subject { described_class.new(database: test_db, epoch: 'u', async: false) }

  after(:each) { influx.delete_database(test_db) }

  describe 'data storing' do
    context 'data exists' do

      before { subject.write([point]) }

      it 'write data to test database and measurement' do
        expect(subject.read(series)).to include(
          { "name"=>"test_measurement", "columns"=>["time", "x"], "values"=>[[33, 2]] }
        )
      end
    end

    context 'data not exists' do
      it 'write data to test database and measurement' do
        expect(subject.read(series)).to eq []
      end
    end
  end

  describe 'scheme explore' do
    it 'returns array with created database' do
      expect(subject.scheme).to include(test_db)
    end

    before { subject.write([point]) }

    it 'returns array with created measurements' do
      expect(subject.scheme(database: test_db)).to include(test_ms)
    end

    it 'returns array with tags' do
      expect(subject.scheme(database: test_db, measurement: test_ms)).to eq ['y']
    end
  end

  describe 'config is available' do
    it 'reads config attrs' do
      expect(subject.database_name).to eq test_db
      expect(subject.async?).to be_falsey
    end
  end


end
