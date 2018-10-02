require 'spec_helper'

RSpec.describe PViewer::Web::Config do
  context 'no options specified' do
    subject { described_class.new }

    it 'include default options' do
      is_expected.to have_attributes(host: 'localhost', port: 3000,
                                     daemonize: true, logging: true,
                                     threaded: false)
    end
  end

  context 'options have been specified' do
    subject do
      opts = { host: 'fake_domain', port: 9999, threaded: true }
      described_class.new(opts)
    end

    it 'include specified options' do
      is_expected.to have_attributes(host: 'fake_domain', port: 9999,
                                     daemonize: true, logging: true,
                                     threaded: true)
    end
  end
end
