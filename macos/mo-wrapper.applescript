-- Mo.app wrapper: receives Apple Events from Finder and forwards to mo CLI

on findMo()
	set searchPaths to {"/opt/homebrew/bin/mo", "/usr/local/bin/mo"}
	repeat with p in searchPaths
		try
			do shell script "test -x " & quoted form of p
			return p
		end try
	end repeat
	-- Fallback: which mo
	try
		set whichResult to do shell script "which mo 2>/dev/null"
		if whichResult is not "" then return whichResult
	end try
	return missing value
end findMo

-- Finder sends this when files are dropped or "Open With" is used
on open theFiles
	set moPath to findMo()
	if moPath is missing value then
		display dialog "mo command not found." & return & return & "Install via Homebrew:" & return & "  brew install k1LoW/tap/mo" & return & return & "Or download from:" & return & "  https://github.com/k1LoW/mo/releases" buttons {"OK"} default button "OK" with icon caution with title "Mo"
		return
	end if

	set fileArgs to ""
	repeat with f in theFiles
		set filePath to POSIX path of f
		set fileArgs to fileArgs & " " & quoted form of filePath
	end repeat

	do shell script moPath & " --open" & fileArgs & " &> /dev/null &"
end open

-- Double-clicking the app icon (no files)
on run
	set moPath to findMo()
	if moPath is missing value then
		display dialog "mo command not found." & return & return & "Install via Homebrew:" & return & "  brew install k1LoW/tap/mo" & return & return & "Or download from:" & return & "  https://github.com/k1LoW/mo/releases" buttons {"OK"} default button "OK" with icon caution with title "Mo"
		return
	end if

	do shell script moPath & " --open &> /dev/null &"
end run
