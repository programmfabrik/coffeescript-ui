globalDrag = null

class Movable extends Draggable
	@cls = "movable"

	initOpts: ->
		super()
		@addOpts
			limitRect:
				default: {}
				check: (v) ->
					CUI.isPlainObject(v) or v instanceof Function

			positioned:
				check: Function

			position:
				check: Function

			do_drag:
				check: Function

	getLimitRect: ->
		if CUI.isFunction(@_limitRect)
			@_limitRect()
		else
			@_limitRect

	setElementCss: (pos) ->
		assert($.isPlainObject(pos), getObjectClass(@), "opts.position must return a PlainObject containing any of x, y, w, h", pos: pos)
		setCss = {}
		if not isEmpty(pos.x)
			setCss.left = pos.x
		if not isEmpty(pos.y)
			setCss.top = pos.y
		if not isEmpty(pos.w)
			setCss.marginBoxWidth = pos.w
		if not isEmpty(pos.h)
			setCss.marginBoxHeight = pos.h

		CUI.DOM.setDimensions(@element[0], setCss)
		@_positioned?(pos)


	startDrag: (ev, $target) ->
		# CUI.debug "startDrag target", ev.getTarget(), $target[0]
		if CUI.DOM.closest(ev.getTarget(), ".cui-resizable-handle")
			return
		# CUI.debug "startDrag on #{@cls}", ev, $target[0]
		super(ev, $target)


	before_drag: ->
		dim = CUI.DOM.getDimensions(@element[0])
		@start =
			x: dim.left or 0
			y: dim.top or 0
			w: dim.marginBoxWidth
			h: dim.marginBoxHeight
		@

	do_drag: (ev, $target, diff) ->
		if @_do_drag
			return @_do_drag(ev, $target, diff, @)

		pos =
			x: diff.x+@start.x
			y: diff.y+@start.y
			w: @start.w
			h: @start.h

		if @_position
			[pos.x, pos.y] = @_position(pos.x, pos.y, @start, diff)
		else
			@limitRect(pos, @start)

		@setElementCss(pos)

	# keep pos inside certain constraints
	# pos.fix is an Array containing any of "n","w","e","s"
	# limitRect: min_w, min_h, max_w, max_h, min_x, max_x, min_y, max_y
	limitRect: (pos, defaults={}, limitRect = @getLimitRect()) =>
		pos.fix = pos.fix or []
		for k,v of defaults
			if isUndef(pos[k])
				pos[k] = v

		# CUI.debug "limitRect BEFORE ", pos, defaults, limitRect

		for key in [
			"min_w"
			"max_w"
			"min_h"
			"max_h"
			"min_x"
			"max_x"
			"min_y"
			"max_y"
			]
			value = limitRect[key]
			if isUndef(value)
				continue

			assert(not isNaN(value), "#{getObjectClass(@)}.limitRect", "key #{key} in pos isNaN", pos: pos, defaults: defaults, limitRect: limitRect)

			skey = key.substring(4)
			mkey = key.substring(0,3)
			if key == "max_x"
				value -= pos.w
			if key == "max_y"
				value -= pos.h

			diff = pos[skey] - value
			if mkey == "min"
				if diff >= 0
					continue
			if mkey == "max"
				if diff <= 0
					continue

			if skey == "y" and "n" in pos.fix
				pos.h -= diff
				continue
			if skey == "x" and "w" in pos.fix
				pos.w -= diff
				continue

			# CUI.debug "correcting #{skey} by #{diff} from #{pos[skey]}"

			pos[skey]-=diff

			if skey == "h" and "s" in pos.fix
				# CUI.debug "FIX y"
				pos.y += diff
			if skey == "w" and "e" in pos.fix
				# CUI.debug "FIX x"
				pos.x += diff
			if skey == "x" and "e" in pos.fix
				# CUI.debug "FIX w"
				pos.w += diff
			if skey == "y" and "s" in pos.fix
				# CUI.debug "FIX h"
				pos.h += diff

		# CUI.debug "limitRect AFTER", pos, diff

		pos

