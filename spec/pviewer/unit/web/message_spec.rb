require 'spec_helper'

RSpec.describe PViewer::Web::Message do
  let(:message_init) do
    { commands: [{ name: :read_scheme,
                   arguments: { database: 'db_name' } }] }
  end
  let(:command) do
    PViewer::Web::Command.new(:read_scheme, database: 'db_name')
  end

  subject(:message) { described_class.new(message_init) }

  context 'initialized by json' do
    context 'valid json' do
      it do
        is_expected.to have_attributes(
          commands: [kind_of(PViewer::Web::Commands::ReadScheme)]
        )
      end
    end
    context 'invalid json' do
      subject { described_class.new('=> not json') }

      it 'makes self as error message' do
        json = {
          commands:
                   [{ command: 'log',
                      arguments: { type: 'error', message: 'Invalid JSON.' } }]
        }
        expect(subject.to_json).to include_json(json)
      end
    end
  end

  context 'initialized with commands' do
    subject { described_class.new([command]) }

    it 'makes self as error message' do
      json = {
        commands: [{ command: 'read_scheme', arguments: { database: 'db_name' } }]
      }
      expect(subject.to_json).to include_json(json)
    end
  end

  describe '#to_hash' do
    subject { message.to_h }
    it { is_expected.to include(:commands) }
  end

  describe '#to_json' do
    subject { message.to_json }
    it do
      json = { commands: [{ command: 'read_scheme',
                            arguments: { database: 'db_name' } }] }
      is_expected.to be_an_instance_of(String).and include_json(json)
    end
  end
end
