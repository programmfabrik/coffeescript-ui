###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###
CUI.Template.loadTemplateText(require('./ProgressMeter.html'));

class CUI.ProgressMeter extends CUI.DOM
	constructor: (@opts={}) ->
		super(@opts)

		@__meter = new Template
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
					v instanceof Icon or isString(v)

	getState: ->
		@__state

	getMeter: ->
		@__meter

	setState: (state) ->

		assert(@__checkState(state), "ProgressMeter.setState", "state needs to be "+@_states.join(",")+" or between 0 and 100.", state: state)
		if typeof(state) == "number"
			state = Math.round(state*100)/100

		if @__state == state
			return

		@__state = state
		if @__state in @_states
			icon = @["_icon_"+@__state]
			if icon instanceof Icon
				@__meter.replace(icon, "icon")
			else if not isEmpty(icon)
				@__meter.replace(new Icon(icon: icon), "icon")
			else
				@__meter.empty("icon")
			# CUI.debug icon, @__state
			@__meter.DOM.attr("state", @__state)
			@__meter.empty("text")

			fill_css = {} #display: ""
			fill_css[@_css_property_percent] = ""
		else
			@__meter.DOM.attr("state", "percent")
			@__meter.empty("icon")
			@__meter.replace(Math.round(@__state)+"%", "text")
			fill_css = {} #display: ""
			fill_css[@_css_property_percent] = @__state+"%"

		@__meter.map.fill.css(fill_css)
		@_onUpdate?.call(@, @)
		@

CUI.defaults.ProgressMeter =
	states:
		waiting: "fa-hourglass"
		spinning: "svg-spinner cui-spin-stepped"
