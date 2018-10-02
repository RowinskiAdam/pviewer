RSpec.shared_examples 'a command' do |cmd_name|
  let(:possible_args) do
    {
      basic: {},
      log: { type: :info, message: 'message' },
      read_info: {},
      read_data: { database: 'db_name', measurement: 'measurement_name',
                   tags:  { tag: ['water'] } },
      read_scheme: { database: 'db_name' },
      read_metadata: { database: 'db', measurement: 'ms' },
      reduction_types: {}
    }
  end
  let(:arguments) { possible_args[cmd_name.to_sym] }

  subject(:command) { described_class.new(arguments) }

  it { is_expected.to respond_to(:execute) }

  context 'required argument is not specified' do
    let(:required_args) { described_class::REQUIRED_ARGS }

    subject { described_class.new(arguments.except!(required_args.first)) }

    it 'raise error' do
      unless required_args.empty?
        expect { subject }
          .to raise_error(PViewer::Web::Commands::ArgumentMissing)
      end
    end
  end

  context 'argument type is invalid' do
    subject { described_class.new(arguments) }

    before { arguments.transform_values! { |_| double('fake') } }

    it 'raise error' do
      unless arguments.empty?
        expect { subject }.to raise_error(PViewer::InvalidType)
      end
    end
  end

  describe '#to_hash' do
    subject { command.to_h }

    it { is_expected.to include(command: cmd_name, arguments: arguments) }
  end

  describe '#name' do
    subject { command.name }

    it { is_expected.to match cmd_name }
  end

  describe '#arguments' do
    subject { command.arguments }

    it { is_expected.to include(arguments) }
  end
end
