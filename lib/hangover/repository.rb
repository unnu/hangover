class Repository
  def initialize(dir)
    @repository = "#{dir}/.hangover"
    ENV['GIT_DIR'] = @repository
    ENV['GIT_WORK_TREE'] = dir
  end
  
  def ensure_exists!
    return if File.exists?(@repository)
    
    # TODO: get name of repo from repo dir
    p "Initializing new hangover repo at #{@repository}"
    init
    add
    commit
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
end