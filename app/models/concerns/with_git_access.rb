module WithGitAccess
  def octokit
    Octokit::Client.new(access_token: token)
  end

  def ensure_repo_exists!(guide)
    create_repo!(guide) unless repo_exists?(guide)
  end

  def repo_github_url(guide)
    "https://#{token}:@github.com/#{guide.github_repository}"
  end

  def create_repo!(guide)
    Rails.logger.info "Creating repository #{guide.github_repository}"
    octokit.create_repository(guide.github_repository_name)
  end

  def clone_repo_into(guide, dir)
    Git.clone(repo_github_url(guide), '.', path: dir)
  rescue Git::GitExecuteError => e
    raise 'Repository is private or does not exist' if private_repo_error(e.message)
    raise e
  end

  def with_cloned_repo(guide, key)
    Dir.mktmpdir("mumuki.#{id}.#{key}") do |dir|
      repo = clone_repo_into guide, dir
      yield dir, repo
    end
  end

  def repo_exists?(guide)
    Git.ls_remote(repo_github_url(guide))
    true
  rescue Git::GitExecuteError
    false
  end

  def can_commit?(guide)
    octokit.collaborator?(guide.github_repository, name)
  rescue
    false
  end

  def register_post_commit_hook!(guide, web_hook)
    octokit.create_hook(
        guide.github_repository, 'web',
        {url: web_hook, content_type: 'json'},
        {events: ['push'],
         active: true})
  end

  def contributors(guide)
    Rails.logger.info "Fetching contributors for guide #{guide}"
    octokit.contribs(guide.github_repository)
  end

  def collaborators(guide)
    Rails.logger.info "Fetching collaboratos for guide #{guide}"
    octokit.collabs(guide.github_repository)
  end

  private

  def private_repo_error(message)
    ['could not read Username', 'Invalid username or password'].any? { |it| message.include? it }
  end

end
