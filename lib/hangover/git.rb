class Git
  def initialize(dir)
    repo = "#{dir}/.hangover"
    ENV['GIT_DIR'] = repo
    ENV['GIT_WORK_TREE'] = dir
    
    unless File.exists?(repo)
      # TODO: get name of repo from repo dir
      p "Initializing new hangover repo at #{repo}"
      init
      add
      commit
    end
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