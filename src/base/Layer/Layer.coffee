# a layer is a top level positioned div
# which can be used to display Menu
# Popver, Modal, Autocompletion and
# other dialogs


class CUI.Layer extends CUI.DOM

	constructor: (@opts={}) ->
		super(@opts)

		@__layer = @getTemplate()

		# layer is registered as our main layer TODO register layer_root as our main layer!
		@registerTemplate(@__layer)
		# @__layer.DOM.attr("role", @_role)

		# layer root is a container for the backdrop, pointer and layer
		#
		# this is only to hold all nodes in one node, the backdrop is a sibling
		# of the layer, that way we can give the backdrop an opacity which does
		# not affect the layer's opacity as it would to if the layer would be
		# a child of backdrop
		@__layer_root = new Template
			class: "cui-layer-root-"+(toDash(@__cls)+" "+@_class).trim().split(/\s+/).join(" cui-layer-root-")
			name: "layer-root"

		# @__backdropClickDisabled = false

		if @_backdrop

			@__bd_policy = @_backdrop.policy or "click-thru"

			@__backdrop = new Template
				class: "cui-layer-backdrop"
				name: "layer-backdrop"

			@__layer_root.addClass("cui-layer-backdrop-policy-"+@__bd_policy)

			if @_backdrop.content
				@setBackdropContent(@_backdrop.content)
			else if @_backdrop.blur
				# clone body
				body_clone = document.body.firstChild.cloneNode(true)

				if @__bd_policy == "click-thru"
					# backdrop needs to be cropped
					@__backdrop_crop = @__backdrop.DOM
					@setBackdropContent(body_clone)
				else
					@__backdrop_crop = $div("cui-layer-backdrop-body-clone")[0]
					@__backdrop_crop.appendChild(body_clone)
					@setBackdropContent(@__backdrop_crop)

				# console.error "crop this:", @__backdrop_crop
				@__layer_root.addClass("cui-layer-root-backdrop-blur")


			if @__bd_policy == "click-thru" and not @_backdrop.blur and not @_backdrop.content
				; # @__addClickThruListenerOnShow = true
			else
				@__layer_root.DOM.appendChild(@__backdrop.DOM)

				# @__backdrop.DOM.attr("role", @_role)

				switch @__bd_policy
					when "click-thru"
						; # @__addClickThruListener()
					when "click"
						Events.listen
							type: ["click", "contextmenu"]
							node: @__backdrop
							call: (ev) =>
								if ev.ctrlKey() and ev.getButton() == 2
									return

								# if @__backdropClickDisabled
								# 	return

								@hide(ev)
								ev.stopPropagation()

					when "modal"
						@__backdrop.addClass("cui-layer-backdrop--visible")
						if @_backdrop.add_bounce_class != false
							if isString(@_backdrop.add_bounce_class)
								bc = @_backdrop.add_bounce_class
							else
								bc = "cui-layer-bounce"

							Events.listen
								type: "click"
								node: @__backdrop
								call: (ev) =>
									CUI.debug "clicked on modal backdrop", bc, @_backdrop
									if not @__layer
										return

									Events.wait
										type: "transitionend"
										node: @__layer
									.always =>
										if @isDestroyed()
											return

										@__layer.removeClass(bc)

									@__layer.addClass(bc)
									return

					else
						assert("new #{@__cls}", "Unknown backdrop policy: \"#{@__bd_policy}\".")

		if @_visible == false
			@setVisible(@_visible)

		@__layer_root.DOM.appendChild(@__layer.DOM)

		Events.listen
			type: "click"
			node: @__layer
			call: (ev) =>
				if not ev.altKey()
					return
				@hide()
				@show()

		if @_handle_focus
			DOM.setAttribute(@__layer.DOM, "tabindex", "0")

		if @_element
			@__setElement(@_element)

		if @_use_element_width_as_min_width
			assert(@__element, "new CUI.Layer", "opts.use_element_width_as_min_width requires opts.element to be set.", opts: @opts)

		if @_pointer
			if @_class
				cls = "cui-layer-pointer-"+@_class.split(/\s+/).join(" cui-layer-pointer-")

			@__pointer = new Template
				class: cls
				name: "layer-pointer"
			.DOM

			#append pointer and make sure pointer is rendered beneath layer.
			@__layer_root.DOM.appendChild(@__pointer)


		@__shown = false


	# __addClickThruListener: ->
	# 	Events.listen
	# 		type: "mousedown"
	# 		capture: true
	# 		node: window
	# 		call: (ev) =>
	# 			console.debug "ev", ev.getTarget(), CUI.DOM.parents(ev.getTarget())

	# 			if ev.ctrlKey() and ev.getButton() == 2
	# 				return

	# 			if CUI.DOM.closest(ev.getTarget(), ".cui-tmpl-layer-root")
	# 				console.debug "ignoring click on layer 'backdrop'"
	# 				return

	# 			# if @__backdropClickDisabled
	# 			# 	# this is used in Popover when all buttons are disabled
	# 			# 	# we need to eat this
	# 			# 	return

	# 			@hide(ev)
	# 			return


	# disableBackdropClick: ->
	# 	@__backdropClickDisabled = true
	# 	@

	# enableBackdropClick: ->
	# 	@__backdropClickDisabled = false
	# 	@

	setBackdropContent: (content) ->
		assert(@__backdrop, "CUI.Layer.setBackdropContent", "No backdrop found in layer", layer: @)
		@__backdrop.DOM.append(content)

	getTemplate: ->
		new Template(name: "layer")

	getLayerRoot: ->
		@__layer_root

	getLayer: ->
		@__layer

	initOpts: ->
		super()
		@addOpts
			# role:
			#	mandatory: true
			#	check: String
			# set to true if a backdrop should be
			# added to the DOM tree
			backdrop:
				default:
					policy: "click-thru"
					add_bounce_class: true
					content: null

				check: (v) ->
					if CUI.isPlainObject(v) or v == false
						return true

			# if added, a bounce class will be added and after a css transition
			# removed to the layer, if the user clicks on a modal backdrop
			# the bounce class defaults to "cui-layer-bounce"
			add_bounce_class:
				deprecated: "use backdrop.add_bounce_class instead"

			onBeforeShow:
				check: Function
			onShow:
				check: Function
			onPosition:
				check: Function
			onHide:
				check: Function

			# handle focus on tab index
			handle_focus:
				default: true
				check: Boolean


			# a rectangle box to position the layer to
			# a pointer is a helper to show the position of the layer
			# allowed values are "arrow"
			pointer:
				check: ["arrow"]
			# the preferred placement
			placement:
				check: String
			placements:
				check: (v) ->
					if not CUI.isArray(v)
						return false
					for a in v
						if CUI.Layer.knownPlacements.indexOf(a) == -1
							return false
					return true

			# element to position the layer to
			element:
				check: (v) ->
					isElement(v) or isElement(v?.DOM)

			use_element_width_as_min_width:
				default: false
				check: Boolean

			show_at_position:
				check: (v) ->
					CUI.isPlainObject(v) and v.top >= 0 and v.left >= 0

			# fills the available space to the maximum
			# if used with "placement", the placement is not
			# chosen
			#
			# auto: check if width or height is already set, use the other
			#
			#
			# both: overwrite width and height, no matter what
			# horizontal: stretch width only
			# vertical: stretch height only
			fill_space:
				default: "auto"
				mandatory: true
				check: ["auto", "both", "horizontal", "vertical"]

			# if set, the Layer, when shown checks if the "element"
			# is still in the DOM tree
			check_for_element:
				default: false
				check: Boolean

			show_ms:
				default: 700
				check: (v) =>
					v > 0

			visible:
				check: Boolean

			hide_ms:
				default: 100
				check: (v) =>
					v > 0

			#
		@


	setVisible: (on_off=true) ->
		if on_off
			DOM.setStyleOne(@__layer_root.DOM, "visibility", "")
		else
			DOM.setStyleOne(@__layer_root.DOM, "visibility", "hidden")

	@knownPlacements: ["s", "e", "w", "ws", "wn", "n", "se", "ne", "es", "en", "nw", "sw", "c"]

	__setElement: (element) ->
		if element instanceof CUI.DOM
			@__element = element.getElementForLayer()
		else if element.DOM
			@__element = element.DOM
		else
			@__element = element

		assert(not DOM.closest(@__element, ".cui-tmpl"), "Layer.__setElement", "element cannot be inside a Template.", element: element)
		assert(@__element instanceof HTMLElement, "Layer.__setElement", "element needs to be HTMLElement.", element: element)
		@__element

	autoSize: ->
		@position()

	position: (ev) ->
		#
		if not @isShown()
			return

		dim_window = CUI.DOM.getDimensions(window)

		get_pointer_direction = (placement) ->
			# return direction
			{
				n: "s"
				s: "n"
				e: "w"
				w: "e"
			}[placement]

		get_pointer_class = (direction) =>
			if CUI.__ng__
				"cui-layer-pointer--"+direction
			else
				# we need to map this back, the interpretatin
				# in old css was different
				"cui-pointer-placement-"+get_pointer_direction(direction)

		if @__pointer
			# reset pointer
			CUI.DOM.setStyle(@__pointer,
				top: 0
				left: 0
				margin: ""
			)

			for direction in ["w", "s", "e", "n"]
				CUI.DOM.removeClass(@__pointer, get_pointer_class(direction))


		# measure all 4 directions for all pointers
		dim_pointer = {}
		for placement in ["n", "s", "e", "w"]

			pointer_direction = get_pointer_direction(placement)

			if @__pointer
				CUI.DOM.addClass(@__pointer, get_pointer_class(pointer_direction))

				dim_pointer[placement] = CUI.DOM.getDimensions(@__pointer)

				CUI.DOM.removeClass(@__pointer, get_pointer_class(pointer_direction))
			else
				dim_pointer[placement] =
					borderBoxWidth: 0
					borderBoxHeight: 0
					marginLeft: 0
					marginRight: 0
					marginTop: 0
					marginBottom: 0

			dim_pointer[placement].direction = pointer_direction

		# reset previously set layer dimensions
		CUI.DOM.setStyle @__layer.DOM,
			top: 0
			left: 0
			width: ""
			height: ""
			margin: ""
			minWidth: ""

		dim_layer = CUI.DOM.getDimensions(@__layer.DOM)

		allowed_placements = (@_placements or CUI.Layer.knownPlacements).slice(0)
		wanted_placement = @_placement or allowed_placements[0]

		if @__element
			dim_element = CUI.DOM.getDimensions(@__element)

		else if @_show_at_position
			dim_element =
				viewportTop: @_show_at_position.top
				viewportLeft: @_show_at_position.left

			dim_element.viewportBottom = dim_element.viewportTop
			dim_element.viewportRight = dim_element.viewportLeft
		else
			dim_element =
				viewportTop: 0
				viewportLeft: 0
				viewportBottom: dim_window.height
				viewportRight: dim_window.width
				viewportCenterLeft: dim_window.width / 2
				viewportCenterTop: dim_window.height / 2
				borderBoxWidth: dim_window.width
				borderBoxHeight: dim_window.height

		vp_pl = {}

		# calc all possible layer viewports
		for placement in CUI.Layer.knownPlacements
			if placement not in ["n", "s", "e", "w", "c"]
				continue

			vp_pl[placement] = vp = {}

			vp.window_top = dim_layer.marginTop
			vp.window_left = dim_layer.marginLeft
			vp.window_right = dim_window.width - dim_layer.marginRight
			vp.window_bottom = dim_window.height - dim_layer.marginBottom
			vp.dim_window = dim_window
			vp.dim_layer = dim_layer
			vp.dim_element = dim_element
			vp.dim_pointer = dim_pointer[placement]


			switch placement
				when "c"
					vp.top = vp.window_top
					vp.left = vp.window_left
					vp.right = vp.window_right
					vp.bottom = vp.window_bottom
					vp.align_vertical = "center"
					vp.align_horizontal = "center"
				when "n"
					vp.top = dim_layer.marginTop
					vp.left = dim_layer.marginLeft
					vp.right = dim_window.width - dim_layer.marginRight
					vp.bottom = dim_element.viewportTop - vp.dim_pointer.borderBoxHeight - vp.dim_pointer.marginBottom
					vp.align_vertical = "bottom"
					vp.align_horizontal = "center"
				when "s"
					vp.top = dim_element.viewportBottom + vp.dim_pointer.borderBoxHeight + vp.dim_pointer.marginTop
					vp.left = dim_layer.marginLeft
					vp.right = dim_window.width - dim_layer.marginRight
					vp.bottom = dim_window.height - dim_layer.marginBottom
					vp.align_vertical = "top"
					vp.align_horizontal = "center"
				when "e"
					vp.top = dim_layer.marginTop
					vp.right = dim_window.width - dim_layer.marginRight
					vp.bottom = dim_window.height - dim_layer.marginBottom
					vp.left = dim_element.viewportRight + vp.dim_pointer.borderBoxWidth + vp.dim_pointer.marginLeft
					vp.align_vertical = "center"
					vp.align_horizontal = "left"
				when "w"
					vp.top = dim_layer.marginTop
					vp.bottom = dim_window.height - dim_layer.marginBottom
					vp.right = dim_element.viewportLeft - vp.dim_pointer.borderBoxWidth - vp.dim_pointer.marginRight
					vp.left = dim_layer.marginLeft
					vp.align_vertical = "center"
					vp.align_horizontal = "right"

			vp.pointer_align_vertical = vp.align_vertical
			vp.pointer_align_horizontal = vp.align_horizontal

			vp.overlap_align = null

		# add two-direction placements
		for placement in CUI.Layer.knownPlacements
			if placement in ["n", "s", "e", "w", "c"]
				continue

			placement_parts = placement.split("")
			vp_pl[placement] = vp = copyObject(vp_pl[placement_parts[0]])

			vp.dim_pointer = dim_pointer[placement_parts[0]]

			if not vp
				continue

			switch placement_parts[1]
				when "s"
					vp.top = dim_element.viewportTop
					vp.align_vertical = "top"
					vp.pointer_align_vertical = "center"
					vp.overlap_align = "bottom"
				when "n"
					vp.bottom = dim_element.viewportBottom
					vp.align_vertical = "bottom"
					vp.pointer_align_vertical = "center"
					vp.overlap_align = "top"
				when "e"
					vp.left = dim_element.viewportLeft
					vp.align_horizontal = "left"
					vp.pointer_align_horizontal = "center"
					vp.overlap_align = "right"
				when "w"
					vp.right = dim_element.viewportRight
					vp.align_horizontal = "right"
					vp.pointer_align_horizontal = "center"
					vp.overlap_align = "left"

		# throw out placements which are too small
		for placement in CUI.Layer.knownPlacements
			if placement not in allowed_placements
				delete(vp_pl[placement])
				continue

			vp = vp_pl[placement]
			vp.width = vp.right - vp.left
			vp.height = vp.bottom - vp.top

			# placement might not be available, no space
			# FIXME: we can read minWidth & minHeight from layer
			# here, so the design can decide on a minimum
			if vp.width < 10 or vp.height < 10
				delete(vp_pl[placement])

		# now we need to position the layer within the available viewport
		for placement, vp of vp_pl

			layer_pos = vp.layer_pos = {}
			pointer_pos = vp.pointer_pos = {}

			# number of times we need to cut the layer
			# to make it fit into the viewport
			vp.cuts = 0

			# set width on height on the layer
			# depending on the available viewport and the
			# fill space policy
			switch @_fill_space
				when "both"
					layer_pos.width = vp.width
					layer_pos.height = vp.height
				when "vertical"
					layer_pos.height = vp.height
					layer_pos.width = dim_layer.borderBoxWidth
				when "horizontal"
					layer_pos.width = vp.width
					layer_pos.height = dim_layer.borderBoxHeight
				else
					layer_pos.width = dim_layer.borderBoxWidth
					layer_pos.height = dim_layer.borderBoxHeight

			if layer_pos.width > vp.width
				layer_pos.width = vp.width
				vp.cuts++

			if layer_pos.height > vp.height
				layer_pos.height = vp.height
				vp.cuts++

			# now align the layer within the available viewport
			switch vp.align_horizontal
				when "left"
					layer_pos.left = vp.left
				when "right"
					layer_pos.left = vp.right - layer_pos.width
				when "center"
					layer_pos.left = dim_element.viewportCenterLeft - layer_pos.width / 2

			switch vp.align_vertical
				when "top"
					layer_pos.top = vp.top
				when "bottom"
					layer_pos.top = vp.bottom - layer_pos.height
				when "center"
					layer_pos.top = dim_element.viewportCenterTop - layer_pos.height / 2


			if vp.dim_pointer
				# now align the pointer within the available viewport
				switch vp.pointer_align_horizontal
					when "left"
						pointer_pos.left = dim_element.viewportRight + vp.dim_pointer.marginLeft
					when "right"
						pointer_pos.left = dim_element.viewportLeft - vp.dim_pointer.borderBoxWidth - vp.dim_pointer.marginLeft
					when "center"
						pointer_pos.left = dim_element.viewportCenterLeft - vp.dim_pointer.borderBoxWidth / 2

				switch vp.pointer_align_vertical
					when "top"
						pointer_pos.top = dim_element.viewportBottom + vp.dim_pointer.marginTop
					when "bottom"
						pointer_pos.top = dim_element.viewportTop - vp.dim_pointer.marginBoxHeight + vp.dim_pointer.marginTop
					when "center"
						pointer_pos.top = dim_element.viewportCenterTop - vp.dim_pointer.borderBoxHeight / 2

				pointer_pos.width = vp.dim_pointer.borderBoxWidth
				pointer_pos.height = vp.dim_pointer.borderBoxHeight
				pointer_pos.direction = vp.dim_pointer.direction


			# move layer into viewport in case we overlap
			if layer_pos.top < vp.top
				layer_pos.top = vp.top
				vp.cuts++

			if layer_pos.left < vp.left
				layer_pos.left = vp.left
				vp.cuts++

			overlap_bottom = layer_pos.top + layer_pos.height - vp.bottom
			if overlap_bottom > 0
				layer_pos.top = layer_pos.top - overlap_bottom

			overlap_right = layer_pos.left + layer_pos.width - vp.right
			if overlap_right > 0
				layer_pos.left = layer_pos.left - overlap_right

			vp.overlap_height = 0
			vp.overlap_width = 0

			if @__pointer or @_show_at_position
				# we allow an overlap push for certain placements,
				# that means, if we cut the layer we allow it to
				# be positioned outside the viewport (but inside the window)
				overlap_height = dim_layer.borderBoxHeight - layer_pos.height

				if overlap_height > 0
					switch vp.overlap_align
						when "bottom"
							vp.overlap_height = Math.min(layer_pos.top - vp.window_top, overlap_height)
							layer_pos.top = layer_pos.top - vp.overlap_height
							layer_pos.height = layer_pos.height + vp.overlap_height
						when "top"
							vp.overlap_height = Math.min(vp.window_bottom - layer_pos.top - layer_pos.height, overlap_height)
							layer_pos.height = layer_pos.height + vp.overlap_height


				overlap_width = dim_layer.borderBoxWidth - layer_pos.width

				if overlap_width > 0
					switch vp.overlap_align
						when "right"
							vp.overlap_width = Math.min(layer_pos.left - vp.window_left, overlap_width)
							layer_pos.left = layer_pos.left - vp.overlap_width
							layer_pos.width = layer_pos.width + vp.overlap_width
						when "left"
							vp.overlap_height = Math.min(vp.window_right - layer_pos.right, overlap_width)
							layer_pos.width = layer_pos.width + vp.overlap_width


			if @__pointer

				layer_pos_right = vp.layer_pos.left + vp.layer_pos.width
				layer_pos_bottom = vp.layer_pos.top + vp.layer_pos.height

				pointer_pos_right = vp.pointer_pos.left + vp.pointer_pos.width
				pointer_pos_bottom = vp.pointer_pos.top + vp.pointer_pos.height

				# push layer further, so the pointer has enough margin to the
				# edge of the layer
				switch vp.pointer_pos.direction
					when "n", "s"
						marginLeft = vp.pointer_pos.left - vp.layer_pos.left
						pushNeeded = marginLeft - vp.dim_pointer.marginLeft

						if pushNeeded < 0
							spaceAvailable = vp.layer_pos.left - vp.window_left
							vp.push_left = Math.min(spaceAvailable, -pushNeeded)
							vp.layer_pos.left = vp.layer_pos.left - vp.push_left

						marginRight = layer_pos_right - pointer_pos_right
						pushNeeded = marginRight - vp.dim_pointer.marginRight

						if pushNeeded < 0
							spaceAvailable = vp.window_right - layer_pos_right
							vp.push_right = Math.min(spaceAvailable, -pushNeeded)
							vp.layer_pos.left = vp.layer_pos.left + vp.push_right

					when "e", "w"
						marginTop = vp.pointer_pos.top - vp.layer_pos.top
						pushNeeded = marginTop - vp.dim_pointer.marginTop

						if pushNeeded < 0
							spaceAvailable = vp.layer_pos.top - vp.window_top
							vp.push_top = Math.min(spaceAvailable, -pushNeeded)
							vp.layer_pos.top = vp.layer_pos.top - vp.push_top

						marginBottom = layer_pos_bottom - pointer_pos_bottom
						pushNeeded = marginBottom - vp.dim_pointer.marginBottom

						if pushNeeded < 0
							spaceAvailable = vp.window_bottom - layer_pos_bottom
							vp.push_bottom = Math.min(spaceAvailable, -pushNeeded)
							vp.layer_pos.top = vp.layer_pos.top + vp.push_bottom


			if @_onPosition
				# link dimensions, so the callback can
				# use it

				@_onPosition?(@, vp)
				# overflow cutting

			# the higher this number, the better
			vp.layer_pos.estate = vp.layer_pos.width * vp.layer_pos.height
			vp.layer_pos.aspect_ratio = vp.layer_pos.width / vp.layer_pos.height
			vp.dim_layer.aspect_ratio = vp.dim_layer.borderBoxWidth / vp.dim_layer.borderBoxHeight

			wanted_rank = (allowed_placements.length - idxInArray(placement, allowed_placements))
			if wanted_placement == placement
				wanted_rank = allowed_placements.length + 1

			vp.ranking =
				wanted_rank*10 +
				1 - Math.abs(vp.layer_pos.aspect_ratio - vp.dim_layer.aspect_ratio) +
				vp.layer_pos.estate

		# pick best placement
		available_placements = []
		for placement, vp of vp_pl
			available_placements.push(placement)

		assert(available_placements.length > 0, "Layer.position", "No available placements found.", vp_pl: vp_pl)

		# console.debug "sorting placements BEFORE", ((pl+"["+vp_pl[pl].ranking+"]") for pl in available_placements).join(", ")
		# sort available placements
		available_placements.sort (pl1, pl2) ->
			value = (pl) ->
				vp_pl[pl].ranking

			compareIndex(value(pl1), value(pl2))

		available_placements.reverse()
		# console.debug "sorting placements AFTER", available_placements.join(", ")

		placement = available_placements[0]

		if ev?.hasModifierKey()
			console.debug "layer", dim_layer
			console.debug "element", dim_element
			console.debug "pointer", dim_pointer
			console.debug "window", dim_window

			console.debug "placements", placement, vp_pl

			show_dbg_div = (placement) =>

				@__removeDebugDivs()

				_vp = vp_pl[placement]

				console.info("Layer: Placement", placement, _vp)

				@__dbg_div1 = CUI.DOM.element("DIV")
				@__dbg_div2 = CUI.DOM.element("DIV")
				@__dbg_div3 = CUI.DOM.element("DIV")

				style1 =
					position: "absolute"
					zIndex: 2
					border: "2px solid #ff0032"
					backgroundColor: "rgba(255, 0, 0, 0.4)"
					top: _vp.top
					left: _vp.left
					width: _vp.width
					height: _vp.height

				DOM.setStyle(@__dbg_div1, style1)

				style2 =
					position: "absolute"
					zIndex: 2
					border: "2px solid #00ff32"
					backgroundColor: "rgba(0, 255, 0, 0.4)"
					top: _vp.layer_pos.top
					left: _vp.layer_pos.left
					width: _vp.layer_pos.width
					height: _vp.layer_pos.height
					alignItems: "center"
					justifyContent: "center"
					fontSize: 40
					color: "rgb(0,255,50)"

				span = CUI.DOM.element("SPAN")
				span.textContent = placement

				@__dbg_div2.appendChild(span)
				DOM.setStyle(@__dbg_div2, style2)

				style3 =
					position: "absolute"
					zIndex: 2
					border: "2px solid #0032ff"
					backgroundColor: "rgba(0, 0, 255, 0.4)"
					top: _vp.pointer_pos.top
					left: _vp.pointer_pos.left
					width: _vp.pointer_pos.width
					height: _vp.pointer_pos.height

				DOM.setStyle(@__dbg_div3, style3)

				@__layer_root.DOM.appendChild(@__dbg_div1)
				@__layer_root.DOM.appendChild(@__dbg_div2)

				if @__pointer
					@__layer_root.DOM.appendChild(@__dbg_div3)

			dbg_pl = 0

			listener = Events.listen
				node: document
				type: "keyup"
				call: (ev, info) =>
					if ev.keyCode() != 32
						return

					while (true)
						dbg_pl = dbg_pl + 1
						if dbg_pl == CUI.Layer.knownPlacements.length
							@__removeDebugDivs()
							listener.destroy()
							return

						_placement = CUI.Layer.knownPlacements[dbg_pl]

						if vp_pl[_placement]
							show_dbg_div(_placement)
							return

						console.warn("Placement", _placement, "is unavailable.")
					return


		vp = vp_pl[placement]

		# console.debug "Layer.position: Placement:", placement, "Wanted:", wanted_placement, "Allowed:", allowed_placements, "Viewports:", vp_pl, @

		# console.info "PLACEMENT --- ", placement, "---"
		# console.debug "Layer POS", vp.layer_pos, "align:", vp.align_horizontal, "/", vp.align_vertical, "overlap:", vp.overlap_align, vp.push_left, vp.push_right
		# console.debug "Pointer POS", vp.pointer_pos, "align:", vp.pointer_align_horizontal, "/", vp.pointer_align_vertical

		if vp.layer_pos.width < 10 or vp.layer_pos.height < 10
			; # console.warn("Layer: DIM is very small, layer might not be visible. Placement:", placement, "Dimensions:", vp, "Layer:", @__layer.DOM)

		if @_element and @_use_element_width_as_min_width
			minWidth = dim_element.borderBoxWidth
		else
			minWidth = undefined

		CUI.DOM.setAttribute(@__layer_root.DOM, "cui-placement", placement)
		CUI.DOM.setAttribute(@__layer_root.DOM, "cui-fill-space", @_fill_space)

		if CUI.__ng__ and placement == "c" and not @__backdrop_crop
			# in "ng" we position this by pure CSS
			return

		# set layer
		CUI.DOM.setStyle @__layer.DOM,
			top: vp.layer_pos.top
			left: vp.layer_pos.left
			width: vp.layer_pos.width
			height: vp.layer_pos.height
			margin: 0
			minWidth: minWidth
			# maxWidth: vp.width + vp.overlap_width
			# maxHeight: vp.height + vp.overlap_height

		if @__pointer
			# set pointer
			CUI.DOM.setStyle @__pointer,
				top: vp.pointer_pos.top
				left: vp.pointer_pos.left
				margin: 0

			CUI.DOM.addClass(@__pointer, get_pointer_class(vp.pointer_pos.direction))

		if @__backdrop_crop
			DOM.setStyle @__backdrop_crop,
				top: vp.layer_pos.top
				left: vp.layer_pos.left
				width: vp.layer_pos.width
				height: vp.layer_pos.height

			DOM.setStyle @__backdrop_crop.firstChild,
				width: dim_window.width
				height: dim_window.height
				top: -vp.layer_pos.top
				left: -vp.layer_pos.left

		# We could re-read the layer width & height here to actually
		# set it in Style. By doing that we could have support for transitions
		# when Layer content size changes.
		return

	__removeDebugDivs: ->
		@__dbg_div1?.remove()
		@__dbg_div2?.remove()
		@__dbg_div3?.remove()
		@__dbg_div1 = null
		@__dbg_div2 = null
		@__dbg_div3 = null


	clearTimeout: ->
		if @__timeout
			CUI.clearTimeout(@__timeout)
		@__timeout = null
		@

	showTimeout: (ms=@_show_ms, ev) ->
		# console.error "Layer.showTimeout ", @getUniqueId()

		@clearTimeout()
		dfr = new CUI.Deferred()
		@__timeout = CUI.setTimeout
			ms: ms
			track: false
			onReset: =>
				dfr.reject()
			onDone: =>
				dfr.resolve()
			call: =>
				if @__element and not CUI.DOM.isInDOM(@__element)
					@destroy()
					return
				@show(null, ev)
		dfr.promise()

	hideTimeout: (ms=@_hide_ms, ev) ->
		@clearTimeout()
		dfr = new CUI.Deferred()

		@__timeout = CUI.setTimeout
			ms: ms
			track: false
			onReset: =>
				dfr.reject()
			onDone: =>
				dfr.resolve()
			call: =>
				@hide(ev)

		dfr.promise()

	hide: (ev) ->
		#remove our fixed size
		@clearTimeout()
		if @isDestroyed()
			return

		if not @isShown()
			return @

		@__removeDebugDivs()

		if @__element
			if @__check_for_element
				CUI.clearInterval(@__check_for_element)
			@__element.removeClass("cui-layer-active")

		@__layer_root.DOM.detach()

		CUI.DOM.setAttributeMap @__layer_root.DOM[0],
			"cui-layer-stack-number": null
			"cui-layer-stack-count": null

		@__updateLayerStackCounter()

		@__shown = false

		if @_handle_focus
			@focusOnHide(ev)

		# if @__orig_element
		# 	@__element = @__orig_element
		# 	delete(@__orig_element)

		Events.ignore(instance: @)

		@__clickThruListener?.destroy()
		@__clickThruListener = null

		@_onHide?(@, ev)
		@

	__updateLayerStackCounter: ->
		# count all active layers and set a counter to the body
		# and to each, so a layer knows its stack number

		layer_elements = CUI.DOM.matchSelector(document.documentElement, "body > .cui-tmpl-layer-root")
		total = layer_elements.length

		for el, idx in layer_elements
			CUI.DOM.setAttributeMap el,
				"cui-layer-stack-number": idx
				"cui-layer-stack-count": total

		@

	# use element to temporarily overwrite element used
	# for positioning
	show: (ev) ->
		# console.error "show ", @getUniqueId()

		# "element" as first parameter is gone, i don't think we need this

		assert(not @isDestroyed(), "#{@__cls}.show", "Unable to show, Layer ##{@getUniqueId()} is already destroyed", layer: @)

		if Tooltip.current and @ not instanceof Tooltip
			Tooltip.current.hide()

		@clearTimeout()
		if @isShown()
			@position()
			return @

		# if element
		# 	@__orig_element = @__element
		# 	@__setElement(element)

		# @__layer.DOM.css
		# 	top: 0
		# 	left: 0

		document.body.appendChild(@__layer_root.DOM)

		if @__element
			@__element.addClass("cui-layer-active")

			for scroll_parent in CUI.DOM.parentsScrollable(@__element)
				Events.listen
					type: "scroll"
					instance: @
					node: scroll_parent
					call: =>
						@position()

			if @_check_for_element
				@__check_for_element = CUI.setInterval =>
					if not CUI.DOM.isInDOM(@__element)
						@destroy()
				,
					200

		@__updateLayerStackCounter()

		Events.listen
			type: "content-resize"
			instance: @
			node: @__layer
			call: (ev) =>
				# console.error "Layer caught event:", ev.getType()
				@position()

		Events.listen
			type: "viewport-resize"
			instance: @
			node: @__layer
			call: (ev) =>
				if @__element and not CUI.DOM.isInDOM(@__element)
					# ignore the event
					return

				# console.info("Layer caught event:", ev.getType)
				@position()
				return


		# if @__addClickThruListenerOnShow
		# 	@__clickThruListener = @__addClickThruListener()
		# else
		# 	@__clickThruListener = null

		@_onBeforeShow?(@, ev)
		@__shown = true

		@position(ev)
		if @_handle_focus
			@focusOnShow(ev)

		@_onShow?(@, ev)
		@

	isKeyboardCancellable: (ev) ->
		if @__bd_policy in ["click", "click-thru"] # and not @__backdropClickDisabled
			true
		else
			false

	doCancel: (ev) ->
		@hide(ev)

	focusOnShow: (ev) ->
		if ev == CUI.KeyboardEvent
			@__focused_on_show = true
		else if @__element and DOM.matchSelector(document.documentElement, ":focus").length > 0
			; # @__focused_on_show = true
		else
			@__focused_on_show = false

		if @__focused_on_show
			@DOM[0].focus()
		@

	focusOnHide: (ev) ->
		if not @__element
			return @

		if ev == CUI.KeyboardEvent or @__focused_on_show
			DOM.findElement(@__element[0], "[tabindex]")?.focus()
		@

	getElement: ->
		@__element

	isShown: ->
		@__shown

	destroy: ->
		# CUI.error "Layer.destroy",@, @isDestroyed()
		@clearTimeout()
		if @__shown
			@hide()

		super()

		@__layer?.destroy()
		@__layer_root?.destroy()

		@__layer = null
		@__layer_root = null

		@__pointer?.remove()
		@__pointer = null

		@__backdrop?.destroy()
		@__backdrop = null


CUI.ready ->

	Events.listen
		type: ["mousedown", "touchend"]
		capture: true
		# install not do high, do Drag & Drop can be on top
		node: document.body
		call: (ev, info) ->

			layer_elements = DOM.findElements(document.body, "body > .cui-tmpl-layer-root, body > .cui-pane-fill-screen-is-on")
			target = ev.getTarget()

			while layer_element = layer_elements.pop()

				if not CUI.DOM.hasClass(layer_element, "cui-layer-backdrop-policy-click-thru")
					return

				if CUI.DOM.closest(target, layer_element)
					return

				layer = DOM.data(CUI.DOM.children(layer_element, ".cui-layer")[0], "element")

				ev.cui_layer_closed = true

				layer.hide(ev)

			return

	Events.listen
		type: ["keyup"]
		capture: true
		# install not do high, do Drag & Drop can be on top
		node: document.body
		call: (ev) ->
			if ev.keyCode() != 27
				return

			layer_elements = DOM.findElements(document.body, "body > .cui-tmpl-layer-root > .cui-layer")
			layer_element = layer_elements[layer_elements.length-1]

			element = CUI.DOM.closest(ev.getTarget(), "[tabindex],input,textarea")

			if (element and element != layer_element) or not layer_element
				# ignore this
				return

			layer = DOM.data(layer_element, "element")

			ev.stopImmediatePropagation()
			ev.preventDefault()

			if layer.isKeyboardCancellable(ev)
				layer.doCancel(ev)
				return false
			return