require 'spec_helper'

RSpec.describe PViewer::Database::Series do
  let(:init_hash) do
    { database: 'db_name', measurement: 'ms_name', metadata: 'metadata' }
  end
  subject(:series) { described_class.new(init_hash) }

  it 'has specified attributes' do
    is_expected.to have_attributes(init_hash.reject { |e| e == :resample })
  end

  describe '#==' do
    context 'when series are same' do
      subject { series == described_class.new(init_hash) }
      it { is_expected.to be_truthy }
    end

    context 'when series are different' do
      subject { series == described_class.new(init_hash.merge(tags: [x: 5])) }
      it { is_expected.to be_falsey }
    end
  end

  describe 'eql?' do
    context 'when series are same' do
      subject { series.eql? described_class.new(init_hash) }
      it { is_expected.to be_truthy }
    end

    context 'when series are different' do
      subject do
        series.eql? described_class.new(init_hash.merge(measurement: 'another'))
      end

      it { is_expected.to be_falsey }
    end
  end

  describe '#to_h' do
    subject { series.to_h }
    it 'returns hash with all instance variables' do
      is_expected.to eq(init_hash)
    end
  end
end
