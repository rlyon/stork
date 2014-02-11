###
### The test scheme
###
scheme "default" do
  clearpart
  zerombr
  part "/boot" do
    size 100
    type "ext4"
    primary
  end

  part "swap" do
    size 0 # zero defaults to recommended
    type "swap"
    primary
  end

  part "/" do
    size 1
    type "ext4"
    grow
  end
end

scheme "split" do
  clearpart
  zerombr
  part "/boot" do
    size 100
    type "ext4"
    primary
  end

  part "swap" do
    size 0
    type "swap"
    primary
  end

  part "/" do
    size 4096
    type "ext4"
  end

  part "/home" do
    size 1
    type "ext4"
    grow
  end
end