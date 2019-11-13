# frozen_string_literal: true

require 'add_line_to_file'
require 'environment'
require 'ansi'

task :git => [:'git:config', :'git:commands', :'git:aliases']

namespace :git do
  desc 'Set up Git Configuration'
  task :config do
    git_config_dir = File.expand_path('~/.config/git')
    git_config = "#{git_config_dir}/config"
    git_attributes = "#{git_config_dir}/attributes"

    FileUtils.mkdir_p git_config_dir
    FileUtils.touch git_config

    sh 'git', 'config', '--global', 'user.name', 'Michael Kaltschmid'
    sh 'git', 'config', '--global', 'user.email', 'kaltschmidmichael@gmail.com'
  end

  desc 'Install Git Commands'
  task :commands do
    bin = '~/.config/git/commands'
    add_line_to_file fish_environment, "mkdir -p #{bin}; and set -x fish_user_paths #{bin} $fish_user_paths"
    add_line_to_file bash_environment, "mkdir -p #{bin} && export PATH=#{bin}:\"$PATH\""
  end

  desc 'Install Git Aliases'
  task :aliases do
    puts ANSI.blue { 'Installing Git aliases …' }

    # Show all aliases.
    sh 'git', 'config', '--global', 'alias.aliases', 'config --get-regexp ^alias\.'

    # Change last n commits.
    sh 'git', 'config', '--global', 'alias.change', '! f() { git rebase -i "HEAD~${1:-1}" --autostash; }; f'

    # Output nice log graph.
    sh 'git', 'config', '--global', 'alias.tree', 'log --graph --oneline --decorate --all'

    # Only diff words instead of lines.
    sh 'git', 'config', '--global', 'alias.wdiff', 'diff --word-diff=color'

    # Amend all changes to the last commit.
    sh 'git', 'config', '--global', 'alias.amend', 'commit --amend --all --no-edit'

    sh 'git', 'config', '--global', 'alias.s', 'add -p'
    sh 'git', 'config', '--global', 'alias.u', 'reset -p'
    sh 'git', 'config', '--global', 'alias.d', 'checkout -p'

    sh 'git', 'config', '--global', 'alias.master', '! f() { git fetch ${1:-origin} master && git rebase --autostash ${1:-origin}/master; }; f'

    sh 'git', 'config', '--global', 'alias.sync', '! f() { git pull --rebase ${@} && git push ${@}; }; f'

    sh 'git', 'config', '--global', 'alias.new', 'checkout -b'
    sh 'git', 'config', '--global', 'alias.shove', 'push --force-with-lease'

    sh 'git', 'config', '--global', 'alias.cp', 'cherry-pick'
    sh 'git', 'config', '--global', 'alias.st', 'status -s'
    sh 'git', 'config', '--global', 'alias.cl', 'clone'
    sh 'git', 'config', '--global', 'alias.ci', 'commit'
    sh 'git', 'config', '--global', 'alias.co', 'checkout'
    sh 'git', 'config', '--global', 'alias.br', 'branch '
    sh 'git', 'config', '--global', 'alias.dc', 'diff --cached'

    sh 'git', 'config', '--global', 'alias.r', 'reset'
    sh 'git', 'config', '--global', 'alias.r1', 'reset HEAD^'
    sh 'git', 'config', '--global', 'alias.r2', 'reset HEAD^^'
    sh 'git', 'config', '--global', 'alias.rh', 'reset --hard'
    sh 'git', 'config', '--global', 'alias.rh1', 'reset HEAD^ --hard'
    sh 'git', 'config', '--global', 'alias.rh2', 'reset HEAD^^ --hard'

    sh 'git', 'config', '--global', 'alias.sl', 'stash list'
    sh 'git', 'config', '--global', 'alias.sa', 'stash apply'
    sh 'git', 'config', '--global', 'alias.ss', 'stash save'
  end
end