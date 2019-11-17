task :konsole do
	add_line_to_file '~/.local/share/konsole/Shell.profile', <<~eos
		[Appearance]
		ColorScheme=SolarizedLight
		Font=SF Mono,10,-1,5,50,0,0,0,0,0,Regular

		[General]
		Name=Shell
		Parent=FALLBACK/

		[Interaction Options]
		MiddleClickPasteMode=1
	eos

	add_line_to_file '~/.local/share/konsole/SolarizedLight.colorscheme', <<~eos
		[Background]
		Color=253,239,204

		[BackgroundFaint]
		Color=253,246,227

		[BackgroundIntense]
		Color=238,233,213

		[Color0]
		Color=7,54,66

		[Color0Faint]
		Color=8,65,80

		[Color0Intense]
		Color=0,43,54

		[Color1]
		Color=220,50,47

		[Color1Faint]
		Color=222,81,81

		[Color1Intense]
		Color=203,75,22

		[Color2]
		Color=133,153,0

		[Color2Faint]
		Color=153,168,39

		[Color2Intense]
		Color=88,110,117

		[Color3]
		Color=181,137,0

		[Color3Faint]
		Color=213,170,49

		[Color3Intense]
		Color=101,123,131

		[Color4]
		Color=38,139,210

		[Color4Faint]
		Color=80,173,226

		[Color4Intense]
		Color=131,148,150

		[Color5]
		Color=211,54,130

		[Color5Faint]
		Color=223,92,158

		[Color5Intense]
		Color=108,113,196

		[Color6]
		Color=42,161,152

		[Color6Faint]
		Color=78,211,200

		[Color6Intense]
		Color=147,161,161

		[Color7]
		Color=238,232,213

		[Color7Faint]
		Color=238,232,213

		[Color7Intense]
		Color=253,246,227

		[Foreground]
		Color=101,123,131

		[ForegroundFaint]
		Color=141,172,182

		[ForegroundIntense]
		Color=88,110,117

		[General]
		Blur=true
		Description=Solarized Light
		Opacity=0.88
		Wallpaper=
	eos
end
