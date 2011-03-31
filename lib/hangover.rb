require 'rb-fsevent'
require 'active_support/core_ext'
require 'logger'

$:.push(File.expand_path(File.dirname(__FILE__)))

require 'hangover/repository'
require 'hangover/diff_tokenizer'
require 'hangover/commit_message_builder'
require 'hangover/watch_dir'

class Hangover
  
  cattr_accessor :logger
  @@logger = Logger.new($stderr)
  @@logger.level = $HANGOVER_DEBUG ? Logger::DEBUG : Logger::INFO
  
  def initialize(base_dir)
    @base_dir = expand_dir(base_dir)
  end
  
  def start(options)
    exit_if_running!
    logger.info "Hangover starting..."
    daemonize!
    
    WatchDir.new(@base_dir).on_change do |dir|
      repository = Repository.find(dir)
      next if repository.nil?
      
      diff = repository.diff
      next if diff.blank?
      
      tokenizer = DiffTokenizer.new(diff)
      
      message = CommitMessageBuilder.new(tokenizer.top_adds, tokenizer.top_subs).message
      repository.add_all
      repository.commit_all(message)
    end
  end
  
  def stop(options)
    if running?
      Process.kill(15, pid)
      logger.info "Hangover stopped."
    else
      logger.info "Hangover not running."
    end
  ensure
    remove_pid if File.exist?(pid_file)
  end
  
  def create(options)
    Repository.new(@base_dir).exists!
  end
  
  def gitk(options)
    Repository.new(@base_dir).gitk
  end
    
  def gource(options)
    Repository.new(@base_dir).gource
  end
  
  def status(options)
    if running?
      logger.info "Hangover is running and watching #{@base_dir}"
    else
      logger.info "Hangover NOT running."
    end
  end
  
  def git(options)
    logger.info Repository.new(@base_dir).git(options[:args])
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
        logger.info "Removing stale pid file."
        remove_pid
      end
      false
    end
    
    def exit_if_running!
      return unless running?

      logger.info "Hangover already running."
      exit(0)
    end
    
    def daemonize!
      Process.daemon(true, true)
      write_pid
    end
    
    def logger
      self.class.logger
    end
end