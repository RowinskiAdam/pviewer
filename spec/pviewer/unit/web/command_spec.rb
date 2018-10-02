require 'spec_helper'

RSpec.describe PViewer::Web::Command do
  subject(:command) do
    described_class.new(:log, type: :info, message: 'message')
  end

  context 'command exists' do
    let(:cmd_const) { PViewer::Web::Commands::Log }
    it 'create specified command' do
      expect(subject).to be_an_instance_of(cmd_const)
    end
  end

  context 'command not exists' do
    subject { described_class.new(:unknown, {}) }

    it 'raises error uknown command' do
      expect { subject }.to raise_error(PViewer::UnknownCommand)
    end
  end

  describe '.command_exists?' do
    context 'when exists' do
      subject { described_class.command_exists?('Log') }
      it { is_expected.to be_truthy }
    end
    context 'when not exists' do
      subject { described_class.command_exists?('CamelNotation') }
      it { is_expected.to be_falsey }
    end
  end

  describe '.camel_to_snake_notation' do
    subject { described_class.camel_to_snake_notation('imSnakeNow') }
    it { is_expected.to eq 'im_snake_now' }
  end

  describe '.snake_to_camel_notation' do
    subject { described_class.snake_to_camel_notation('im_camel_now') }
    it { is_expected.to eq 'ImCamelNow' }
  end
end
