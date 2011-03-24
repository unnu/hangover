class DiffTokenizer
  
  def initialize(text)
    lines = text.split("\n")

    add_lines = select_lines_starting_with(lines, '+')
    substract_lines = select_lines_starting_with(lines, '-')

    added_tokens = extract_tokens(add_lines)
    substracted_tokens = extract_tokens(substract_lines)
    
    cleaned_added_tokens = added_tokens - substracted_tokens.uniq
    cleaned_substracted_tokens = substracted_tokens - added_tokens.uniq

    @top = {}
    @top[:adds] = count_tokens(cleaned_added_tokens)
    @top[:subs] = count_tokens(cleaned_substracted_tokens)
  end
  
  def top(count, type)
    @top[type][0, count].map { |token_and_count| token_and_count.first }
  end
  
  def top_adds(count = 5)
    top(count, :adds)
  end
  
  def top_subs(count = 5)
    top(count, :subs)
  end
  
  private
    def select_lines_starting_with(lines, char)
      escaped_char = Regexp.escape(char)
      lines.select { |line| line =~ Regexp.new("^#{escaped_char}[^#{escaped_char}]") }
    end
    
    def extract_tokens(lines)
      lines.map { |line| line.scan(/[\w_]{2,}/) }.flatten
    end
    
    def count_tokens(tokens)
      counts = Hash.new(0)
      tokens.each { |token| counts[token] += 1 }
      counts.sort_by { |a, b| b }.reverse
    end
end