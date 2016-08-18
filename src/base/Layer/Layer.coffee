# a layer is a top level positioned div
# which can be used to display Menu
# Popver, Modal, Autocompletion and
# other dialogs


class CUI.Layer extends CUI.DOM

	constructor: (@opts={}) ->
		super(@opts)

		@__layer = @getTemplate()

		@__placement = null

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
			class: "cui-layer-root-"+("cui-"+toDash(@__cls)+" "+@_class).trim().split(/\s+/).join(" cui-layer-root-")
			name: "layer-root"

		@__backdropClickDisabled = false

		if @_backdrop or @_modal

			if @_modal
				@__bd_policy = "modal"
			else
				@__bd_policy = @_backdrop.policy or "click-thru"

			@__backdrop = new Template
				class: "cui-layer-backdrop"
				name: "layer-backdrop"

			@__backdrop.addClass("cui-layer-backdrop-policy-"+@__bd_policy)

			if @_backdrop.background_effect
				@__body_effect_class = "cui-layer-effect-" + @_backdrop.background_effect
				$(document.body).addClass(@__body_effect_class)

			if @_backdrop.content
				@setBackdropContent(@_backdrop.content)
			else if @_backdrop.blur
				# clone body
				body_clone = document.body.firstChild.cloneNode(true)

				if @__bd_policy == "click-thru"
					# backdrop needs to be cropped
					@__backdrop_crop = @__backdrop.DOM[0]
					@setBackdropContent(body_clone)
				else
					@__backdrop_crop = $div("cui-layer-backdrop-body-clone")[0]
					@__backdrop_crop.appendChild(body_clone)
					@setBackdropContent(@__backdrop_crop)

				console.error "crop this:", @__backdrop_crop

				@__layer_root.addClass("cui-layer-root-backdrop-blur")

			@__backdrop.DOM.appendTo(@__layer_root.DOM)

			# @__backdrop.DOM.attr("role", @_role)

			switch @__bd_policy
				when "click-thru"
					Events.listen
						type: "mousedown"
						node: @__backdrop
						call: (ev) =>
							if ev.ctrlKey() and ev.getButton() == 2
								return

							if @__backdropClickDisabled
								# this is used in Popover when all buttons are disabled
								# we need to eat this
								return

							@hide(ev)

							CUI.setTimeout
								ms: 0
								call: =>
									Events.trigger
										node: document.elementFromPoint(ev.clientX(), ev.clientY())
										type: "mousedown"
										button: ev.getButton()
										pageX: ev.pageX()
										pageY: ev.pageY()

							ev.stopPropagation()
							return


				when "click"
					Events.listen
						type: ["click", "contextmenu"]
						node: @__backdrop
						call: (ev) =>
							if ev.ctrlKey() and ev.getButton() == 2
								return

							if @__backdropClickDisabled
								return

							@hide(ev)
							ev.stopPropagation()

				when "modal"
					@__backdrop.addClass("layer-backdrop-modal")
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

		@__layer.DOM.appendTo( @__layer_root.DOM )

		if @_handle_focus
			DOM.setAttribute(@__layer.DOM[0], "tabindex", "0")

		if @_element
			if @_element.DOM
				@__element = @_element.DOM
			else
				@__element = @_element
			assert(@__element.closest(".ez-tmpl").length == 0, "new #{@__cls}", "opts.element is inside a Template.", element: @__element)

		if @_set_element_width
			assert(@__element, "new Layer", "opts.set_element_width requires opts.element to be set.", opts: @opts)

		if @_pointer
			if @_class
				cls = "layer-pointer-"+@_class.split(/\s+/).join(" layer-pointer-")

			@__pointer = new Template
				class: cls
				name: "layer-pointer"
			.DOM

			#append pointer and make sure pointer is rendered beneath layer.
			@__pointer.insertBefore(@__layer.DOM)

			# @__pointer.attr("role", @_pointer)

			@__pointer.addClass("layer-pointer") # layer-pointer-#{@_role}")

		if @_fill_space
			assert(@_placement, "new #{@__cls}", "opts.fill_space requires opts.placement to be set.", opts: @opts)

		@__shown = false

		@__auto_size_transition_active = false
		@__trigger_auto_size_again_at_transitionend = false

		#this is defined in show. if its defined the layer size should never change anymore
		# in fill_screen mode this dimensions are ignored
		@__resetFixedLayerDim()

	disableBackdropClick: ->
		@__backdropClickDisabled = true
		@

	enableBackdropClick: ->
		@__backdropClickDisabled = false
		@

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
					background_effect: null
					content: null

				check: (v) ->
					if $.isPlainObject(v) or v == false
						return true

			# if added, a bounce class will be added and after a css transition
			# removed to the layer, if the user clicks on a modal backdrop
			# the bounce class defaults to "cui-layer-bounce"
			add_bounce_class:
				deprecated: "use backdrop.add_bounce_class instead"


			# set to true, if a mousedown on the backdrop
			# does not destroy the layer
			# modal implies backdrop
			modal:
				deprecated: true
				check: Boolean
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
					if not $.isArray(v)
						return false
					for a in v
						if CUI.Layer.knownPlacements.indexOf(a) == -1
							return false
					return true

			# element to position the layer to
			element:
				check: (v) ->
					isElement(v) or isElement(v?.DOM)

			set_element_width:
				default: false
				check: Boolean

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
				check: ["auto", "both", "horizontal", "vertical"]

			# if set, the Layer, when shown checks if the "element"
			# is still in the DOM tree
			check_for_element:
				default: false
				check: Boolean

			#
			# if set to true the Layer listens to content-resize events
			# and adjusts its size
			auto_size:
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

	# known placements
	getPlacements: ->
		if @_placements
			@_placements
		else
			CUI.Layer.knownPlacements

	setVisible: (on_off=true) ->
		if on_off
			DOM.setStyleOne(@__layer_root.DOM[0], "visibility", "")
		else
			DOM.setStyleOne(@__layer_root.DOM[0], "visibility", "hidden")

	@knownPlacements: ["s", "e", "w", "ws", "wn", "n", "se", "ne", "es", "en", "nw", "sw", "c"]

	# returns a list of all possible placements starting with @__placement and ending with "c"
	__getPlacements: ->
		pls = @getPlacements()
		all_pls = Layer::getPlacements.call(@)

		for p in pls
			assert(all_pls.indexOf(p) > -1, "#{@__cls}", "Unsupported placement \"#{p}\"")

		if @_placement
			idx = pls.indexOf(@_placement)
			assert(idx > -1, "#{@__cls}.getPlacements", "placement \"#{@_placement}\" is not supported. Possible placements are [\"#{pls.join('\", \"')}\"].", opts: @opts)
			_pls = pls.slice(idx)
			_pls.push.apply(_pls, pls.slice(0, idx))
		else
			idx = 0
			_pls = pls.slice(0)

		_pls

	# returns Positioner
	getViewport: ->
		parent = @__layer.DOM.offsetParent()

		#if overflow is visible then get use our document as the viewport  (needed by submenus)
		if parent.css("overflow-x") == "visible" or parent.css("overflow-y") == "visible"
				# @__debug.push("getViewport: using document viewport")
				return new Positioner
					top: 0
					left: 0
					width: CUI.getViewport().width
					height: CUI.getViewport().height
		else
			rect = parent.rect()
			return new Positioner(
				top: rect.top
				left: rect.left
				width: parent[0].clientWidth
				height: parent[0].clientHeight
			)


	getPositioner: ->
		assert(@__element, "#{@__cls}.getPositioner", "opts.element needs to be set", opts: @opts)
		# CUI.debug "getPositioner", @, "destroyed:", @isDestroyed(), @__element, "dom:", $elementIsInDOM(@__element)
		if @__element
			new Positioner(@__element)

	__getMaxLayerWidth: ->
		margin_x = @__layer_margin.left + @__layer_margin.right
		@__viewport.width - margin_x

	__getMaxLayerHeight: ->
		margin_y = @__layer_margin.bottom + @__layer_margin.top
		@__viewport.height - margin_y

	__setMaxDimensionsOnLayer: ->

		new_max_dimension =
			width: @__getMaxLayerWidth()
			height: @__getMaxLayerHeight()
		@__layer.DOM.css
			"max-width": new_max_dimension.width
			"max-height": new_max_dimension.height

		return new_max_dimension


	__setLayerSizeFromFixedDimensions: ->

		# CUI.debug "setLayerSizeFromFixedDimensions",@__fixed_layer_dim

		@__layer.DOM.width( @__fixed_layer_dim._css_width)
		@__layer.DOM.height( @__fixed_layer_dim._css_height)

		new_max_dimension = @__setMaxDimensionsOnLayer()

		@


	__findMostSpacePlacement: ->
		most_space =
			placement: null

			area: 0

			width: 0
			height: 0

		for p, idx in @__getPlacements()
			#calculate visible area of the layer in the current placement

			space = @__getAvailableSpace(p)

			if @_fill_space in ["both", "vertical"]
				max_height = space.height
			else
				max_height = Math.min(@__layer_dim.height, space.height)

			if @_fill_space in ["both", "horizontal"]
				max_width = space.width
			else
				max_width = Math.min(@__layer_dim.width, space.width)

			area = max_height * max_width

			if area > most_space.area
				most_space.area = area
				most_space.placement = p
				most_space.width = space.width
				most_space.height = space.height

		most_space

	__getFirstPlacementThatFits: ->
		fits = null

		#layer with width 200.4 was not fitting into 200 , fixed that with math.floor
		layer_width  = Math.min(@__getMaxLayerWidth(), @__layer_dim.width)
		layer_height = Math.min(@__getMaxLayerHeight(),@__layer_dim.height)
		layer_width  = Math.floor(layer_width)
		layer_height = Math.floor(layer_height)

		for p, idx in @__getPlacements()
			space = @__getAvailableSpace(p)
			if layer_width <= space.width and layer_height <= space.height
				fits  = p
				break

		fits

	#called inside fillspace when layer is shrunk , menu overwrites it
	# __compensateScrollbars: ( new_dimension_in_out ) ->
	# 	@

	__fillSpace: (dir, placement, shrink_only = false) ->

		if dir == "auto"
			# lets see if we can change the width or height or need
			# to change both

			#remove content and check if the layer still has a size , manually set dimensions are locked for us
			#TODO we should be able to get this info without disabling the children!?
			for c in @__layer.DOM.children()
				$(c).css("display", "none")

			w = @__layer.DOM.width()
			h = @__layer.DOM.height()

			for c in @__layer.DOM.children()
				$(c).css("display", "")

			if w and h
				dir = null
			else if not w and not h # both are set or not set
				dir = "both"
			else if w
				dir = "vertical"
			else
				dir = "horizontal"

		if dir
			space = @__getAvailableSpace(placement)

			new_dimension =
				height: space.height - @__layer.DOM.cssEdgeSpace("vertical", true)
				width: space.width - @__layer.DOM.cssEdgeSpace("horizontal", true)

			#we only limit shrinking when no fillspace is set
			if not (@_fill_space in ["both", "vertical"]) and shrink_only
				new_dimension.height = Math.min(@__layer_dim._css_height,new_dimension.height)
			if not (@_fill_space in ["both", "horizontal"]) and shrink_only
				new_dimension.width =  Math.min(@__layer_dim._css_width ,new_dimension.width)

			# @__compensateScrollbars( new_dimension )

			if dir in ["both", "vertical"]
				# CUI.debug(@__layer.DOM.cssEdgeSpace("vertical", true))
				@__layer.DOM.height(new_dimension.height)

			if dir in ["both", "horizontal"]
				@__layer.DOM.width(new_dimension.width)

			# @__debug.push("fillSpace: dir:#{dir}, placement:#{placement}, space: "+space.width+" x "+space.height);
		@


	resetLayer: ->
		# @__debug.push("resetLayer")

		# if @__appendToElement
		# 	previous_element = @__layer_root.DOM.prev()
		# 	@__layer_root.DOM.detach()

		@__layer.DOM.css
			height: ""
			width: ""
			"max-width": ""
			"max-height": ""

		# if @__appendToElement
		# 	if previous_element.length > 0
		# 		previous_element.after(@__layer_root.DOM)
		# 	else
		# 		@__layer_root.DOM.appendTo(@__appendToElement)
		@


	__getMargin: (el) ->
		margin =
			left: el.cssFloat("marginLeft")
			top: el.cssFloat("marginTop")
			right: el.cssFloat("marginRight")
			bottom: el.cssFloat("marginBottom")
		margin


	# let the layer find a new size based on its content
	# @param immediate , skips animation
	autoSize: ( immediate=false ) ->
		if not @isShown()
			return

		focused = @__layer.DOM.find(":focus")

		#need to take care of multiple autosize calls
		if @__auto_size_transition_active and not immediate
			@__trigger_auto_size_again_at_transitionend = true
			return

		@__trigger_auto_size_again_at_transitionend = false
		@__auto_size_transition_active = true

		@__layer.DOM.removeClass("cui-layer-autosize-transition")

		layer_start_transform =
			left: @__layer.DOM.cssFloat("left")
			top: @__layer.DOM.cssFloat("top")
			width: @__layer.DOM.width()
			height: @__layer.DOM.height()

		#calculate new layer transform
		immediate = immediate or isUndef(@__fixed_layer_dim)
		@__resetFixedLayerDim()

		@position()

		if not immediate
			#start transition

			layer_offset =
				left: @__layer.DOM.cssFloat("left")
				top: @__layer.DOM.cssFloat("top")

			#set animation start transform
			@__layer.DOM.css
				top: layer_start_transform.top
				left: layer_start_transform.left
				width: layer_start_transform.width
				height: layer_start_transform.height

			#trigger layout to make sure the browser is using our animation start values!
			@__layer.DOM.width()

			# set autosize transition when window has moved

			# find biggest movement in our transition
			max_movement = 0
			calc_max_movement = (start,end) =>
				max_movement = Math.max( max_movement, Math.abs(start-end) )
			calc_max_movement( layer_start_transform.left, layer_offset.left )
			calc_max_movement( layer_start_transform.top, layer_offset.top )
			calc_max_movement( layer_start_transform.width, @__fixed_layer_dim._css_width )
			calc_max_movement( layer_start_transform.height, @__fixed_layer_dim._css_height )

			animation_threshold = 3
			if max_movement > animation_threshold
				#enable transition
				@__layer.DOM.addClass("cui-layer-autosize-transition")

			# make sure we clean up our animation class, otherwise it overwrites animation speeds

			focused[0]?.focus()

			Events.wait
				type: "transitionend"
				node: @__layer
			.always =>
				if @isDestroyed()
					return

				@__auto_size_transition_active = false

				if @__layer.DOM.hasClass("cui-layer-autosize-transition")
					@__layer.DOM.removeClass("cui-layer-autosize-transition")

					# make sure viewport resize is called at the end without 'cui-layer-autosize-transition' being set,
					# 'cui-layer-autosize-transition' is setting a oversize to avoid irritating content relayouts during the transition
					Events.trigger
						type: "viewport-resize"
						exclude_self: true
						node: @__layer

				if @__trigger_auto_size_again_at_transitionend
					@autoSize()

			#set animation end transform
			@__layer.DOM.css
				left: layer_offset.left
				top: layer_offset.top
			@__setLayerSizeFromFixedDimensions()
		else
			@__auto_size_transition_active = false




	#updates and returns @__layer_dim
	__getLayerDim: ->
		@__layer.addClass("cui-layer-measure")
		rect = @__layer.DOM.rect()
		@__minimumElementWidthUsed = false

		# let's see if we need to put a minium size
		if @_set_element_width and @__element
			dim = DOM.getDimensions(@__element[0])
			if dim.borderBoxWidth >= rect.width
				@__minimumElementWidthUsed = true
				width = dim.borderBoxWidth
			else
				width = rect.width
			# console.error "Layer.__getLayoutDim: Set min-width on layer:", rect.width, dim.borderBoxWidth
		else
			width = rect.width

		@__layer.removeClass("cui-layer-measure")

		if isUndef(@__layer_dim)
			@__layer_dim = {}

		# if our axis wants to be filled then we don't use its fixed size

		if isUndef(@__fixed_layer_dim) or @_fill_space in ["both","horizontal"]
			@__layer_dim.width = width + @__layer_margin.left + @__layer_margin.right
			@__layer_dim._css_width = rect.width - @__layer.DOM.cssEdgeSpace("horizontal")
		else
			@__layer_dim.width = @__fixed_layer_dim.width
			@__layer_dim._css_width = @__fixed_layer_dim._css_width

		if isUndef(@__fixed_layer_dim) or @_fill_space in ["both","vertical"]
			@__layer_dim.height = rect.height + @__layer_margin.top + @__layer_margin.bottom
			@__layer_dim._css_height = rect.height - @__layer.DOM.cssEdgeSpace("vertical")
		else
			@__layer_dim.height = @__fixed_layer_dim.height
			@__layer_dim._css_height = @__fixed_layer_dim._css_height

		# @__debug.push("getLayerDim: "+@__layer_dim.width+" x "+@__layer_dim.height)
		# @__debug.push("getLayerDim [rect]: "+rect.width+" x "+rect.height)
		# @__debug.push("getLayerDim [inner] : "+@__layer_dim._css_width+" x "+@__layer_dim._css_height)
		# @__debug.push("width:"+@__layer.DOM.width())
		# @__debug.push("max-width:"+@__layer.DOM.css("max-width"))
		@__layer_dim

	__resetFixedLayerDim: ->
		@__fixed_layer_dim = undefined


	__isPreviousPlacementBetter: ( previous_placement, current_placement ) ->
		assert( previous_placement and isString(previous_placement) )
		assert( current_placement and isString(current_placement) )

		current_space = @__getAvailableSpace(current_placement)
		previous_space = @__getAvailableSpace(previous_placement)

		return (
				(@__layer_dim.width  <= previous_space.width  or previous_space.width  >= @__viewport.width  or previous_space.width  >= current_space.width-1 ) and
			   	(@__layer_dim.height <= previous_space.height or previous_space.height >= @__viewport.height or previous_space.height >= current_space.height-1 )
		)


	position: ->
		if not @isShown()
			return

		# @__debug = []

		# Window Viewport
		@__window = CUI.getViewport()
		# @__debug.push("window: "+@__window.width+" x "+@__window.height)

		# Viewport of Layer
		viewport = @getViewport()
		assert(viewport instanceof Positioner, "#{@__cls}.getViewport", "Returned value is not instance of Positioner", return: viewport)
		@__viewport = viewport.getPos()

		# @__debug.push("viewport: "+@__viewport.width+" x "+@__viewport.height)

		#if @__fixed_layer_dim
		#	CUI.debug "have fixed layer dim: ",@__fixed_layer_dim

		# Rectangle of Positioner
		rect = @getPositioner()
		assert(rect instanceof Positioner, "#{@__cls}.getPositioner()", "Returned value is not instance of Positioner", return: rect)
		@__rect = rect.getPos()
		# @__debug.push("positioner: left:"+@__rect.left+" top:"+@__rect.top+" width:"+@__rect.width+" height:"+@__rect.height+" right:"+@__rect.right+" bottom:"+@__rect.bottom)

		@resetLayer()
		@__layer_margin = @__getMargin(@__layer.DOM)

		# TODO fill_space can be undefined, behaviour is different from fill_space==null, document this behaviour
		# TODO undefined and null should be the same, use null as default in readopts
		if isUndef(@_fill_space)
			@_fill_space = null
		fill_space = @_fill_space

		#get real need of dimensions, needed to have an idea for the minimum size
		@__getLayerDim()
		@__setMaxDimensionsOnLayer() #make sure we limit its size by the viewport

		previous_placement = @__placement

		if fill_space == "both"
			@__placement = "c"
		else
			@__placement = @__getFirstPlacementThatFits()

		# @__debug.push("best placement: "+@__placement)
		if @__placement
			if fill_space != null
				@__updatePointerOrientation()
				#this is filling space even when there is no, manipulates dom and can set negative dimensions, thats why we call it after findBestPlacement
				@__fillSpace( fill_space, @__placement )
			else
				#check if we can stay on the old placement
				if previous_placement
					if @__isPreviousPlacementBetter(previous_placement,@__placement)
						@__placement = previous_placement
		else
			#nothing fits, try again
			most_space = @__findMostSpacePlacement()

			#check if our previous placement was better, __findMostSpacePlacement is not necessarily returning the best option
			if previous_placement and @__isPreviousPlacementBetter(previous_placement, most_space.placement)
				most_space = @__getAvailableSpace(previous_placement)
				most_space.placement = previous_placement

			@__placement = most_space.placement

			@__updatePointerOrientation()

			#find the axis that has not enough space, only interesting if its not bigger than the viewport
			if fill_space == null
				if @__layer_dim.width > most_space.width and most_space.width < @__viewport.width
					fill_space = "horizontal"
				if @__layer_dim.height > most_space.height and most_space.height < @__viewport.height
					if fill_space == "horizontal"
						fill_space = "auto"
					else
						fill_space = "vertical"

				if fill_space != null
					@__fillSpace( fill_space, @__placement, true )

#			#found no fitting
#			shrink_layer_to_fit = true
#
#			#we dont try 'auto' if we have a 'c' placement , in most cases there is not enough space.
#			if fill_space == null and @__placement != "c"
#				# when fill_space is undefined we shrink the layer as much as we want
#				fill_space = "auto"
#				@__fillSpace( fill_space, @__placement )
#				#did it fit?
#				@__getLayerDim()
#				shrink_layer_to_fit =
#						@__layer_dim.width > @__viewport.width or
#						@__layer_dim.height > @__viewport.height
#
#			if shrink_layer_to_fit
#				#should work always
#				assert(@__placement != "","we cant have 'c' as a fallback anymore.")
#				@__updatePointerOrientation()
#				@__fillSpace( "both", @__placement, true )


		#update @__layer_dim after possible change of @__layer.DOM with fillspace
		@__getLayerDim()



		offset = {}
		pointer_off = {}

		#align everything at @__rect

		# @__debug.push("Align Layer and Pointer to Rect")

		pointer_off = {}

		first_placement = @__placement[0]
		second_placement = null
		if @__placement.length == 2
			second_placement = @__placement[1]
			assert( Positioner.getAxis(first_placement) != Positioner.getAxis(second_placement) )

		layer_rect = @__layer_dim
		layer_rect.left = 0
		layer_rect.top = 0
		layer_rect = new Positioner(layer_rect)
		new_layer_rect = null

		if first_placement == "c"
			#center on both axis
			new_layer_rect = layer_rect.slideAlignToCenter(@__rect, "n")
			new_layer_rect = new_layer_rect.slideAlignToCenter(@__rect, "w")
			pointer_off = null #hide pointer
		else
			#convert to Positioners
			layer_rect = @__layer_dim
			layer_rect.left = 0
			layer_rect.top = 0
			layer_rect = new Positioner(layer_rect)
			@__pointer_dim.left = 0
			@__pointer_dim.top = 0
			pointer_dim = new Positioner(@__pointer_dim)

			first_placement = Positioner.getIndex( first_placement )
			first_placement_opposite = Positioner.getOppositeIndex( first_placement )

			#remove margins on the slide sides
			new_pointer_rect = pointer_dim.extendSide( first_placement, @__pointer_margin, -1 )

			if second_placement == null
				#remove side margins when centering pointer
				new_pointer_rect = new_pointer_rect.extendSide( Positioner.getIndex(first_placement+1), @__pointer_margin, -1 )
				new_pointer_rect = new_pointer_rect.extendSide( Positioner.getIndex(first_placement+3), @__pointer_margin, -1 )

			#align pointer to rect and layer to pointer
			new_pointer_rect = new_pointer_rect.align( first_placement_opposite, @__rect, first_placement )
			new_layer_rect = layer_rect.align( first_placement_opposite, new_pointer_rect, first_placement, @__layer_margin )

			#align to second pole
			if second_placement
				second_placement_opposite = Positioner.getOppositeIndex( second_placement )
				new_layer_rect = new_layer_rect.align( second_placement_opposite , @__rect, second_placement_opposite  , @__layer_margin )

			#put out new layer position
			if second_placement == null
				new_layer_rect = new_layer_rect.slideAlignToCenter(@__rect, first_placement)

			#center pointer on align side between layer and rect
			layer_side_len = new_layer_rect.getSideLength(first_placement)
			rect_side_len = new Positioner(@__rect).getSideLength(first_placement)

			if second_placement
				#align to edge
				new_pointer_rect = new_pointer_rect.align( second_placement_opposite, @__rect, second_placement_opposite )
			else
				new_pointer_rect = new_pointer_rect.slideAlignToCenter(@__rect,first_placement)

				#re-add side margins when centering
				side_index = Positioner.getIndex(first_placement)
				new_pointer_rect = new_pointer_rect.extendSide( Positioner.getIndex(first_placement+1), @__pointer_margin )
				new_pointer_rect = new_pointer_rect.extendSide( Positioner.getIndex(first_placement+3), @__pointer_margin )

			#re-add margins that we removed in the beginning
			new_pointer_rect = new_pointer_rect.extendSide( first_placement, @__pointer_margin )


			pointer_off.top = new_pointer_rect.getPos().top
			pointer_off.left = new_pointer_rect.getPos().left

		new_layer_rect = new_layer_rect.keepInside( @__viewport )
		offset = new_layer_rect.getPos()

		# @__debug.push("offset: top:"+offset.top+" left:"+offset.left)
		# @__debug.push("pointer: top:"+pointer_off?.top+" left:"+pointer_off?.left)

		#REMARKED use for debug output
#		CUI.debug "#{@__cls}.position()", @__layer.DOM[0], @__pointer?[0], @
#		CUI.debug @__pointer_dim, @__pointer_margin, @__rect, @__layer_dim, @__layer_margin
#		CUI.debug @__debug.join("\n")

		DOM.setAbsolutePosition(@__layer.DOM, offset)

		# CUI.debug "SetPosition:",offset, @__viewport

		if @__backdrop_crop
			DOM.setStylePx(@__backdrop_crop,
				top: offset.top
				left: offset.left
				width: offset.width
				height: offset.height
			)
			DOM.setStylePx(@__backdrop_crop.firstChild,
				width: @__viewport.width
				height: @__viewport.height
				top: -offset.top
				left: -offset.left
			)

		#REMARKED TODO why?
#		# set right and bottom positions for our animations
#		viewport_width =  $("body").width()
#		viewport_height =  $("body").height()
#		layer_width = @__layer.DOM.cssEdgeSpace("horizontal", true) + @__layer.DOM.width()
#		layer_height = @__layer.DOM.cssEdgeSpace("vertical", true) + @__layer.DOM.height()
#
#		layer_right = viewport_width - (offset.left + layer_width)
#		layer_bottom = viewport_height - (offset.top + layer_height)
#		@__layer.DOM.css
#			right: layer_right+"px"
#			bottom: layer_bottom+"px"



		if @__pointer
			if pointer_off
				#hide pointer if outside of viewport
				if pointer_off.top + @__pointer_dim.height + @__pointer_margin.top > @__viewport.top + @__viewport.height or
					pointer_off.top < @__viewport.top or
					pointer_off.left + @__pointer_dim.width + @__pointer_margin.left > @__viewport.left + @__viewport.width or
					pointer_off.left < @__viewport.left
						pointer_off = null
						@__pointer.detach()
				else
					DOM.setAbsolutePosition(@__pointer, pointer_off)
			else
				@__pointer.detach()

		@__getLayerDim()

		set_fixed_dimensions = false
		if isUndef(@__fixed_layer_dim)
			@__fixed_layer_dim = {}
			set_fixed_dimensions = true

		if set_fixed_dimensions or @_fill_space in ["both","horizontal"]
			@__fixed_layer_dim.width = @__layer_dim.width
			@__fixed_layer_dim._css_width = @__layer_dim.width - @__layer.DOM.cssEdgeSpace("horizontal", true)


		if set_fixed_dimensions or @_fill_space in ["both","vertical"]
			@__fixed_layer_dim.height = @__layer_dim.height
			@__fixed_layer_dim._css_height = @__layer_dim.height - @__layer.DOM.cssEdgeSpace("vertical", true)

		# console.error "set fixed dimensions", @__fixed_layer_dim, @_fill_space

		@__setLayerSizeFromFixedDimensions()

		# lets check if we can get rid of a very short
		# horizontal scrollbar
		if @__minimumElementWidthUsed
			layer_dim = DOM.getDimensions(@__layer.DOM[0])
			if layer_dim.verticalScrollbarWidth > 0
				# add width
				@__layer.DOM.width(@__fixed_layer_dim._css_width + layer_dim.verticalScrollbarWidth)

		@_onPosition?(@)
		@

	#this updates the different pointer style classes depending on current placement direction
	#placement: if null the @__placement is used
	__updatePointerOrientation: (placement = null) ->

		if placement == null
			placement = @__placement

		if @__pointer and placement
			assert(isString(placement))
			assert( placement.length > 0 && placement.length < 3 )


			placement = placement[0]
			p = DOM.data(@__pointer[0], "placement")
			if p
				@__pointer.removeClass("ez-pointer-placement-#{p}")
			@__pointer.addClass("ez-pointer-placement-#{placement}")
			DOM.data(@__pointer[0], "placement", placement)

			#make sure pointer is visible and measurable
			@__pointer.insertBefore(@__layer.DOM) # TODO not sure if this code is needed

			rect = @__pointer.rect()
			@__pointer_margin = @__getMargin(@__pointer)
			@__pointer_dim =
				width: rect.width + @__pointer_margin.left + @__pointer_margin.right
				height: rect.height + @__pointer_margin.top + @__pointer_margin.bottom

		else
			@__pointer_dim = width: 0, height: 0
			@__pointer_margin = left: 0, right: 0, bottom: 0, top: 0, width: 0, height: 0



	# returns the rectangle of available space
	# the dimension is the width and height including
	# padding and border but without space for margin
	# relative to the anchor
	__getAvailableSpace: (placement) ->
		assert( isString(placement) )
		assert( placement.length > 0 && placement.length < 3 )

		@__updatePointerOrientation(placement)

		max_space_dim = {}
		first_placement = placement[0]
		if first_placement == "c"
			#need rect relative to viewport
#			rect = new Positioner(@__rect)
#			rect.move( -@__viewport.top, -@__viewport.left )
#			local_rect = rect.getPos()
#			max_space_dim.height = Math.min(@__viewport.height - local_rect.middle, local_rect.middle) * 2
#			max_space_dim.width  = Math.min(@__viewport.width - local_rect.center, local_rect.center) * 2

			#we dont calculate the space of a centered rectangle anymore. we just say that it can use the whole space. its always better than switching to any pole later!
			max_space_dim.height = @__viewport.height
			max_space_dim.width  = @__viewport.width
		else
			first_placement_opposite = Positioner.getOppositeIndex(first_placement)
			cut_position = @__rect[ Positioner.getSide(first_placement) ]

			#remove pointer size from space TODO this is copy paste from position!
			@__pointer_dim.left = 0
			@__pointer_dim.top = 0
			pointer_dim = new Positioner(@__pointer_dim)

			#remove margins on the slide sides
			pointer_dim = pointer_dim.extendSide( first_placement, @__pointer_margin, -1 )

			cut_position += pointer_dim.getSideLength( Positioner.getIndex(first_placement)+1 ) * Positioner.getDirection(first_placement)

			viewPort = new Positioner(@__viewport)
			space_rect = viewPort.cutSide( first_placement_opposite, cut_position )
			if placement.length > 1
				second_placement = placement[1]
				second_placement_opposite = Positioner.getOppositeIndex(second_placement)
				cut_position = @__rect[ Positioner.getSide(second_placement_opposite) ]
				space_rect = space_rect.cutSide( second_placement_opposite, cut_position )

				space_rect = space_rect.extendSide( second_placement_opposite, @__layer_margin )

			space_rect = space_rect.extendSide( first_placement_opposite, @__layer_margin,1 )

			# make sure dimensions are inside viewport, space_rect.extendSide( first_placement_opposite, @__layer_margin )  could overshoot
			max_space_dim.height = Math.min( space_rect.getPos().height, @__viewport.height )
			max_space_dim.width  = Math.min( space_rect.getPos().width,  @__viewport.width  )

		return max_space_dim


	clearTimeout: ->
		if @__timeout
			CUI.clearTimeout(@__timeout)
		@__timeout = null
		@

	showTimeout: (ms=@_show_ms, ev) ->
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
				if @__element and not @elementIsInDOM()
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

		@__resetFixedLayerDim()
		@__layer.DOM.css
			width: ""
			height: ""

		if not @isShown()
			return @

		if @__element
			if @__check_for_element
				CUI.clearInterval(@__check_for_element)
			@__element.removeClass("cui-layer-active")

		if @__body_effect_class
			$(document.body).removeClass(@__body_effect_class)
			@__body_effect_class = null

		@__layer_root.DOM.detach()
		@__shown = false

		if @_handle_focus
			@focusOnHide(ev)

		if @__orig_element
			@__element = @__orig_element
			delete(@__orig_element)

		Events.ignore
			instance: @

		@_onHide?(@, ev)
		@


	# use element to temporarily overwrite element used
	# for positioning
	show: (element, ev) ->
		assert(not @isDestroyed(), "#{@__cls}.show", "Unable to show, Layer is already destroyed", layer: @)

		if Tooltip.current and @ not instanceof Tooltip
			Tooltip.current.hide()

		@clearTimeout()
		if @isShown()
			@autoSize()
			return @

		if element
			@__orig_element = @__element
			@__element = element

		# get @__appendToElement
		@__appendToElement = $(document.body)

		@__layer.DOM.css
			top: 0
			left: 0

		@__layer_root.DOM.appendTo(@__appendToElement)

		if @_element
			@_element.addClass("cui-layer-active")

			if @_check_for_element
				@__check_for_element = CUI.setInterval =>
					if not @elementIsInDOM()
						@destroy()
				,
					200

		if @_auto_size
			Events.listen
				type: "content-resize"
				instance: @
				node: @__layer
				call: (ev) =>
					# CUI.debug "Layer caught event: \"#{ev.getType()}\", executing \"autoSize\"."
					@autoSize()

		Events.listen
			type: "viewport-resize"
			instance: @
			node: @__layer
			call: (ev) =>
				if @__element and not @elementIsInDOM()
					# ignore the event
					return

				# CUI.debug "Layer caught event: \"#{ev.getType()}\", executing \"position\".", "destroyed:", @isDestroyed(), "in DOM:", DOM.isInDOM(@__layer_root.DOM[0])

				@__placement = null # reset placement so it cant be used as previous placement.
				# in theory we could just refresh the maximum values on our layer and its position, currently thats not working (buggy or execution path is not prepared).
				# its also stupid cause we could end up with a 0 size and that would be strange
				# so its best to recalculate the whole thing
				@__placement = null # reset placement so it cant be used as previous placement.
				@__resetFixedLayerDim()
				@position()
				return

		@_onBeforeShow?(@, ev)
		@__shown = true

		#call position twice to force a refresh of the layer div
		#otherwise we could get wrong dimensions (when scrolling bars are added to late etc.)
		@position()

		if @_handle_focus
			@focusOnShow(ev)

		@_onShow?(@, ev)
		@

	isKeyboardCancellable: (ev) ->
		if @__bd_policy in ["click", "click-thru"] and not @__backdropClickDisabled
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

	elementIsInDOM: ->
		@__element and DOM.isInDOM(@__element[0])

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

Layer = CUI.Layer


CUI.ready ->
	Events.listen
		type: "keyup"
		node: document
		call: (ev) ->
			if ev.keyCode() != 27
				return

			layer_elements = DOM.findElements(document.body, "body > .cui-tmpl-layer-root > .cui-layer")
			layer_element = layer_elements[layer_elements.length-1]
			element = DOM.closest(ev.getTarget(), "[tabindex],input,textarea")

			console.debug "keyup", ev, ev.getTarget()

			if (element and element != layer_element) or not layer_element
				# ignore this
				return

			ev.stopImmediatePropagation()
			ev.preventDefault()

			layer = DOM.data(layer_element, "element")
			if layer.isKeyboardCancellable(ev)
				layer.doCancel(ev)
				return false
			return