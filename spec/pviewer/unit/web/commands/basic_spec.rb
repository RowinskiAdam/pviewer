require 'spec_helper'
require_relative 'shared_command_examples'

RSpec.describe PViewer::Web::Commands::Basic do
  it_behaves_like 'a command', 'basic'

  describe '#response_command' do
    subject { described_class.new.response_command }
    it { is_expected.to be nil }
  end

  describe '#execute' do
    subject do
      described_class.new.execute(app: nil, client: nil)
    end
    it 'raise error' do
      expect { subject }.to raise_error(PViewer::AbstractMethod)
    end
  end
end