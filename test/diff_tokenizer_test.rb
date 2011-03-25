require 'test_helper'

class DiffTokenizerTest < ActiveSupport::TestCase
  
  test "extract subs with token count order ('Das ist Zeile' was extracted three times)" do
    assert_equal %w(Das ist Zeile eins zwei drei), DiffTokenizer.new(diff(:only_subs)).top(100, :subs)
  end
  
  test "extract adds" do
    assert_equal %w(dazu Eine), DiffTokenizer.new(diff(:only_one_add)).top(100, :adds)
  end
  
  test "extract both only returning tokens that were not in both (adds and subs)" do
    assert_equal %w(weg), DiffTokenizer.new(diff(:one_line_changed)).top(100, :adds)
    assert_equal %w(Das), DiffTokenizer.new(diff(:one_line_changed)).top(100, :subs)
  end
  
  private
    def diff(name)
      IO.read(File.dirname(__FILE__) + "/fixtures/#{name}.diff")
    end
end