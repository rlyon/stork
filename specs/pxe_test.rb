require File.dirname(__FILE__) + '/spec_helper'

describe "Midwife::PXE" do
  before :all do
    host = Midwife::Build::Host.build "test.local" do
      pxemac "00:11:22:33:44:56"
      distro "centos"
    end
    @path = Midwife.configuration.pxe_path
    @pxe = Midwife::PXE.new(host)
  end

  after :each do
    #Dir.glob("#{@path}/*") { |file| File.unlink(file) }
  end

  it "creates the localboot file" do
    @pxe.localboot
    File.exists?("#{@path}/00-11-22-33-44-56").must_equal true
    File.read("#{@path}/00-11-22-33-44-56").must_equal File.read("specs/files/results/pxe.localboot")
  end

  it "creates the default file" do
    @pxe.default
    File.exists?("#{@path}/00-11-22-33-44-56").must_equal true
    File.read("#{@path}/00-11-22-33-44-56").must_equal File.read("specs/files/results/pxe.localboot")
  end

  it "creates the install file" do
    @pxe.install
    File.exists?("#{@path}/00-11-22-33-44-56").must_equal true
    File.read("#{@path}/00-11-22-33-44-56").must_equal File.read("specs/files/results/pxe.install")
  end
end