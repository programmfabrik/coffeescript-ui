###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

# Short message that slides in at the top of the window and goes away by itself.
# It never takes the focus, a new one of the same group replaces the one on screen.
class CUI.Notification extends CUI.DOMElement

	@__container: null

	@__byGroup: {}

	initOpts: ->
		super()
		@addOpts
			text:
				mandatory: true
				check: String
			icon:
				check: (v) ->
					CUI.util.isString(v) or v instanceof CUI.Icon
			# 0 keeps it until hide()
			show_ms:
				default: 3000
				check: (v) ->
					CUI.util.isInteger(v) and v >= 0
			group:
				check: String

	readOpts: ->
		super()
		@__label = new CUI.Label
			text: @_text
			icon: @_icon
			multiline: true

		@registerDOMElement(CUI.dom.div(null, role: "status", "aria-live": "polite"))
		CUI.dom.append(@DOM, @__label.DOM)

		# hovering keeps it, to give time to read it
		CUI.Events.listen
			type: "mouseenter"
			node: @DOM
			instance: @
			call: =>
				CUI.clearTimeout(@__hideTimeout)
		CUI.Events.listen
			type: "mouseleave"
			node: @DOM
			instance: @
			call: =>
				@__startTimeout()
		CUI.Events.listen
			type: "click"
			node: @DOM
			instance: @
			call: =>
				@hide()
		@

	show: ->
		if @isDestroyed() or @__shown
			return @

		@__shown = true
		if @_group
			CUI.Notification.__byGroup[@_group]?.hide()
			CUI.Notification.__byGroup[@_group] = @

		CUI.dom.append(CUI.Notification.__getContainer(), @DOM)
		# a reflow first, so the slide in runs from the starting position
		@DOM.offsetHeight
		CUI.dom.addClass(@DOM, "cui-notification--shown")
		@__startTimeout()
		@

	update: (opts) ->
		if opts.text
			@__label.setText(opts.text)
		if opts.icon
			@__label.setIcon(opts.icon)
		@__startTimeout()
		@

	hide: ->
		if not @__shown
			return @

		@__shown = false
		CUI.clearTimeout(@__hideTimeout)
		if @_group and CUI.Notification.__byGroup[@_group] == @
			delete(CUI.Notification.__byGroup[@_group])

		CUI.dom.removeClass(@DOM, "cui-notification--shown")
		# transitionend does not come without a transition (reduced motion), so a timeout removes it
		CUI.setTimeout
			ms: 400
			call: =>
				@destroy()
		@

	isShown: ->
		!!@__shown

	destroy: ->
		CUI.clearTimeout(@__hideTimeout)
		CUI.Events.ignore(instance: @)
		super()

	__startTimeout: ->
		CUI.clearTimeout(@__hideTimeout)
		if @_show_ms > 0
			@__hideTimeout = CUI.setTimeout
				ms: @_show_ms
				call: =>
					@hide()
		return

	@__getContainer: ->
		if not CUI.dom.isInDOM(@__container)
			@__container = CUI.dom.div("cui-notification-container")
			document.body.appendChild(@__container)
		@__container

	# shows the notification, or updates the one of the same group that is still on screen
	@show: (opts) ->
		current = @__byGroup[opts.group] if opts.group
		if current?.isShown()
			return current.update(opts)
		new CUI.Notification(opts).show()

CUI.notify = (opts) ->
	CUI.Notification.show(opts)
