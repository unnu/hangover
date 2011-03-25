require 'rb-fsevent'

$:.push(File.expand_path(File.dirname(__FILE__)))

require 'hangover/repository'
require 'hangover/diff_tokenizer'
require 'hangover/commit_message_builder'

class Hangover
  
  def initialize(dir)
    @dir = expand_dir(dir)
  end
  
  def start
    exit_if_running!
    
    @repository = Repository.new(@dir)
    @repository.ensure_exists!
    
    @fsevent = FSEvent.new
    on_change(@dir) do |diff|
      tokenizer = DiffTokenizer.new(diff)
      message = CommitMessageBuilder.new(tokenizer.top_adds, tokenizer.top_subs).message
      @repository.add
      @repository.commit_a(message)
      $stderr.puts message if true #$DEBUG
    end
    
    $stderr.puts "Hangover starting..."
    daemonize!
    @fsevent.run
  end
  
  def stop
    if running?
      Process.kill(15, pid)
      $stderr.puts "Hangover stopped."
    else
      $stderr.puts "Hangover not running."
    end
  ensure
    remove_pid if File.exist?(pid_file)
  end
  
  def gitk
    @repository.gitk
  end
  
  private
    def on_change(dir)
      @fsevent.watch(dir, :latency => 0.5, :no_defer => true) do |directories|
        diff = @repository.diff
        unless directories.size == 1 && /\.git|\.hangover/ =~ directories.first || diff == ''
          yield diff
        end
      end
    end
    
    def expand_dir(dir)
      raise ArgumentError, "No dir given!" unless dir
      dir = "#{FileUtils.pwd}/#{dir}" if dir !~ /^\//
      raise ArgumentError, "Dir '#{dir}' does not exist" unless File.exist?(dir)
      dir
    end
    
    def pid
      IO.read(pid_file).to_i if File.exist?(pid_file)
    end
    
    def write_pid
      File.open(pid_file, "w") { |f| f.puts Process.pid }
    end
    
    def remove_pid
      FileUtils.rm(pid_file)
    end
    
    def pid_file
      "#{@dir}/.hangover_pid"
    end
    
    def running?
      Process.kill(0, pid) == 1 if pid
    end
    
    def exit_if_running!
      return unless running?

      $stderr.puts "Hangover already running."
      exit(0)
    end
    
    def daemonize!
      Process.daemon
      write_pid
    end
end