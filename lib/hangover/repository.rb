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
    return if File.exists?(@repository)
    
    # TODO: get name of repo from repo dir
    p "Initializing new hangover repo at #{@repository}"
    init
    add
    commit_a("Initial commit")
  end
  
  def gitk
    `gitk`
  end
  
  def init
    `git init`
  end
  
  def add
    `git add .`
  end

  def commit(message, args = '')
    `git commit #{args} -m "#{message}"`
  end
  
  def commit_a(message)
    commit(message, '-a')
  end
  
  def diff
    `git diff --unified=0`
  end

  def clean
    `git clean`
  end
  
  def git(args_string)
    `git #{args_string}`
  end
end