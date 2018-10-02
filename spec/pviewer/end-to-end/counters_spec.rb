require 'spec_helper'

RSpec.describe PViewer do
  subject {PViewer.counters}

  before do
    PViewer.init(
        time_precision: 'u',
        database: 'test_database',
        measurement: 'test_measurement',
        metadata: 'First experiment with simple model. Routes: 3',
        async: false,
        disable_save_on_kill: true # cuz mocks fails, idk why cuz not using here
    )
  end

  after(:each) {InfluxDB::Client.new.delete_database('test_database')}


  before(:each) do
    subject.write(tags: {kind_of: 'counter'}, time: 2)
    subject.write(tags: {kind_of: 'counter'}, time: 10)
    PViewer::Database::Client.new.finalize(0)
  end

  context 'programming access' do
    it 'handles with counters' do
      expect(subject.read).to be_a(Array)
      expect(subject.read.first).to include("tags" => {"kind_of" => "counter"})
      expect(subject.read(epoch: 'u').first).to include("values" => [[2], [10]])
    end
  end

  context 'GUI access' do
    let(:client) do
      ws = Faye::WebSocket::Client.new('ws://localhost:3000')

      ws.on :message do |event|
        data = JSON.parse(event.data)
        ws.instance_variable_set(:@buff, data)
      end

      ws.send(message)
      sleep 0.2

      ws.instance_variable_get(:@buff)
    end

    before do
      PViewer.run_gui(daemonize: true, logging: false)
    end

    after(:each) {PViewer.instance_variable_get(:@base).instance_variable_get(:@server).stop}

    let(:client_data) {client["commands"].first["arguments"]["data"].first}

    context 'Summary view' do
      let(:message) do
        '{"commands":[{"name":"read_data","arguments":{"database":"test_database","measurement":"test_measurement [counters]",
          "tags":{},"reduce_type":"mean","time_precision":"u","gui_format":"Summary"}}]}'
      end

      it 'handles with durations - summary view' do
        expect(client).to be_a(Hash)
        expect(client_data).to include("tags" => {"kind_of" => "counter"})
        expect(client_data).to include("values" => [["kind_of: counter", 1], ["kind_of: counter", 1]])
      end
    end

    context 'Tracking view' do
      let(:message) do
        '{"commands":[{"name":"read_data","arguments":{"database":"test_database","measurement":"test_measurement [counters]",
          "tags":{},"reduce_type":"mean","time_precision":"u","gui_format":"Tracking"}}]}'
      end

      it 'handles with durations' do
        expect(client).to be_a(Hash)
        expect(client_data).to include("tags" => {"kind_of" => "counter"})
        expect(client_data).to include("values" => [["1970-01-01T00:00:00.000002Z", 1], ["1970-01-01T00:00:00.00001Z", 1]])
      end
    end
  end


end
