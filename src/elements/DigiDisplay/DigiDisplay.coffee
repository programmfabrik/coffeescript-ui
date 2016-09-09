class DigiDisplay extends CUI.DOM

	constructor: (@opts={}) ->
		super(@opts)
		@__digitsMap = []
		@createMarkup()
		@registerDOMElement(@__displayDiv)

	initOpts: ->
		super()
		@addOpts
			digits:
				mandatory: true
				check: Array

	display: (str) ->
		for c, idx in str.split("")
			if idx == @_digits.length
				break

			info = @__digitsMap[idx]

			if not info
				continue

			if info.map.hasOwnProperty(c)
				_idx = info.map[c]
			else
				_idx = 0

			fc = info.first_div

			if not info.height
				info.height = fc.outerHeight()
			fc.css("marginTop", "-"+(_idx*info.height)+"px")
			fc.attr("c", c)
			fc.attr("idx", _idx)
		@

	createMarkup: ->
		@__displayDiv = $div("cui-digi-display")

		for digit, digit_idx in @_digits
			if digit.static
				@__displayDiv.append(
					container = $div("cui-digi-display-static cui-digi-display-#{digit_idx}")

				)
				container.append($text(digit.static)).addClass(digit.class)
				if digit.attr
					container.attr(digit.attr)
				continue
			digit.__regexp = new RegExp(digit.mask)
			@__displayDiv.append(
				container = $div("cui-digi-display-container cui-digi-display-#{digit_idx}")
			)
			container.addClass(digit.class)
			if digit.attr
				container.attr(digit.attr)

			@__digitsMap[digit_idx] = map: (map = {})

			# for the "unknown character
			container.append(fc = $div("cui-digi-display-digit").html("&nbsp;"))
			@__digitsMap[digit_idx].first_div = fc
			idx = 1
			matched = false
			for i in [32..128]
				if digit.__regexp.exec(c = String.fromCharCode(i))
					if i == 32
						container.append($div("cui-digi-display-digit").html("&nbsp;"))
					else
						container.append($div("cui-digi-display-digit").text(c))
					map[c] = idx
					idx++
					matched = true

			assert(matched, "DigiDisplay.createMarkup", "Digit #{digit_idx} not matched against the regexp. ASCII range 32-128 is allowed.", digit: digit)

			# CUI.debug "created markup with map", map
		@__displayDiv
