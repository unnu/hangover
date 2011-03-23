require 'rb-fsevent'
require 'grit'

dir = File.dirname(__FILE__)
fsevent = FSEvent.new

class Git
  def initialize(dir)
    repo = "#{dir}/.hangover"
    @git_options = "--git-dir=#{repo} --work-tree=#{dir}"
    
    unless File.exists?(repo)
      init
      add
      commit
    end
  end
  
  def init
    `git #{@git_options} init`
  end
  
  def add
    `git #{@git_options} add .`
  end

  def commit(message)
    `git #{@git_options} commit -m "#{message}"`
  end
  
  def diff
    `git #{@git_options} diff --unified=0`
  end
end

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

class CommitMessageBuilder
  attr_reader :message
  
  def initialize(adds, subs)
    message_parts = []
    message_parts << "ADDS: #{adds.join(', ')}" unless adds.empty?
    message_parts << "SUBS: #{subs.join(', ')}" unless subs.empty?
    
    @message = message_parts.empty? ? 'Minor changes.' : message_parts.join(' - ')
  end
end


git = Git.new(dir)

fsevent.watch(dir, :latency => 0.5, :no_defer => true) do |directories|
  diff = git.diff
  unless directories.size == 1 && /\.git|\.hangover/ =~ directories.first && diff == ''
    tokenizer = DiffTokenizer.new(diff)
    message = CommitMessageBuilder.new(tokenizer.top_adds, tokenizer.top_subs)

    git.add
    git.commit(message)
  end
end
fsevent.run