module Stork
  class PXE
    attr_reader :initrd, :kernel, :kickstart, :path, :hostname, :mac

    def initialize(server, path, hostname, mac, kernel, initrd)
      @host = hostname
      @initrd = initrd
      @kernel = kernel
      @path = path
      @mac = mac
      @kickstart = "http://#{server}/ks/#{hostname}"
    end

    def localboot
      # template = File.dirname(__FILE__) + '/erbs/pxe.localboot.erb'
      # write ERB.new(File.read(template)).result(binding())
      write localboot_content
    end

    def install
      # template = File.dirname(__FILE__) + '/erbs/pxe.install.erb'
      # write ERB.new(File.read(template)).result(binding())
      write install_content
    end

    alias_method :default, :localboot

    private
    def install_content
      <<-EOS
default install
prompt 0
timeout 1
label install
        kernel #{kernel}
        ipappend 2
        append initrd=#{initrd} ksdevice=bootif priority=critical kssendmac ks=#{kickstart}
      EOS
    end

    def localboot_content
      <<-EOS
DEFAULT local
PROMPT 0
TIMEOUT 0
TOTALTIMEOUT 0
ONTIMEOUT local
LABEL local
        LOCALBOOT -1
      EOS
    end

    def write(str)
      File.open("#{path}/#{pxefile}", 'w') do |f|
        f.write(str)
      end
    end

    def pxefile
      @mac.gsub(/[:]/, '-')
    end
  end
end
