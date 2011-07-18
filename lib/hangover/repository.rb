require 'pathname'

class Repository
  
  NAME = '.hangover'
  
  class << self
    def find(dir)
      path = Pathname.new(dir).expand_path.realpath
      
      begin
        try_path = path + NAME
        return new(path.to_s) if try_path.directory?
      end while (path = path.parent).to_s != '/'
      
      nil
    end
  end
  
  def initialize(dir)
    @repository = "#{dir}/#{NAME}"
    ENV['GIT_DIR'] = @repository
    ENV['GIT_WORK_TREE'] = dir
  end
  
  def exists!
    if File.directory?(@repository)
      Hangover.logger.warn "Repository already exists at #{@repository}"
      return
    end
    
    Hangover.logger.info "Initializing new hangover repo at #{@repository}"
    init
    File.open("#{@repository}/info/exclude", "w") do |f|
      f.puts NAME
      f.puts ".git"
    end
    add_all
    commit_all("Initial commit")
  end
  
  def gitk
    `gitk`
  end
    
  def gource
    `gource`
  end
  
  def init
    git 'init'
  end
  
  def add_all
    git 'add .'
  end

  def commit(message, args = '')
    git "commit #{args} -m \"#{message}\""
  end
  
  def commit_all(message)
    commit(message, '-a')
  end
  
  def diff
    git 'diff --unified=0'
  end

  def clean
    git 'clean'
  end
  
  def git(args)
    Hangover.logger.debug { "git #{args}" }
    `git #{args}`
  end
end