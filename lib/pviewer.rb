require_relative 'pviewer/ruby_class_extensions'
require_relative 'pviewer/base'
require_relative 'pviewer/errors'
require_relative 'pviewer/version'
require 'eventmachine'

# Base PViewer module, could be initialized by passing options in hashes.
# First hash should contains options for database , second holds GUI settings.
# More infos in files with that classes.
#
# Initialization example:
#
# PViewer.init({ time_precision: 'u' }, { port: 3000, gui: true }, )
#
# Initialize PViewer, starts gui on port: 3000,
# and sets database write precision to microseconds.
#
# Durations example:
#
# PViewer.durations('experiment', database: 'some_name')
#
# Returns object that allow to read and write events durations,
# that name is experiment and is located in some_name database
#
# IMPORTANT:
# Fit database time precision to timestamps to avoid problems with time.
# After all finalize PViewer to save values in buffer.
#
module PViewer
  class << self
    def init(db_conf = {}, app_conf = {})
      @base = PViewer::Base.new(db_conf, app_conf)
      self
    end

    alias initialize init
    alias initialize_default init

    def durations(name = nil, **args)
      initialize_default unless @base
      args[:measurement] = (name || args[:measurement])
      @base.durations_handler(**args)
    end

    def values(name = nil, **args)
      initialize_default unless @base
      args[:measurement] = (name || args[:measurement])
      @base.values_handler(**args)
    end

    def counters(name = nil, **args)
      initialize_default unless @base
      args[:measurement] = (name || args[:measurement])
      @base.counters_handler(**args)
    end

    def finalize
      @base.finalize
    end

    def initialized?
      !@base.nil?
    end

    def run_gui(**args)
      finalize
      @base.run_gui(**args)
    end
  end
end