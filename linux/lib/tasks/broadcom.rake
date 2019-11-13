task :broadcom => :yay do 
  sh 'yay', '-S', '--noconfirm', 'linux-headers'
  sh 'yay', '-S', '--noconfirm', 'broadcom-wl'
  sh 'sudo', 'rmmod', 'b44', 'b43', 'b43legacy', 'ssb', 'brcmsmac', 'bcma'
  sh 'sudo', 'modprobe', 'wl'
end
