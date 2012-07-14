require "spec_helper"

describe NilClass do
  it { nil.must_be :blank? }
end

describe FalseClass do
  it { false.must_be :blank? }
end

describe Object do
  it { [].must_be :blank? }
  it { ["foo"].wont_be :blank? }
end


describe String do
  it { "".must_be :blank? }
  it { "foo".wont_be :blank? }
end
