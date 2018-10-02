require 'spec_helper'

RSpec.describe PViewer::Database::EventWriter do
  let(:database) { 'db_name' }
  let(:measurement) { 'ms_name' }
  let(:writers) { [] }

  let(:db_client) do
    double('client', database_name: 'db_name', write: nil, metadata: nil,
                     'metadata=' => nil, drop_measurement: nil, writers: writers)
  end

  subject do
    described_class.new(database: database, measurement: measurement,
                        db_client: db_client)
  end

  it 'writes event to database' do
    expect(db_client).to receive(:write)
      .with([instance_of(PViewer::Database::Point)], database: 'db_name')

    subject.add(tags: { tag: 5 }, time: 0)
    subject.add(tags: { tag: 5 }, time: 1)
  end

  it 'handles with arrays' do
    expect(subject.send(:arrays_to_fields, [1, 2]))
      .to eq('_values_0' => 1, '_values_1' => 2)
  end

  it 'handles with hash' do
    expect(subject.send(:hash_to_fields, values: [1, 2], x: 3))
      .to eq(_values_0: 1, _values_1: 2, x: 3)
  end

  context 'as experiments handler' do
    subject do
      described_class.new(database: database, measurement: measurement,
                          db_client: db_client, experiments: true)
    end
    it 'allow to set up experiments' do
      allow(db_client).to receive(:scheme).and_return(['key', 0])
      expect(PViewer::Database::Point).to receive(:new)
        .with(measurement, { values: 1, '~~event' => 1 },
              tags: { '$index' => 0, 'exn' => 1 }, time: 2)
      subject
      subject.add(values: 1, time: 2)
    end
  end
end
