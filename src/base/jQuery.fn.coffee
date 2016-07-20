
jQuery.fn.cssInt = (propertyName, check=true) ->
	if @[0]
		el = $(@[0])
		s = el.css(propertyName)
		if s == undefined or s == ""
			return 0
		assert(not check or s.match(/px$/), "cssInt", "css(\"#{propertyName}\") did not return \"px\" but \"#{s}\".")
		i = parseInt(s)
		if isNaN(i)
			return 0
		else
			return i

jQuery.fn.cssFloat = (propertyName, check=true) ->
		el = $(@[0])
		s = el.css(propertyName)
		if s == undefined or s == ""
			return 0
		assert(not check or s.match(/px$/), "cssFloat", "css(\"#{propertyName}\") did not return \"px\" but \"#{s}\".")
		i = parseFloat(s)
		if isNaN(i)
			return 0
		else
			return i

# find the closest scrollable contain#
# jQuery.fn.offsetScrollContainer = ->
#	el = $(@[0])
#	while true
#		CUI.debug el[0], "x", el.css("overflow-x"), "y",  el.css("overflow-y")
#		el = el.offsetParent()
#		if el.is("html")
#			break



jQuery.fn.relativePosition = ->
	if @[0]
		relPos = @position()
		$p = @offsetParent()
		if not $p.is("html")
			relPos.top += $p[0].scrollTop
			relPos.left += $p[0].scrollLeft
		return relPos

jQuery.fn.rect = (show, timeout=false, label) ->
	el = @[0]
	if not el
		return

	if not show
		return el.getBoundingClientRect()
	else
		if not el
			return null

		rect = el.getBoundingClientRect()
		d = $div("ez-rect-debug").appendTo(document.body)
		t = [ "node: #{el.tagName}" ]
		for k, v of rect
			t.push("#{k}: #{v}")
		d.prop("title", t.join("\n"))

		offset =
			top: rect.top
			left: rect.left
		DOM.setAbsolutePosition(d, offset)
		d.css
			width: rect.width
			height: rect.height
		Events.listen
			type: "click"
			node: d
			call: ->
				d.remove()
		if parseInt(timeout) >= 0
			d.addClass("ez-rect-debug-timeout")
			if label
				l = $span("ez-rect-debug-label").text(label)
				l.appendTo(document.body)
				DOM.setAbsolutePosition(l, offset)
			do (l, d) ->
				CUI.setTimeout ->
					l?.remove()
					d.remove()
				,
					timeout
		else
			window.rect = el
			CUI.info(".rect for", el, "stored in window.rect", rect)
		return rect

jQuery.fn.cssEdgeSpace = (dir, includeMargin=false) ->
	if not @[0]
		return null

	if dir == "vertical"
		return @cssEdgeSpace("top", includeMargin)+@cssEdgeSpace("bottom", includeMargin)
	if dir == "horizontal"
		return @cssEdgeSpace("left", includeMargin)+@cssEdgeSpace("right", includeMargin)

	edge = @.cssFloat("padding-#{dir}") + @.cssFloat("border-#{dir}-width")
	if includeMargin
		edge += @.cssFloat("margin-#{dir}")
	return edge

jQuery.Event.prototype.hasModifierKey = (includeShift=false) ->
	@metaKey or @ctrlKey or @altKey or (includeShift and @shiftKey) or false

jQuery.Event.prototype.isCursorKey = ->
	@which in [16, 17, 18, 33, 34, 35, 36, 37, 38, 39, 40]

