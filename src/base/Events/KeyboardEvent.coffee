class CUI.KeyboardEvent extends CUI.Event

	getKeys: ->
		CUI.KeyboardEvent.__keys

	getKeyboard: ->
		keys = @getModifiers()
		keys.push.apply(keys, @getKeys())
		keys.join("+")

	# Returns the visible keyboard key
	# "key" only returns the native event key which is different
	# between OSs
	keyboardKey: ->
		key = @keyCode()
		if key in [96..105]
			s = "Num"+String.fromCharCode(key-48)
		if key in [112..123]
			s = "F"+String.fromCharCode(key-111)
		else
			switch key
				when 8
					s = "Backspace"
				when 9
					s = "Tab"
				when 13
					s = "Return"
				when 16
					s = "Shift"
				when 17
					s = "Ctrl"
				when 18
					s = "Alt"
				when 20
					s = "CapsLock"
				when 27
					s = "Esc"
				when 32
					s = "Space"
				when 33
					s = "PageUp"
				when 34
					s = "PageDown"
				when 37
					s = "Left"
				when 38
					s = "Up"
				when 39
					s = "Right"
				when 40
					s = "Down"
				when 46
					s = "Insert"
				when 46
					s = "Delete"
				when 110
					s = "Num."
				when 144
					s = "Numlock"
				when 111
					s = "Num/"
				when 106
					s = "Num*"
				when 107
					s = "Num+"
				else
					s = String.fromCharCode(key)
		console.debug key, s
		s

	key: ->
		@getNativeEvent().key

	dump: ->
		txt = @__cls+": **"+@getType()+"**"
		txt += " Key: **"+@key()+"** KeyCode: **"+@keyCode()+"**"
		keyboard = @getKeyboard()
		if keyboard.length > 0
			txt = txt + " Keyboard: **"+keyboard+"**"
		txt

	@isModifierKey: (keyCode) ->
		switch keyCode
			when 16, 17, 18, 91, 93
				true
			else
				false

	@initKeyboardListener: ->
		CUI.KeyboardEvent.__keys = []
		CUI.KeyboardEvent.__modifier_keys = []

		Events.listen
			type: ["keydown"]
			node: window
			capture: true
			call: (ev) ->
				console.debug "keyboard key:", ev.keyboardKey()
				if not KeyboardEvent.isModifierKey(ev.keyCode())
					pushOntoArray(ev.keyboardKey(), CUI.KeyboardEvent.__keys)

				return

		Events.listen
			type: ["keyup"]
			node: window
			capture: true
			call: (ev) ->

				if not KeyboardEvent.isModifierKey(ev.keyCode())
					removeFromArray(ev.keyboardKey(), CUI.KeyboardEvent.__keys)

				return

		Events.listen
			type: ["blur"]
			node: window
			capture: true
			call: (ev) ->
				# console.debug "blur windo"
				CUI.KeyboardEvent.__keys = []

CUI.ready =>
	CUI.KeyboardEvent.initKeyboardListener()
