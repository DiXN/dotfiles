require 'environment'

task :link do
  cd '/tmp/' do
    system 'git', 'clone', 'https://github.com/audiohacked/OpenCorsairLink.git'

    cd 'OpenCorsairLink' do
      sh 'make'
      sh 'sudo', 'make', 'install'
    end
  end

  add_line_to_file bash_environment, 'alias clink="sudo /usr/local/bin/OpenCorsairLink.elf --device 0"'
  add_line_to_file fish_environment, 'alias clink="sudo /usr/local/bin/OpenCorsairLink.elf --device 0"'
end
