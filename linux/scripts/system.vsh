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
  dotfiles_root := os.getenv('DOTFILES_ROOT')
  execute('git -c $dotfiles_root pull')
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

mut app := cli.Command{
  name: 'system'
  description: 'system management utility'
  execute: fn (cmd cli.Command) ! {
    cli.print_help_for_command(cmd) !
    cmd.execute_help()
  }
  commands: [
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

        mut dd := os.Command {
          path: 'sudo dd if=/mnt/nas/iso/arch.img of=$target_disk bs=4096 conv=noerror,sync'
          redirect_stdout: true
        }

        dd.start() or { 
          eprintln(error)
          exit(-1)
        }

	      for !dd.eof {
		      line := dd.read_line()
		      println(line)
	      }

	      dd.close() !

        mut grow := os.Command {
          path: 'sudo growpart $target_disk 2'
          redirect_stdout: true
        }

        grow.start() or { 
          eprintln(error)
          exit(-1)
        }

	      for !grow.eof {
		      line := grow.read_line()
		      println(line)
	      }

	      grow.close() !
      },
    },
    cli.Command{
      name: 'packages'
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

