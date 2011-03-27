require 'rubygems'
require 'bundler/setup'
require 'rb-fsevent'
require 'active_support/core_ext'

$:.push(File.expand_path(File.dirname(__FILE__)))

require 'hangover/repository'
require 'hangover/diff_tokenizer'
require 'hangover/commit_message_builder'
require 'hangover/watch_dir'

class Hangover
  
  def initialize(base_dir)
    @base_dir = expand_dir(base_dir)
  end
  
  def start
    exit_if_running!
    $stderr.puts "Hangover starting..."
    daemonize!
    
    WatchDir.new(@base_dir).on_change do |dir|
      @repository = Repository.find(dir)
      diff = @repository.diff
      next if diff.blank?
      
      tokenizer = DiffTokenizer.new(diff)
      message = CommitMessageBuilder.new(tokenizer.top_adds, tokenizer.top_subs).message
      @repository.add
      @repository.commit_a(message)
    end
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
  
  def create
    @repository = Repository.new(@base_dir)
    @repository.exists!
  end
  
  def gitk
    Repository.new(@base_dir).gitk
  end
  
  def status
    if running?
      $stderr.puts "Hangover is running and watching #{@base_dir}"
    else
      $stderr.puts "Hangover NOT running."
    end
  end
  
  private
    def expand_dir(dir)
      raise ArgumentError, "No dir given!" unless dir
      
      dir.replace("#{FileUtils.pwd}/#{dir}") if dir !~ /^\//
      raise ArgumentError, "Dir '#{dir}' does not exist" unless File.directory?(dir)
      
      dir
    end
    
    def pid
      IO.read(pid_file).to_i if File.exist?(pid_file)
    end
    
    def write_pid
      File.open(pid_file, "w") { |f| f.puts Process.pid }
    end
    
    def remove_pid
      FileUtils.rm(pid_file) if File.exist?(pid_file)
    end
    
    def pid_file
      "#{ENV['HOME']}/.hangover.pid"
    end
    
    def running?
      Process.kill(0, pid) == 1 if pid
    rescue Errno::ESRCH
      if File.exist?(pid_file)
        $stderr.puts "Removing stale pid file."
        remove_pid
      end
      false
    end
    
    def exit_if_running!
      return unless running?

      $stderr.puts "Hangover already running."
      exit(0)
    end
    
    def daemonize!
      Process.daemon(true, true)
      write_pid
    end
end