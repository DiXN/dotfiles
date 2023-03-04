#!/usr/bin/env -S v run

import os
import cli
import json

struct App {
  name string [json:app]
}

struct Pacman {
  packages []App [json:pacman]
}

fn get_packages() Pacman {
  dotfiles_root := os.getenv_opt('DOTFILES_ROOT') or {
    eprintln('["DOTFILES_ROOT" environment variable must be set ...]')
    exit(-1)
  }

  execute('git -c $dotfiles_root pull')

  // Get JSON representation of the YAML file.
  package_json := execute('cat $dotfiles_root/src/templates/base/pacman.yaml | yq .')

  package_output := package_json.output
  pacman := json.decode(Pacman, package_output) or {
	  eprintln(err)
	  exit(-1)
  }

  return pacman
}

fn install_package(package string) {
  mut install := os.Command {
    path: 'yay --noconfirm -Syy $package'
    redirect_stdout: true
  }

  error := '[Could not install "$package" ...]'

  install.start() or { eprintln(error) }

	for !install.eof {
		line := install.read_line()
		println(line)
	}

	install.close() or { eprintln(error) }
}

fn print_cmd(command string, error ?string) {
  mut cmd := os.Command {
    path: command
    redirect_stdout: true
  }

  cmd.start() or {
    eprintln(error or { err })
    exit(-1)
  }

	for !cmd.eof {
		line := cmd.read_line()
		println(line)
	}

	cmd.close() or {
    eprintln(error or { err })
    exit(-1)
	}
}

mut app := cli.Command{
  name: 'system'
  description: 'system management utility'
  execute: fn (cmd cli.Command) ! {
    cmd.execute_help()
  }
  commands: [
    cli.Command{
      name: 'build'
      description: 'Build mkosi image.'
      execute: fn (cmd cli.Command) ! {
        dotfiles_root := os.getenv_opt('DOTFILES_ROOT') or {
          eprintln('["DOTFILES_ROOT" environment variable must be set ...]')
          exit(-1)
        }

        println('[Build mkosi image ...]')

        os.chdir('$dotfiles_root/linux/mkosi/') or {
          eprintln(err)
          exit(-1)
        }

        execute('rm -f ./mkosi.skeleton.tar')
        execute('docker export -o ./mkosi.skeleton.tar $(docker run -d arch-full /bin/true)')

        print_cmd('sudo mkosi -ff', none)
      }
    },
    cli.Command{
      name: 'update'
      description: 'Runs "essentials.sh".'
      execute: fn (cmd cli.Command) ! {
        dotfiles_root := os.getenv_opt('DOTFILES_ROOT') or {
          eprintln('["DOTFILES_ROOT" environment variable must be set ...]')
          exit(-1)
        }

        println('[Rerun "essentials.sh" ...]')
        print_cmd('RERUN=true bash $dotfiles_root/linux/scripts/essentials.sh', none)
      }
    },
    cli.Command{
      name: 'install'
      description: 'Install image on target disk.'
      required_args: 1
      execute: fn (cmd cli.Command) ! {
        target_disk := cmd.args.first()
        println('[Installing system on disk: "$target_disk" ...]')

        os.mkdir_all('/mnt/nas') or {
          eprintln(err)
          exit(-1)
        }

        execute('sudo mount -t nfs 10.0.0.5:/media /mnt/nas')
        execute('sudo wipefs --all $target_disk')

        error := '[Could not install system ...]'

        print_cmd('sudo dd if=/mnt/nas/iso/arch.img of=$target_disk bs=4096 conv=noerror,sync', error)

        print_cmd('sudo growpart $target_disk 2', error)
      },
    },
    cli.Command{
      name: 'packages'
      description: 'Install or update packages.'
      execute: fn (cmd cli.Command) ! {
        cli.print_help_for_command(cmd) !
        cmd.execute_help()
      },
      commands: [
        cli.Command{
          name: 'install'
          description: 'Install packages from "pacman.yaml".'
          execute: fn (cmd cli.Command) ! {
            pacman := get_packages()

            for package in pacman.packages {
              status := execute('yay -Q $package.name')

              if status.exit_code == 1 {
                println('[Installing missing package "$package.name" ...]')
                install_package(package.name)
              }
            }

          },
        },
        cli.Command{
          name: 'update'
          description: 'Update packages from "pacman.yaml".'
          execute: fn (cmd cli.Command) ! {
            pacman := get_packages()

            for package in pacman.packages {
              println('[Updating package "$package.name" ...]')
              install_package(package.name)
            }
          },
        },
      ]
    },
  ]
}

app.setup()
app.parse(os.args)
