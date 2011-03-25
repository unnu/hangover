require 'test_helper'

class HangoverTest < ActiveSupport::TestCase
  
  test "" do
    assert_equal %w(Das ist Zeile eins zwei drei), DiffTokenizer.new(diff(:only_subs)).top(100, :subs)
  end
end