###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.MultiInputControl extends CUI.Element


	constructor: (@opts={}) ->
		super(@opts)
		@__body = document.body

		@setKeys(@_keys)
		@setPreferredKey(@_preferred_key)

	initOpts: ->
		super()
		@addOpts
			preferred_key:
				check: String
			keys:
				check: (v) ->
					CUI.util.isArray(v) and v.length > 0
			user_control:
				default: true
				check: Boolean

	setKeys: (keys) ->
		@__keys = []

		if not keys
			return

		key_names = {}
		for key, idx in keys
			CUI.util.assert(CUI.util.isString(key.name) and not CUI.util.isEmpty(key.name), "new #{@__cls}", "opts.keys[#{idx}].name must be non-empty String.", key: key)
			CUI.util.assert(CUI.util.isString(key.tag) and not CUI.util.isEmpty(key.tag), "new #{@__cls}", "opts.keys[#{idx}].tag must be non-empty String.", key: key)
			CUI.util.assert(CUI.util.isUndef(key.enabled) or CUI.util.isBoolean(key.enabled), "new #{@__cls}", "opts.keys[#{idx}].enabled must be Boolean.", key: key)

			if not CUI.util.isUndef(key_names[key.name])
				CUI.util.assert(false, "new #{@__cls}", "Duplicate opts.keys[#{idx}].name \"#{key.name}\", name already used in ##{idx}.", key: key)
				continue

			key_names[key.name] = idx

			@__keys.push
				name: key.name
				tag: key.tag
				enabled: key.enabled
				tooltip: key.tooltip
				__idx: idx

		@

	setPreferredKey: (key_name) ->
		@__preferred_key = null
		if CUI.util.isNull(key_name)
			return @__preferred_key

		for key in @__keys
			if key.name == key_name
				@__preferred_key = key

		CUI.util.assert(@__preferred_key, "#{@__cls}.setPreferredKey", "key.name == \"#{key_name}\" not found in keys.", keys: @__keys)
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
						console.debug "control activate", key.tag
						key.enabled = true
						CUI.Events.trigger(type: "multi-input-control-update")
					onDeactivate: (cb) ->
						console.debug "control deactivate", key.tag
						key.enabled = false
						CUI.Events.trigger(type: "multi-input-control-update")
					text: key.tag
		options

	showUserControl:  ->
		options = new CUI.Options
			min_checked: 1
			options: @getUserControlOptions()
		.start()

		@popover = new CUI.Modal
			class: "cui-multi-input-control"
			onHide: =>
				@popover = null
			pane:
				footer_right: new CUI.Button
					text: "Done"
					onClick: =>
						@popover.destroy()

				header_left: new CUI.Label(text: "MultiInputControl")
				content: options
		.show()

	hasUserControl: ->
		@_user_control


CUI.Events.registerEvent
	type: "multi-input-control-update"
	sink: true

