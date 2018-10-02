require 'spec_helper'

RSpec.describe PViewer::Database::EventReader do
  let(:database) { 'db_name' }
  let(:measurement) { 'ms_name' }

  let(:db_client) do
    double('base', database_name: 'db_name', write: nil, metadata: nil,
                   'metadata=' => nil, scheme: %w[tag $index])
  end

  let(:response_data) do
    [{
      'name' => 'name',
      'columns' => %w[time ~~event],
      'tags' => { 'tag' => 'tag_val' },
      'values' => [[:timestamp, 1]]
    }]
  end

  subject do
    described_class.new(database: database,
                        measurement: measurement,
                        db_client: db_client)
  end

  it 'returns data without redundant tags' do
    expect(db_client).to receive(:read).with(subject.series, {})
                                       .and_return(response_data)
    expect(subject.read).to eq response_data
  end

  context 'with data reduction' do
    let(:response_data) do
      [{
        'name' => 'name',
        'columns' => %w[time _val_0 _val_1 ~~event],
        'tags' => { 'tag' => 'tag_val' },
        'values' => [[:timestamp, 9, 8, 1]]
      }]
    end

    let(:expected_data) do
      [{
        'name' => 'name',
        'columns' => %w[time val],
        'tags' => { 'tag' => 'tag_val' },
        'values' => [[:timestamp, 17]]
      }]
    end

    subject do
      described_class.new(database: database, measurement: measurement,
                          db_client: db_client, reduce_type: :sum)
    end

    it 'reduces data' do
      expect(db_client).to receive(:read).with(subject.series, {})
                                         .and_return(response_data)
      expect(subject.read).to eq expected_data
    end
  end

  context 'gui format option has been set' do
    let(:response_data) do
      [{
        'name' => 'name',
        'columns' => %w[time _val_0 _val_1 ~~event],
        'tags' => { 'tag' => 'tag_val' },
        'values' => [[:timestamp, 9, 8, 1]]
      }]
    end

    let(:expected_data) do
      [{
        'name' => 'name',
        'columns' => %w[tags val],
        'tags' => { 'tag' => 'tag_val' },
        'values' => [['tag: tag_val', 9]]
      }]
    end

    subject do
      described_class.new(database: database, measurement: measurement,
                          db_client: db_client, reduce_type: :first,
                          gui_format: 'Summary')
    end

    it 'returns data in gui format' do
      expect(db_client).to receive(:read).with(subject.series, {})
                                         .and_return(response_data)

      expect(subject.read).to eq expected_data
    end
  end
end
