require 'trollop'

class Utils

  attr_accessor :parser, :opts
  PROD = false # set to true for production

  def initialize()
    self.init_parser()
    self.init_opts()
  end

  def init_parser()
    @parser = Trollop::Parser.new do
      version "udp-amp v0.1.0 (c) 2014 Pasquale D'Agostino"
      banner <<-EOS
This script takes a list of IP addresses as input and sends four commands to the NTP server. Each command is tried three times before moving on, a timeout
can be set to adjust the wait time.

Scan Types:
  ntp\tChecks for monlist, iostat, and loopinfo responses

Usage:
  udp-amp [options] <host,subnet,filename>

[options] are:
EOS
      opt :timeout, "Set packet timeout (in seconds)", :type => :int
      opt :output, "Write output to a file", :type => String
      opt :scan, "Amplification vector to scan", :short => "s", :type => String
    end
  end

  def init_opts()
    @opts = Trollop::with_standard_exception_handling @parser do
      raise Trollop::HelpNeeded if (ARGV.empty? and PROD)  # show help screen
      @parser.parse ARGV
    end
  end

end
