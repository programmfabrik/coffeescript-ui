###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.KeyboardEvent extends CUI.Event

	getKeyboard: ->
		keys = @getModifiers()
		keys.push.apply(keys, CUI.KeyboardEvent.__keys)
		keys.join("+")

	# Returns the visible keyboard key
	# "key" only returns the native event key which is different
	# between OSs
	__keyboardKey: ->
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

	@__initKeyboardListener: ->
		is_modifier = (keyCode) ->
			switch keyCode
				when 16, 17, 18, 91, 93
					true
				else
					false

		CUI.KeyboardEvent.__keys = []

		Events.listen
			type: ["keydown"]
			node: window
			capture: true
			call: (ev) ->
				if not is_modifier(ev.keyCode())
					CUI.util.pushOntoArray(ev.__keyboardKey(), CUI.KeyboardEvent.__keys)

				return

		Events.listen
			type: ["keyup"]
			node: window
			capture: true
			call: (ev) ->

				if not is_modifier(ev.keyCode())
					CUI.util.removeFromArray(ev.__keyboardKey(), CUI.KeyboardEvent.__keys)

				return

		Events.listen
			type: ["blur"]
			node: window
			capture: true
			call: (ev) ->
				# console.debug "blur windo"
				CUI.KeyboardEvent.__keys = []

CUI.ready =>
	CUI.KeyboardEvent.__initKeyboardListener()
