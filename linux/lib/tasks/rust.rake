# frozen_string_literal: true

require 'which'
require 'open3'

task :rust do
  cargo_home = '~/.config/cargo'
  rustup_home = '~/.config/rustup'

  ENV['CARGO_HOME'] = File.expand_path(cargo_home)

  add_line_to_file fish_environment, "set -x CARGO_HOME #{cargo_home}"
  add_line_to_file bash_environment, "export CARGO_HOME=#{cargo_home}"

  ENV['RUSTUP_HOME'] = File.expand_path(rustup_home)

  add_line_to_file fish_environment, "set -x RUSTUP_HOME #{rustup_home}"
  add_line_to_file bash_environment, "export RUSTUP_HOME=#{rustup_home}"

  ENV['PATH'] = "#{ENV['CARGO_HOME']}/bin:#{ENV['PATH']}"

  add_line_to_file fish_environment, 'mkdir -p "$CARGO_HOME/bin"; and set -x fish_user_paths "$CARGO_HOME/bin" $fish_user_paths'
  add_line_to_file bash_environment, 'mkdir -p "$CARGO_HOME/bin" && export PATH="$CARGO_HOME/bin:$PATH"'

  FileUtils.mkdir_p ENV['CARGO_HOME']
  File.write "#{ENV['CARGO_HOME']}/config", <<~TOML
    [net]
    git-fetch-with-cli = true
  TOML

  if which 'rustup'
    puts ANSI.blue { 'Updating Rust …' }
    sh 'rustup', 'update'
  else
    puts ANSI.blue { 'Installing Rust …' }
    sh 'rustup-init', '-y', '--no-modify-path'
  end

  installed_toolchains, *_ = Open3.capture3('rustup', 'toolchain', 'list')
  installed_toolchains = installed_toolchains.chomp.split("\n")

  if installed_toolchains.include?('nightly-x86_64-unknown-linux-gnu')
    puts ANSI.green { 'Rust nightly toolchain already installed.' }
  else
    puts ANSI.blue { 'Installing Rust nightly toolchain …' }
    sh 'rustup', 'toolchain', 'install', 'nightly'
  end

  if which 'cargo-add'
    puts ANSI.green { '`cargo-edit` already installed.' }
  else
    puts ANSI.blue { 'Installing `cargo-edit` …' }
    sh 'cargo', 'install', 'cargo-edit'
  end

  if which 'racer'
    puts ANSI.green { '`racer` already installed.' }
  else
    puts ANSI.blue { 'Installing `racer` …' }
    sh 'cargo', '+nightly', 'install', 'racer'
  end
end
