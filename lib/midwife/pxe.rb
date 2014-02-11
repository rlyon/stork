# Copyright 2012, Rob Lyon
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Midwife
  class PXE
    include Midwife::Core

    attr_reader :initrd, :kernel, :kickstart

    def initialize(host)
      @host = host
      @initrd = @host.distro.initrd_url
      @kernel = @host.distro.kernel_url
      @kickstart = "http://#{Midwife.configuration.server}/ks/#{@host.name}"
    end

    def pxefile
      @host.pxemac.gsub(/[:]/,'-')
    end

    def write(str)
      File.open("#{Midwife.configuration.pxe_path}/#{pxefile}", 'w') do |f|
        f.write(str)
      end
    end

    def default
      template = File.dirname(__FILE__) + '/erbs/pxe.localboot.erb'
      write ERB.new(File.read(template)).result(binding())
    end

    alias_method :localboot, :default

    def install
      template = File.dirname(__FILE__) + '/erbs/pxe.install.erb'
      write ERB.new(File.read(template)).result(binding())
    end
  end
end