# Array extension.
class Array
  def remove_every(num, start = num)
    start.step(size - 1, num).map { |i| self[i] }
  end

  def clip(num = 1)
    take size - num
  end
end

# Hash extension.
class Hash
  def deep_merge_pv!(other_hash, &block)
    merge!(other_hash) do |key, this_val, other_val|
      if this_val.is_a?(Hash) && other_val.is_a?(Hash)
        this_val.deep_merge_pv!(other_val, &block)
      elsif block_given?
        yield(key, this_val, other_val)
      else
        other_val
      end
    end
  end


  def except!(*keys)
    keys.each { |key| delete(key) }
    self
  end

  def except(*keys)
    dup.except!(*keys)
  end

  def compact
    delete_if { |_, v| v.nil? }
  end
end
