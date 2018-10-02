require 'spec_helper'

RSpec.describe PViewer::Database::Clients::InfluxQL::Data do
  let(:args) do
    { database: 'db', measurement: 'measurement',
      tags: { x: [1], y: [2] } }
  end

  subject { described_class.new }

  describe '#to_s' do
    context 'without group_by' do
      let(:expected_query_syntax) do
        format('SELECT *::field FROM "db".."%<measurement>s" WHERE ' \
                "\"x\" = '1' and \"y\" = '2'", args)
      end

      subject { described_class.new(args).to_s }

      it 'returns valid influxQL syntax' do
        is_expected.to eq expected_query_syntax
      end
    end

    context 'with group_by' do
      let(:expected_query_syntax) do
        format('SELECT MEAN(*) FROM "%<database>s".."%<measurement>s" WHERE ' \
        "\"x\" = '1' and \"y\" = '2' GROUP BY \"tag\"", args)
      end

      subject do
        args.merge!(aggregate_function: 'MEAN', group_by: 'tag')
        described_class.new(args).to_s
      end

      it 'syntax include aggregate function and group_by statement' do
        is_expected.to eq expected_query_syntax
      end
    end

    context 'with regex selector' do
      let(:expected_query_syntax) do
        format('SELECT /^[^__].*/ FROM "%<database>s".."%<measurement>s"' \
        " WHERE \"x\" = '1' and \"y\" = '2'", args)
      end

      subject do
        args[:selector] = '/^[^__].*/'
        described_class.new(args).to_s
      end

      it 'syntax include aggregate function and group_by statement' do
        is_expected.to eq expected_query_syntax
      end
    end

    context 'with time' do
      let(:expected_query_syntax) do
        format('SELECT *::field FROM "%<database>s".."%<measurement>s" WHERE ' \
        "\"x\" = '1' and \"y\" = '2' and time > '2016-09-28T01:02:05Z'", args)
      end

      subject do
        args[:time] = '2016-09-28T01:02:05Z'
        described_class.new(args).to_s
      end

      it 'returns valid influxQL syntax with time' do
        is_expected.to eq expected_query_syntax
      end
    end
  end

  describe '#update_time' do
    let(:time) { '2016-09-28T01:02:05Z' }
    let(:expected_query_syntax) do
      format('SELECT *::field FROM "%<database>s".."%<measurement>s" WHERE ' \
              "\"x\" = '1' and \"y\" = '2' and time > '#{time}'", args)
    end

    subject { described_class.new(args).update_time(time).to_s }

    it 'returns valid influxQL syntax with updated time' do
      is_expected.to eq expected_query_syntax
    end
  end
end
