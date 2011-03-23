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

class TokenFrequency
  attr_reader :frequency
  
  def initialize(text, exclude = %w(diff rb git hangover y x))
    @tokens = text.split(/[\W]/)
    @frequency = Hash.new(0)
    @tokens.each { |token| @frequency[token] += 1 }
    @frequency = @frequency.sort_by { |x,y| y }.reverse.delete_if { |key, value| exclude.include?(key.downcase) || key == '' || /^\d+$/ =~ key || key.size < 2 }
    p @frequency
  end
  
  def top(count = 1)
    @frequency[0, count].map { |token_pair| token_pair.first }
  end
end

git = Git.new(dir)

fsevent.watch(dir, :latency => 0.5, :no_defer => true) do |directories|
  diff = git.diff
  unless directories.size == 1 && /\.git|\.hangover/ =~ directories.first && diff == ''
    git.add
    git.commit(TokenFrequency.new(diff).top(3).join(' - '))
  end
end
fsevent.run