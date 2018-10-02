require 'spec_helper'
require_relative 'shared_command_examples'

RSpec.describe PViewer::Web::Commands::Log do
  it_behaves_like 'a command', 'log'

  describe '#execute' do
    let(:client) { double('client', send: nil) }
    let(:arguments) {  { type: :info, message: 'message' } }

    context 'client was specified' do
      subject { described_class.new(arguments).execute(client: client) }

      it 'send message to client' do
        expect(client).to receive(:send)
          .with(instance_of(PViewer::Web::Message))
        subject
      end
    end
  end

end
