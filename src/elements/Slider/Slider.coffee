CUI.Template.loadTemplateText(require('./Slider.html'));

class CUI.Slider extends CUI.DataField

	initOpts: ->
		super()
		@addOpts
			value:
				check: (v) ->
					CUI.util.isInteger(v)
			min:
				mandatory: true
				default: 0
				check: (v) ->
					CUI.util.isInteger(v)
			max:
				mandatory: true
				default: 100
				check: (v) ->
					CUI.util.isInteger(v)
			onDragstart:
				check: Function
			onDragging:
				check: Function
			onDrop:
				check: Function
			onUpdate:
				check: Function

	readOpts: ->
		super()
		@__distance = @_max - @_min
		CUI.util.assert(@__distance > 1, 'new CUI.Slider', 'opts.min and opts.max need to be at least 2 apart.')
		@__value = @getDefaultValue()

	getTemplate: ->
		@__slider = new CUI.Template
			name: "slider"
			map:
				track: true
				track_visual: true
				handle: true

	initDimensions: ->
		@__track_dim = CUI.dom.getDimensions(@__track)
		@__handle_dim = CUI.dom.getDimensions(@__handle)
		@__track_available =
			width: @__track_dim.contentBoxWidth - (@__handle_dim.borderBoxWidth / 2)
			height: @__track_dim.contentBoxHeight - (@__handle_dim.borderBoxHeight / 2)

	render: ->
		super()

		@__handle = @__slider.map.handle
		@__track = @__slider.map.track

		new CUI.Draggable
			element: @__handle
			helper: null
			dragstart: (ev, gd) =>
				@initDimensions()
				@addClass('cui-slider--dragging')
				@__last_diff_x = 0
				@__start_value = @__value
				@_onDragstart?(@, @__start_value)
			dragstop: =>
				@setValue(@__start_value)
				@removeClass('cui-slider--dragging')
				@_onDrop?(@)
			dragend: =>
				@removeClass('cui-slider--dragging')
				@_onDrop?(@)
			dragging: (ev, gd) =>

				diff_x = gd.dragDiff.bare_x - @__last_diff_x

				@__last_diff_x = gd.dragDiff.bare_x

				precision = @__track_available.width / @__distance

				precision_factor = (gd.dragDiff.bare_y / 5)

				if precision_factor > 1
					use_precision = Math.min(1, precision * precision_factor)
				else
					use_precision = precision

				# console.debug diff_x, precision, precision_factor, use_precision
				@setValue(@__value + (diff_x / use_precision))
				@_onDragging?(@, @getValue())

		CUI.Events.listen
			type: 'click'
			node: @__slider.map.track_visual
			call: (ev) =>
				@initDimensions()
				track_clientX = @__track_dim.clientBoundingRect.left
				click_clientX = ev.getNativeEvent().clientX
				@setValue((click_clientX - track_clientX) / @__track_available.width * @__distance)
				return

	getValue: ->
		if @hasData()
			super()
		else
			@__value

	getHandle: ->
		@__slider.map.handle

	setValue: (_v, flags={}) ->
		v = Math.round(Math.min(Math.max(@_min, _v), @_max))
		@__value = v

		if flags.no_trigger == undefined
			flags.no_trigger = false

		super(@__value, flags)
		@

	getDefaultValue: ->
		if @_value == undefined
			@_min # Math.round((@_max - @_min) / 2)
		else
			@_value

	displayValue: ->
		percent = @getValue() / @_max * 100
		CUI.dom.setStyle(@__handle, left: percent + '%')
		CUI.dom.setStyle(@__slider, '--slider-distance': percent + '%')
		@_onUpdate?(@, @getValue())

	checkValue: (v, flags) ->
		if v < @_min or v > @_max
			throw new CUI.CheckValueError('value needs to be between '+@_min+' and '+@_max)
		@
