require 'spec_helper'

RSpec.describe PViewer::Database::Clients::InfluxQL::Scheme do
  let(:syntax_array) do
    [
      'SHOW DATABASES',
      'SHOW MEASUREMENTS ON "%<database>s"',
      'SHOW TAG KEYS ON "%<database>s" FROM "%<measurement>s"',
      'SHOW TAG VALUES ON "%<database>s" FROM "%<measurement>s"' \
        ' WITH KEY = "%<tag>s"',
      'SHOW FIELD KEYS ON  "%<database>s" FROM "%<measurement>s"'
    ]
  end

  let!(:opts) do
    {
      database: 'database',
      measurement: 'measurement',
      tag: 'tag',
      field: 'field'
    }
  end

  subject { described_class.new(opts) }

  describe 'to_s' do
    context 'any valid option' do
      subject { described_class.new.to_s }

      it 'returns influxQL with show databases' do
        is_expected.to eq syntax_array[0]
      end
    end

    context 'one option is valid' do
      let!(:one_opt) { opts.except!(:measurement, :tag, :field) }

      subject { described_class.new(one_opt).to_s }

      it 'returns influxQL with show measurements' do
        is_expected.to eq syntax_array[1] % one_opt
      end
    end

    context 'two options are valid' do
      let!(:two_opts) { opts.except!(:tag, :field) }

      subject { described_class.new(two_opts).to_s }

      it 'returns influxQL with show tags' do
        is_expected.to eq(syntax_array[2] % two_opts)
      end
    end
    context 'three options are valid' do
      let!(:three_opts) { opts.except!(:field) }

      subject { described_class.new(three_opts).to_s }

      it 'returns influxQL with show tag values' do
        is_expected.to eq(syntax_array[3] % three_opts)
      end
    end
    context 'field option was specified' do
      subject { described_class.new(opts).to_s }

      it 'returns influxQL with show field keys' do
        is_expected.to eq(syntax_array[4] % opts)
      end
    end
  end
end
