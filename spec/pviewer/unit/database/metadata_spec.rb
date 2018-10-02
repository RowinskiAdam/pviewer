require 'spec_helper'

RSpec.describe PViewer::Database::Metadata do
  subject(:metadata) { described_class.new('_test') }

  before { metadata }

  let!(:series) do
    PViewer::Database::Series.new(database: 'db_name', measurement: 'ms_name',
                                metadata: { some: 'metadata', another: 'data' })
  end

  describe '#add' do
    subject { metadata.add(series) }

    it 'write new metadata to file' do
      expect(File).to receive(:open).twice.and_call_original
      expect_any_instance_of(File).to receive(:write).and_call_original
      expect(subject).to eq "some: metadata\nanother: data"
    end
  end

  describe '#read' do
    before { metadata.add(series) }

    subject { metadata.read(series) }

    it 'returns metadata' do
      expect(subject).to eq "some: metadata\nanother: data"
    end
  end
end
