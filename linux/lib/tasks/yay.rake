task :yay do
	cd '/tmp/' do
		system 'git', 'clone', 'https://aur.archlinux.org/yay.git'

		cd 'yay' do
			sh 'makepkg', '-si', '--noconfirm'
		end
	end
end