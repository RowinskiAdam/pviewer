require 'spec_helper'

RSpec.describe PViewer::Database::Clients::Influx do
  let(:influx) do
    config = object_double(
      InfluxDB::Config.new, database: 'name_1', async: false
    )
    object_double(InfluxDB::Client.new,
                  create_database: Net::HTTPNoContent, config: config)
  end

  let(:response) do
    [{ 'name' => 'databases', 'columns' => ['name'],
       'values' => [['name_1'], ['name_2']] }]
  end

  before :each do
    allow(InfluxDB::Client).to receive(:new).and_return(influx)
    allow(influx).to receive(:query).with('SHOW DATABASES', denormalize: false)
                                    .and_return(response)
  end

  subject(:database) { described_class.new }

  describe '#to_s' do
    it 'returns string that contains database name' do
      expect(database.to_s).to match /InfluxDB/
    end
  end

  describe '#write' do
    subject { database.write([PViewer::Database::Point.new('test', x: 5)]) }

    context 'valid entry data' do
      it 'returns true' do
        expect(influx).to receive(:write_points)
          .and_return(Net::HTTPNoContent.new(nil, 204, nil))
        expect(subject).to be_truthy
      end
    end

    context 'invalid entry data' do
      it 'raises error' do
        allow(influx).to receive(:query).and_return(['values' => ['name_1']])
        expect(influx).to receive(:write_points).and_raise(InfluxDB::Error)
        expect { subject }.to raise_error(PViewer::Database::WriteError)
      end
    end
  end

  describe '#exists?' do
    context 'database exists' do
      subject { database.exists?('name_1') }

      it do
        allow(influx).to receive(:query).and_return(response)
        is_expected.to be_truthy
      end
    end

    context 'database not exists' do
      subject { database.exists?('not_exists') }

      it do
        allow(influx).to receive(:query).and_return(response)
        is_expected.to be_falsey
      end
    end
  end

  describe '#scheme' do
    subject { database.scheme(database: 'test') }

    it 'returns array with names' do
      allow(influx).to receive(:query).and_return(response)
      expect(subject).to be_a(Array).and include('name_1', 'name_2')
    end
  end

  describe '#read' do
    subject { database.read(database: '_default', measurement: 'test') }

    it 'returns hash with data' do
      allow(influx).to receive(:query)
        .and_return(['values' => [], 'columns' => []])
      expect(subject).to be_a(Array).and include(kind_of(Hash))
    end
  end

  describe '#database_name=' do
    let(:db_name) { 'new name' }
    subject { database.database_name = db_name }

    it 'set new database name' do
      expect(influx.config).to receive(:database=).with(db_name).and_return(db_name)
      expect(subject).to eq db_name
    end
  end

  describe '#database_name' do
    subject { database.database_name }

    it 'returns database name' do
      expect(influx.config).to receive(:database).and_return('_default')
      expect(subject).to eq 'name_1'
    end
  end

  describe '#drop_measurement' do
    subject { database.drop_measurement(database: 'db', measurement: 'ms') }
    it 'drops measurement' do
      expect(influx).to receive(:query).with('DROP MEASUREMENT "ms"', database: 'db')
      subject
    end
  end
end
