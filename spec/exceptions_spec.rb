require "spec_helper"

describe PinboardApi do
  it { PinboardApi::PinboardApiError.new.must_be_kind_of StandardError }
  it { PinboardApi::InvalidPostError.new.must_be_kind_of PinboardApi::PinboardApiError }
  it { PinboardApi::InvalidResponseError.new.must_be_kind_of PinboardApi::PinboardApiError }
end
