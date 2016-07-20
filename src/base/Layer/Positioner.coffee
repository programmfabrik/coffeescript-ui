# a class to hold positioning information
# for a layer
#
# top:
# left:
# bottom:
# right:
# width:
# height:
# middle: means centerY
# center: means centerX


class Positioner
	constructor: (obj) ->
		el = obj
		if obj?.DOM
			el = obj.DOM
		else
			el = obj
		if isElement(el)
			pos = el.rect()
			assert(pos.width > 0 and pos.height > 0, "new Positioner", "Element is not visible.", element: el[0])
			@__pos = @__convertToPositioner(pos)
		else if obj instanceof Positioner
			@__pos = copyObject( obj.getPos(), true )
		else
			@__pos = @__convertToPositioner(obj)


	@__poleIndices:  ["s","e","n","w"]
	@__sideIndices:  ["bottom","right","top","left"]
	@__directions: 	[1,1,-1,-1]
	@__dimension:	["height","width","height","width"]
	@__axis:			["y","x","y","x"]

	keys: [
		"top"
		"left"
		"bottom"
		"right"
		"width"
		"height"
	]

	getDim: ->
		width: @__pos.width
		height: @__pos.height

	translate: (x,y) ->
		@move( x - @__pos.left, y - @__pos.top )

	translateX: (x) ->
		@move( x - @__pos.left, 0 )

	translateY: (y) ->
		@move( 0, y - @__pos.top )

	translateCenterY: (y) ->
		@move( 0, y - @__pos.middle )

	translateCenterX: (x) ->
		@move( x - @__pos.center, 0 )


	move: (x,y) ->
		@__pos.top += y
		@__pos.bottom += y
		@__pos.middle += y
		@__pos.left += x
		@__pos.right += x
		@__pos.center += x


	updateHeightAndWidth: ->

		@__pos.width  = @__pos.right  - @__pos.left
		@__pos.height = @__pos.bottom - @__pos.top

	updateHeightAndWidthAndCenter: ->

		@__pos.width  = @__pos.right  - @__pos.left
		@__pos.height = @__pos.bottom - @__pos.top
		@__pos.center = (@__pos.right - @__pos.left) / 2 + @__pos.left
		@__pos.middle = (@__pos.bottom - @__pos.top) / 2 + @__pos.top

	__convertToPositioner: (_pos) ->
		pos = {}
		for k in @keys
			if isInteger(_pos[k]) or isFloat(_pos[k]) # isNumber?
				pos[k] = _pos[k]
			else
				pos[k] = null

		if pos.top != null and pos.height != null
			pos.bottom = pos.top + pos.height

		if pos.left != null and pos.width != null
			pos.right = pos.left + pos.width

		if pos.left != null and pos.right != null
			pos.center = (pos.right - pos.left) / 2 + pos.left

		if pos.top != null and pos.bottom != null
			pos.middle = (pos.bottom - pos.top) / 2 + pos.top

		wrong = []
		for k, v of pos
			if v == null and k not in ["bottom","right"]
				wrong.push(k)
		assert(wrong.length == 0, "new Positioner", "Position is not complete, missing keys are \"#{wrong.join()}\".", opts: @opts)
		pos

	getPos: ->
		@__pos

	#side: integer or string, returns "y" for s/n and "x" for w/e
	#returns "x" or "y"
	@getAxis: (side) ->
		return Positioner.__axis[Positioner.getIndex(side)]

	#side: integer or string
	#returns "height" for s/n and "width" for w/e
	@getDimension: (side) ->
		return Positioner.__dimension[Positioner.getIndex(side)]

	#side: integer or string, string can be either a pole or side
	#returns pole string
	@getPole: (side) ->
		return Positioner.__poleIndices[Positioner.getIndex(side)]

	#side: integer or string, string can be either a pole or side
	#returns side name
	@getSide: (side) ->
		return Positioner.__sideIndices[Positioner.getIndex(side)]

	#side: integer or string, string can be either a pole or side
	#returns direction on axis 1 or -1
	@getDirection: (side) ->
		return Positioner.__directions[Positioner.getIndex(side)]

	#side: integer or string, string can be either a pole or side
	#returns side index or whatever
	@getIndex: (side) ->
		if isInteger(side)
			return side % 4
		else
			assert( isString(side) )
			index = -1
			if( side.length == 1 )
				index = Positioner.__poleIndices.indexOf(side)
			else
				index = Positioner.__sideIndices.indexOf(side)

			assert(index >= 0)
			return index


	# converts n to s , w to e, bottom to top etc.
	#side: integer or string, string can be either a pole or side
	# returns index
	@getOppositeIndex: (side) ->
		return Positioner.getIndex( Positioner.getIndex(side) + 2)

	# aligns this Positioner (alignmentSide) to target (targetSide)
	# alignSide: can be a index, pole or side
	# target: should be a map from positioner
	# targetSide: can be a index, pole or side
	# subtract_margin: if margin map is given then the its removed from alignmentSide before aligning
	# returns result as Positioner
	align: ( align_side, target, target_side, subtract_margin = null ) ->

		align_side_index = Positioner.getIndex(align_side)
		align_side = Positioner.__directions[align_side_index]
		target_side = Positioner.getSide(target_side)

		axis = Positioner.getAxis(target_side);
		assert( axis == Positioner.getAxis(align_side_index) );

		#TODO avoid casting for performance, currently it throws nice asserts
		target = new Positioner(target)

		target_pos = target.getPos()[target_side]

		if subtract_margin != null
			target_pos += subtract_margin[Positioner.__sideIndices[align_side_index]] * Positioner.__directions[align_side_index]

		if Positioner.__directions[align_side_index] > 0
			target_pos -= @getPos()[ Positioner.__dimension[align_side_index] ]

		result = new Positioner(@)
		if axis == "x"
			result.translateX( target_pos )
		else
			result.translateY( target_pos )

		return result

	# side: can be a index, pole or side
	# returns length of given side
	getSideLength: (side) ->
		target_side_index = Positioner.getIndex( side )
		start_side = Positioner.getSide( target_side_index + 1 )
		end_side =   Positioner.getSide( target_side_index + 3 ) # -1 one is not working

		start_pos = @getPos()[start_side]
		end_pos = @getPos()[end_side]

		length = Math.abs(end_pos - start_pos)

		return length

	#this moves the positioner to keep it inside outerRect. no shrinking!
	keepInside: ( outer_rect ) ->

		outer_rect = new Positioner(outer_rect).getPos()

		#top and left have priority! (reading direction)
		result = new Positioner(@)
		if @__pos.left < outer_rect.left
			result.move( outer_rect.left - @__pos.left, 0  )
		else if @__pos.right > outer_rect.right
			result.move( outer_rect.right - @__pos.right, 0  )

		if @__pos.top < outer_rect.top
			result.move( 0, outer_rect.top - @__pos.top  )
		else if @__pos.bottom > outer_rect.bottom
			result.move( 0, outer_rect.bottom - @__pos.bottom  )

		return result


			# alignment 'sliding' on the tangent of the target side
	# target: Positioner or rect that our object should slide on
	# targetSide: side on which we slide
	# returns result as Positioner
	slideAlignToCenter: (target, targetSide ) ->

		axis = Positioner.getAxis(targetSide)

		target = new Positioner(target)

		# get start end position of our targetSide
		target_side_index = Positioner.getIndex( targetSide )
		start_side = Positioner.getSide( target_side_index + 1 )
		end_side =   Positioner.getSide( target_side_index + 3 ) # -1 one is not working

		start_pos = target.getPos()[start_side]
		end_pos = target.getPos()[end_side]

		center_pos = (end_pos - start_pos) / 2 + start_pos

		result = new Positioner(@)

		if axis == "y"
			result.translateCenterX(center_pos)
		else
			result.translateCenterY(center_pos)

		return result

	# rectangle: rectancle that will be extended
	# side: side of rectangle to extend
	# margin: extend side by margin.side
	# factor: multiplies margin.side , use -1 to shrink side
	# return: extended rectangle positioner map
	extendSide: ( side, margin, factor=1.0 ) ->
		assert( isNumber(factor) )

		side_index = Positioner.getIndex(side)
		side = Positioner.__sideIndices[side_index]

		if not isNumber(margin)
			margin = margin[side]

		newPos = @__pos[side]
		newPos += margin * Positioner.__directions[side_index] * factor

		result = new Positioner(@)
		result.getPos()[side] = newPos
		result.updateHeightAndWidthAndCenter()
		return result

	#cuts away a portion of the given rectangle
	#instead of just setting the position, this function takes care that the cutting is inside the rectangle
	# side_to_cut: that should be cuttet away
	# cut_position:
	# returns result as Positioner
	cutSide: ( side_to_cut, cut_position ) ->

		side_to_cut_index = Positioner.getIndex(side_to_cut)
		opposite_side_to_cut_index = Positioner.getIndex(side_to_cut + 2)

		#avoid to extend the rectangle
		end_pos = @getPos()[Positioner.__sideIndices[side_to_cut_index]]
		start_pos = @getPos()[Positioner.__sideIndices[opposite_side_to_cut_index]]

		if start_pos > end_pos
			v = end_pos
			end_pos = start_pos
			start_pos = v

		if Positioner.__directions[side_to_cut_index] > 0
			if cut_position > end_pos
				cut_position = end_pos
		else if Positioner.__directions[side_to_cut_index] < 0
			if cut_position < start_pos
				cut_position = start_pos

		result = new Positioner(@)
		if cut_position >= start_pos and cut_position <= end_pos
			result.getPos()[Positioner.__sideIndices[side_to_cut_index]] = cut_position
			result.updateHeightAndWidthAndCenter()

		return result


	basicTest: ->
		assert( Positioner.getIndex(1) == 1 )
		assert( Positioner.getIndex(5) == 1 )
		assert( Positioner.getIndex("e") == 1 )
		assert( Positioner.getPole(2) == "n" )
		assert( Positioner.getOppositeIndex(3) == 1 )
		assert( Positioner.getOppositeIndex("w") == 1 )
		assert( Positioner.getIndex("w") == 3 )
		assert( Positioner.getAxis("w") == "x" )
		assert( Positioner.getAxis("top") == "y" )
		#TODO need tests for cutSide etc.
