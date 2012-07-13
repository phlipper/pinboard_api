require "spec_helper"

describe Hash do

  describe "stringify_keys!" do
    let(:string_hash) do
      { "foo" => "bar", "baz" => "qux" }
    end

    let(:symbol_hash) do
      { foo: "bar", baz: "qux" }
    end

    it { symbol_hash.stringify_keys!.must_equal string_hash }
    it { string_hash.stringify_keys!.must_equal string_hash }
  end

end
