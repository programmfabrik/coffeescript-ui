###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###
CUI.Template.loadTemplateText(require('./ProgressMeter.html'));

class CUI.ProgressMeter extends CUI.DOMElement
	constructor: (opts) ->
		super(opts)

		@__meter = new CUI.Template
			name: "progress-meter"
			map:
				icon: true
				text: true
				fill: true

		@registerTemplate(@__meter)

		if @_state
			@setState(@_state)
		else if @_states.length
			@setState(@_states[0])

	__checkState: (state) ->
		state in @_states or (typeof(state) == "number" and state >= 0 and state <= 100)

	initOpts: ->
		super()

		if not @opts.states
			@opts.states = Object.keys(CUI.defaults.ProgressMeter.states)

		@addOpts
			states:
				check: Array
			state:
				check: (v) =>
					@__checkState(v)
			# css property to set to the current
			# percent fill, filler will be hidden
			# if percent is null
			css_property_percent:
				default: "width"
				check: String
			size:
				default: "auto"
				mandatory: true
				check: ["auto","mini","normal","big"]
			appearance:
				default: "auto"
				mandatory: true
				check: ["auto","normal","important"]
			onUpdate:
				check: Function

		for state in @opts.states
			@addOpt "icon_"+state,
				default: CUI.defaults.ProgressMeter.states[state]
				check: (v) =>
					v instanceof CUI.Icon or CUI.util.isString(v)

	getState: ->
		@__state

	getMeter: ->
		@__meter

	setState: (state) ->

		CUI.util.assert(@__checkState(state), "ProgressMeter.setState", "state needs to be "+@_states.join(",")+" or between 0 and 100.", state: state)
		if typeof(state) == "number"
			state = Math.round(state*100)/100

		if @__state == state
			return

		@__state = state
		if @__state in @_states
			if @__state == "spinning2"
				@__meter.replace(@getAnimatedHourglassIcon(), "icon")
			else
				icon = @["_icon_"+@__state]
				if icon instanceof CUI.Icon
					@__meter.replace(icon, "icon")
				else if not CUI.util.isEmpty(icon)
					@__meter.replace(new CUI.Icon(icon: icon), "icon")
				else
					@__meter.empty("icon")
			
			# console.debug icon, @__state
			@__meter.DOM.setAttribute("state", @__state)
			@__meter.empty("text")

			fill_css = {} #display: ""
			fill_css[@_css_property_percent] = ""
		else
			@__meter.DOM.setAttribute("state", "percent")
			@__meter.empty("icon")
			@__meter.replace(Math.round(@__state)+"%", "text")
			fill_css = {} #display: ""
			fill_css[@_css_property_percent] = @__state+"%"

		CUI.dom.setStyle(@__meter.map.fill, fill_css)
		@_onUpdate?.call(@, @)
		@

	getAnimatedHourglassIcon: ->
		hourglass_icons = [
			"fa-hourglass-start"
			"fa-hourglass-half"
			"fa-hourglass-end"
			"fa-hourglass-end"
			"fa-hourglass-o"
		]
		hourglass_container = CUI.dom.div("cui-hourglass-animation fa-stack")

		for i in hourglass_icons
			icon = new CUI.Icon
				icon: i
				class: "fa-stack-1x"

			CUI.dom.append(hourglass_container, icon.DOM)
		
		hourglass_container

CUI.defaults.ProgressMeter =
	states:
		waiting: "fa-hourglass"
		spinning: "svg-spinner cui-spin-stepped"
		spinning2: "fa-hourglass"
