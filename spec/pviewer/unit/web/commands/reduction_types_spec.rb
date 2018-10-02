require 'spec_helper'
require_relative 'shared_command_examples'

RSpec.describe PViewer::Web::Commands::ReductionTypes do
  it_behaves_like 'a command', 'reduction_types'

  let(:client) { double('client', send: nil) }
  it 'sends to client reduction types' do
    expect(client).to receive(:send)
      .with(instance_of(PViewer::Web::Message))
    expect(PViewer::Database::ReductionTypes)
      .to receive(:public_instance_methods).and_return([:min, :max])
    described_class.new({}).execute(client: client)
  end
end
