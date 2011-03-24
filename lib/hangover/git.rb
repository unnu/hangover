class Git
  def initialize(dir)
    repo = "#{dir}/.hangover"
    #@git_options = "--git-dir=#{repo} --work-tree=#{dir}"
    ENV['GIT_DIR'] = repo
    ENV['GIT_WORK_TREE'] = dir
    
    unless File.exists?(repo)
      p "Initializing new hanover repo at #{repo}"
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