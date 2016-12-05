###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class MultiInputControl extends CUI.Element
	constructor: (@opts={}) ->
		super(@opts)
		@__body = $(document.body)
		@__keys = []

		if not @_keys
			return

		key_names = {}
		for key, idx in @_keys
			assert(isString(key.name) and not isEmpty(key.name), "new #{@__cls}", "opts.keys[#{idx}].name must be non-empty String.", opts: @opts, key: key)
			assert(isString(key.tag) and not isEmpty(key.tag), "new #{@__cls}", "opts.keys[#{idx}].tag must be non-empty String.", opts: @opts, key: key)
			assert(isUndef(key.enabled) or isBoolean(key.enabled), "new #{@__cls}", "opts.keys[#{idx}].enabled must be Boolean.", opts: @opts, key: key)

			if key_names.hasOwnProperty(key.name)
				assert(false, "new #{@__cls}", "Duplicate opts.keys[#{idx}].name \"#{key.name}\", name already used in ##{idx}. Skipping.", opts: @opts, key: key)
				continue

			key_names[key.name] = idx

			@__keys.push
				name: key.name
				tag: key.tag
				enabled: key.enabled
				__idx: idx

		@setPreferredKey(@_preferred_key)

	initOpts: ->
		super()
		@addOpts
			preferred_key:
				check: String
			keys:
				check: (v) ->
					CUI.isArray(v) and v.length > 0
			user_control:
				default: true
				check: Boolean

	setPreferredKey: (key_name) ->
		@__preferred_key = null
		if isNull(key_name)
			return @__preferred_key

		for key in @__keys
			if key.name == key_name
				@__preferred_key = key

		assert(@__preferred_key, "#{@__cls}.setPreferredKey", "key.name == \"#{key_name}\" not found in keys.", keys: @__keys)
		@__preferred_key

	getPreferredKey: ->
		@__preferred_key

	# avoid copying this
	copy: ->
		@

	getKeys: ->
		@__keys

	isEnabled: (name) ->
		for k in @getKeys()
			if k.name == name
				return k.enabled
		return undefined


	getUserControlOptions: ->
		options = []
		for key in @__keys
			do (key) ->
				options.push
					active: key.enabled
					onActivate: ->
						CUI.debug "control activate", key.tag
						key.enabled = true
						Events.trigger(type: "multi-input-control-update")
					onDeactivate: (cb) ->
						CUI.debug "control deactivate", key.tag
						key.enabled = false
						Events.trigger(type: "multi-input-control-update")
					text: key.tag
		options

	showUserControl:  ->
		options = new Options
			min_checked: 1
			options: @getUserControlOptions()
		.start()

		@popover = new Modal
			class: "cui-multi-input-control"
			onHide: =>
				@popover = null
			pane:
				footer_right: new Button
					text: "Done"
					onClick: =>
						@popover.destroy()

				header_left: new Label(text: "MultiInputControl")
				content: options
		.show()

	hasUserControl: ->
		@_user_control


CUI.Events.registerEvent
	type: "multi-input-control-update"
	sink: true

