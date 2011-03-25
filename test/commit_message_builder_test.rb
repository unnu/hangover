require 'test_helper'

class CommitMessageBuilderTest < ActiveSupport::TestCase
  
  test "show adds if any" do
    assert_equal "ADDS: foo, bar, baz", CommitMessageBuilder.new(%w(foo bar baz), []).message
  end
  
  test "show subs if any" do
    assert_equal "SUBS: foo, bar, baz", CommitMessageBuilder.new([], %w(foo bar baz)).message
  end
  
  test "show both if any" do
    assert_equal "ADDS: one, two - SUBS: foo, bar, baz", CommitMessageBuilder.new(%w(one two), %w(foo bar baz)).message
  end
end

