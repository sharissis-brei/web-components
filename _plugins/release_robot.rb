require 'tmpdir'
require 'bundler/setup'
require 'colorize'
require 'json'

class ReleaseRobot
  GITHUB_REPONAME = 'chapmanu/web-components'

  ##########################
  # ::: PUBLIC METHODS ::: #
  ##########################

  # The constructor, just to show you the instance variables that 
  # will appear in the code below.
  def initialize()
    @bower_file      = nil
    @current_version = nil
    @next_version    = nil
    @commit_message  = nil
  end

  # Walks the user through the process of releasing
  # a new bower version of the assets.
  def release!
    welcome
    return if uncommitted_changes?

    # Check if everything is up to date with git remotes
    if branch_behind_remote?
      if want_to_pull? 
        cmd "git pull"
        cmd "git pull --tags"
      else
        inform "Please pull the changes, then run `rake release` again"
        return
      end
    end

    # Gather user input about the release
    get_release_message
    get_release_version_type

    # Confirm and execute
    if you_sure?
      update_dist
      update_bower_file
      cmd "git add ."
      cmd "git commit -am '#{@commit_message}'"
      cmd "git tag -a v#{@next_version} -m '#{@commit_message}'"
      cmd "git push"
      cmd "git push --tags"
      publish! # to github pages

      robot_says "All done :) Thanks for contributing!"
    else
      inform "Release cancelled"
    end
  end

  # Publishes the compiled site to the gh-pages branch to be hosted
  # by github at http://chapmanu.github.io/web-components
  def publish!
    inform "Publishing local version to http://chapmanu.github.io/web-components"
    
    # Production Configuration
    inform "Building site with production configuration"
    Jekyll::Site.new(Jekyll.configuration({
      "source"      => ".",
      "destination" => "_site"
    })).process

    Dir.mktmpdir do |tmp|
      FileUtils.cp_r "_site/.", tmp
      
      pwd = Dir.pwd
      Dir.chdir tmp

      cmd "git init"
      cmd "git add ."
      message = "Site updated at #{Time.now.utc}"
      cmd "git commit -m  #{message.inspect}"
      cmd "git remote add origin git@github.com:#{GITHUB_REPONAME}.git"
      cmd "git push origin master:refs/heads/gh-pages --force"

      Dir.chdir pwd
    end
    inform "Publish successful"
  end

  
  private
  ##########################
  # ::: OUTPUT HELPERS ::: #
  ##########################

  def welcome
    puts File.read('_plugins/title.txt')
    robot_says "Hi, I am the web-components release robot!\nLets walk you through the release processes."
    puts
  end

  def robot_says(phrase)
    lines = phrase.split("\n").reverse!
    robot_text = File.read('_plugins/robot.txt')
    [34, 15].each_with_index do | spot_to_put_line, index |
      break unless lines[index]
      robot_text[spot_to_put_line] = lines[index].bold
    end
    puts robot_text
  end

  def warn(phrase)
    puts phrase.yellow
  end

  def prompt(phrase)
    print phrase
    STDIN.gets.strip
  end

  def inform(phrase)
    puts "#{phrase}".green
  end

  def cmd(system_command)
    puts "Running command: `#{system_command}`".yellow
    output = `#{system_command}`
    # puts output.prepend("  ").gsub("\n", "\n  ").cyan
    output
  end

  ##############################
  # ::: USER INPUT HELPERS ::: #
  ##############################

  def get_release_version_type
    number = prompt "What type of release is this?\n1) Major\n2) Minor\n3) Patch\nSelect option number: "
    bump_version({"1" => "major", "2" => "minor", "3" => "patch"}[number])
  end

  def get_release_message
    @commit_message = prompt "Commit message for this release: "
  end

  def want_to_pull?
    should_pull = prompt "Would you like to run `git pull` and `git pull --tags`? (Y/n) "
    should_pull.downcase == 'y'
  end

  def you_sure?
    robot_says "Please confirm that you want me to do the following:"
    warn "1. Run a fresh build of the assets"
    warn "2. Update the dist folder with compiled assets"
    warn "3. Change version in bower.json from #{@current_version.bold} to #{@next_version.bold}"
    warn "4. Commit all local changes with this message: #{@commit_message.bold}"
    warn "5. Tag this commit with v#{@next_version.bold}"
    warn "6. Push all changes and tags to remote branch"
    warn "7. Push this local version of the site to github pages to be hosted"
    answer = prompt "Does this sound agreeable to you? (Y/n) "
    answer.downcase == 'y'
  end

  #######################
  # ::: GIT HELPERS ::: #
  #######################

  def uncommitted_changes?
    inform "Checking for any uncommitted changes..."
    if nothing_to_commit?
      inform "All changes committed :)"
      false
    else
      inform "You have uncommitted changes.  Please commit them first, then run `rake release` again."
      true
    end
  end

  def nothing_to_commit?
    !!(cmd("git status") =~ /nothing to commit/)
  end

  def branch_behind_remote?
    inform "Checking if your branch is up-to-date with the remote..."
    cmd "git remote update"
    if (cmd("git status -uno") =~ /(up-to-date|branch is ahead)/)
      inform "Cool. Everything is up to date."
      false # Branch is not behind
    else
      inform "Uh oh. Your branch is behind the remote."
      inform "You will need to 'git pull' and 'git pull --tags'"
      true # Branch is behind
    end
  end

  #############################
  # ::: UTILITY FUNCTIONS ::: #
  #############################

  def bump_version(version_bump_type)
    parse_bower
    @current_version = @bower_file["version"]
    versions = @current_version.split('.').map(&:to_i)
    
    case version_bump_type
    when "patch"
      versions[2] += 1
    when "minor"
      versions[1] += 1
      versions[2] = 0
    when "major"
      versions[0] += 1
      versions[1] = 0
      versions[2] = 0
    else
      raise "UnknownVersionType"
    end
    @next_version = versions.join('.')
  end

  def parse_bower
    @bower_file = JSON.parse(File.read('bower.json'))
  end

  def update_dist
    inform "Copying _sites/assets into dist"
    FileUtils.rm_r('dist', force: true)
    FileUtils.cp_r('_site/assets/.', 'dist')
  end

  def update_bower_file
    raise "NeedTheNextVersionNumber" if @next_version == nil
    inform "Updating bower.json to version #{@current_version.bold}"
    @bower_file["version"] = @next_version
    File.write('bower.json', JSON.pretty_generate(@bower_file))
  end
end