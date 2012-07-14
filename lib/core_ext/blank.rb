class NilClass
  def blank?
    true
  end
end

class FalseClass
  def blank?
    true
  end
end

class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
end

class String
  # 0x3000: fullwidth whitespace
  NON_WHITESPACE_REGEXP = /[^\s#{[0x3000].pack("U")}]/

  def blank?
    self !~ NON_WHITESPACE_REGEXP
  end
end
