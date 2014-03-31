require 'socket'
require 'ipaddr'
require 'timeout'

class NetIO

  attr_accessor :socket, :hosts, :pkts, :resp, :opts

  def initialize(opts)
    @socket = UDPSocket.new
    @pkts = init_packets()
    @opts = opts
    @timeout = opts[:timeout] || 15
  end

  def init_packets()
    iostats = [0x17, 0, 0x03, 0x06, 0, 0, 0, 0, 0, 0].pack("C3Q7")
    loopinfo = [0x17, 0, 0x03, 0x08, 0, 0, 0, 0, 0, 0].pack("C3Q7")
    monlist = [0x17, 0, 0x03, 0x2a, 0, 0, 0, 0, 0, 0].pack("C3Q7")
    return { :ntp => {:monlist => monlist, :iostats => iostats, :loopinfo => loopinfo, :port => 123 } }
  end

  def set_hosts(hosts)
    if File.exist? (hosts)
      @hosts = { :hosts => File.open(hosts), :file => true }
    elsif hosts.match(/\A(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\Z/)
      @hosts = { :hosts => IPAddr.new(hosts), :address => true }
    elsif hosts.match(/\A(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\/(\d{1,2})\Z/)
      @hosts = { :hosts => IPAddr.new(hosts).to_range, :range => true }
    else
      error("hosts")
    end
    rescue
      error("hosts")
  end

  def scan()
    if @hosts[:file]
      @hosts[:hosts].each_line do |host|
        scan_type(host.strip!, @opts[:scan])
      end
    elsif @hosts[:address]
      scan_type(@hosts[:hosts], @opts[:scan])
    elsif @hosts[:range]
      @hosts[:hosts].map do |host|
        scan_type(host, @opts[:scan])
      end
    end
  end

  def scan_type(host, type)
    case type
    when /chargen/i
    when /dns/i
    when /ntp/i
      puts "#{host} - #{type}"
    else
      p "ALL"
    end
  end

  def error(statement)
    case statement
    when /hosts/i
      abort "Error: invalid host option\n" +
            "Try --help for help"
    else
      abort "Error: invalid command\n" +
            "Try --help for help"
    end
  end

  def send_packet(host, cmd, port)
    begin
      Timeout.timeout(@timeout) do
        @socket.send cmd, 0, host, port
        @resp = @socket.recv(550)
      end
    rescue Timeout::Error
    end
  end

end
