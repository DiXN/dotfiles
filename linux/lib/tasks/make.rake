
# frozen_string_literal: true

require 'environment'

task :make do
  add_line_to_file fish_environment, 'set -l cores (nproc); and set -x MAKEFLAGS "-j $cores -l $cores"'
  add_line_to_file bash_environment, 'cores="$(nproc)" && export MAKEFLAGS="-j $cores -l $cores"'
end
