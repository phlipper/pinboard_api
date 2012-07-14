module PinboardApi
  class PinboardApiError < StandardError; end
  class InvalidPostError < PinboardApiError; end
  class InvalidResponseError < PinboardApiError; end
end
