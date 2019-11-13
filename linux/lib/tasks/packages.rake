task :packages => :yay do 
	%W[
		visual-studio-code-bin
		gitkraken
		sublime-merge
		piper
		openmpi
		boost
		ttf-windows
		telegram-desktop
		xdotool
		xorg-xinput
		teamspeak3
		teamspeak3-kde-wrapper
	].each do |package|
		sh 'yay', '-S', '--noconfirm', package
	end
end
