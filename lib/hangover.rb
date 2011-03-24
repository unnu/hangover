require 'rb-fsevent'

$:.push(File.expand_path(File.dirname(__FILE__)))

require 'hangover/git'
require 'hangover/diff_tokenizer'
require 'hangover/commit_message_builder'

class Hangover
  
  def initialize(dir)
    @fsevent = FSEvent.new
    @git = Git.new(dir)
    
    on_change(dir) do |diff|
      tokenizer = DiffTokenizer.new(diff)
      message = CommitMessageBuilder.new(tokenizer.top_adds, tokenizer.top_subs).message
      @git.add
      @git.commit_a(message)
      $stderr.puts message
    end
    
    $stderr.puts "Hangover started..."
    @fsevent.run
  end
  
  private
    def on_change(dir)
      @fsevent.watch(dir, :latency => 0.5, :no_defer => true) do |directories|
        diff = @git.diff
        unless directories.size == 1 && /\.git|\.hangover/ =~ directories.first || diff == ''
          yield diff
        end
      end
    end
end