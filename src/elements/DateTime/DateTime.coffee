###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

CUI.Template.loadTemplateText(require('./DateTime.html'));

# CUI.tz_data = {}
moment = require('moment')

class CUI.DateTime extends CUI.Input
	constructor: (opts) ->
		super(opts)
		@init()

	@defaults:
		button_tooltip: "Open calendar"
		bc_appendix: ["B.C.","BC"]

	initOpts: ->
		super()

		locale = CUI.DateTime.getLocale()

		@addOpts
			locale:
				mandatory: true
				default: locale
				check: (v) ->
					CUI.util.isArray(CUI.DateTimeFormats[v]?.formats)
			input_types:
				check: Array
			display_type:
				default: "long"
				check: ["long", "short"]
			min_year:
				mandatory: true
				default: 0
				check: "Integer"
			max_year:
				mandatory: true
				default: 9999
				check: "Integer"
			store_invalid:
				mandatory: true
				default: false
				check: Boolean

		@removeOpt("getValueForDisplay")
		@removeOpt("getValueForInput")
		# @removeOpt("correctValueForInput")
		@removeOpt("checkInput")
		@removeOpt("getInputBlocks")

	init: ->
		@__regexpMatcher = @regexpMatcher()

		@__input_formats_known = CUI.DateTimeFormats[@_locale].formats
		@__locale_format = CUI.DateTimeFormats[@_locale]

		@__input_formats = []
		if not @_input_types?.length
			@__input_formats = @__input_formats_known.slice(0)
		else
			for type in @_input_types
				found = false
				for f in @__input_formats_known
					if f.type == type
						@__input_formats.push(f)
						found = true
				CUI.util.assert(found, "new CUI.DateTime", "opts.input_types contains unknown type: #{type}", formats: @__input_formats_known, input_type: @_input_types)
		@__default_format = @__input_formats[0]
		for format in @__input_formats
			if format.clock == false
				@__input_format_no_time = format
				@__default_format = format
				break
		@__input_format = @initFormat(@__default_format)
		return

	setInputFormat: (use_clock = @__input_formats[0].clock) ->
		if use_clock == true
			@__input_format = @initFormat(@__input_formats[0])
		else
			@__input_format = @initFormat(@__input_format_no_time)
		@

	initDateTimePicker: ->
		if @__dateTimeTmpl
			return @__dateTimeTmpl

		@__dateTimeTmpl = new CUI.Template
			name: "date-time"
			map:
				calendar: true
				analog_clock: true
				hour_minute: true
				digi_clock: true
				# timezone_display: true
				# timezone: true
				header_left: true
				header_center: true
				header_right: true
				hour: true
				minute: true
				second: true

		for k in [
			"calendar"
			"hour_minute"
			"hour"
			"minute"
			"second"
		]
			@["__#{k}"] = @__dateTimeTmpl.map[k]

		@__dateTimeTmpl.append(
			new CUI.defaults.class.Button(
				class: "cui-date-time-browser-date"
				icon_left: "left"
				text: @__locale_format.tab_date
				onClick: =>
					@setCursor("day")
			)
		, "header_left")

		@__dateTimeTmpl.append(
			new CUI.defaults.class.Button(
				class: "cui-date-time-browser-time"
				icon_right: "right"
				text: @__locale_format.tab_time
				onClick: =>
					@setCursor("hour")
			)
		, "header_right")

		# @__timezone_display = tmpl.map.timezone_display
		# @__timeZone = new CUI.Select
		# 	data: CUI.tz_data
		# 	name: "tz"
		# 	mark_changed: false
		# 	undo_support: false
		# 	onDataChanged: (data) =>
		# 		@setPrintClock(@__current_moment)
		# 	options: =>
		# 		@getTimezoneOpts()
		# .start()
		#
		# tmpl.append(@__timeZone, "timezone")

		@setCursor("day")

		# if @__input_format.digi_clock
		# 	@__dateTimeTmpl.append(@getDigiDisplay(@__input_format.digi_clock), "digi_clock")

		@__dateTimeTmpl


	getTemplate: ->
		new CUI.Template
			name: "date-time-input"
			map:
				center: true
				right: true


	readOpts: ->
		super()
		@_checkInput = @__checkInput
		@_getInputBlocks = @__getInputBlocks
		# @_correctValueForInput = (dateTime, value) =>
		# 	corrected_value = @parseAndFormatValue(value, "input")
		# 	if corrected_value
		# 		corrected_value
		# 	else
		# 		# keep the invalid value
		# 		value

	getCurrentFormat: ->
		@__input_format

	getCurrentFormatDisplay: ->
		@__input_format?.__display

	setCursor: (cursor) ->
		switch cursor
			when "hour", "minute", "second", "am_pm"
				title = @__locale_format.tab_time
				CUI.dom.setAttribute(@__dateTimeTmpl.DOM, "browser", "time")
				@setDigiClock()
			else
				title = @__locale_format.tab_date
				CUI.dom.setAttribute(@__dateTimeTmpl.DOM, "browser", "date")

		@__dateTimeTmpl.replace(new CUI.Label(text: title), "header_center")
		@

	initFormat: (input_format) ->

		moment.locale(@__locale_format.moment_locale or @_locale)

		switch @_display_type
			when "short"
				input_format.__display = input_format.display_short
			else
				input_format.__display = input_format.display

		@_invalidHint = text: input_format.invalid

		for k, v of @__regexpMatcher
			v.match_str = k

		input = input_format.input
		rstr = "("+Object.keys(@__regexpMatcher).join("|")+")"
		re = new RegExp(rstr, "g")
		s = input.split("")
		regexp = []
		matcher = []
		last_match_end = 0
		while (match = re.exec(input)) != null
			match_str = match[0]
			match_start = match.index
			regexp.push("("+CUI.util.escapeRegExp(s.slice(last_match_end, match_start).join(""))+")")
			regexp.push("("+@__regexpMatcher[match_str].regexp+")")
			matcher.push(@__regexpMatcher[match_str])

			last_match_end = match_start + match_str.length

		regexp.push("("+CUI.util.escapeRegExp(s.slice(last_match_end).join(""))+")")

		input_format.regexp = new RegExp("^"+regexp.join("")+"$")
		input_format.matcher = matcher

		input_format

	getTemplateKeyForRender: ->
		"center"

	render: ->
		super()
		if CUI.util.isEmpty(@_placeholder)
			@__input.setAttribute("placeholder", @__input_formats[0].text)

		switch @_display_type
			when "short"
				display_key = "display_short"
			else
				display_key = "display"

		attr = @__input_formats[0][display_key+'_attribute']

		if not attr
			attr = @__input_formats[0][display_key].replace(/[:, \.]/g, "-").replace(/-+/g,"-")

		@DOM.setAttribute("data-cui-date-time-format", attr)

		@addClass("cui-data-field--with-button")

		@__calendarButton = new CUI.defaults.class.Button
			icon: "calendar"
			tooltip: text: CUI.DateTime.defaults.button_tooltip
			onClick: =>
				@openPopover(@__calendarButton)

		@replace(@__calendarButton, "right")


	format: (_s, _output_format="display", output_type=null, parseZone = false) ->
		CUI.util.assert(_output_format in CUI.DateTime.formatTypes, "CUI.DateTime.format", "output_format must be on of \"#{CUI.DateTime.formatTypes.join(',')}\".", parm1: _s, output_format: output_format)

		if moment.isMoment(_s)
			mom = _s
		else
			s = _s?.trim()

			if CUI.util.isEmpty(s)
				return null

			mom = @parse(s, @__input_formats_known)

		if mom.isValid() and CUI.util.isNull(output_type)
			output_type = @getCurrentFormat().type

		if not mom.isValid()
			formats_tried = []
			for format in @__input_formats_known
				for k in CUI.DateTime.formatTypes
					formats_tried.push(format[k])

			console.warn("CUI.DateTime.format: Moment '#{s}' is invalid. Tried formats:", formats_tried)
			return null

		output_format = null
		for f in @__input_formats_known
			if f.type == output_type
				output_format = f
				break

		CUI.util.assert(output_format, "CUI.DateTime.format", "output_type must be in known formats", formats: @__input_formats_known, output_type: output_type)

		switch _output_format
			when "store"
				return CUI.DateTime.formatMoment(mom, output_format[_output_format], parseZone)
			else
				return CUI.DateTime.formatMomentWithBc(mom, output_format[_output_format])

	regexpMatcher: ->
		YYYY:
			regexp: "(?:-|)[0-9]{1,}"
			inc_func: "year"
			cursor: "year"
		MM:
			regexp: "(?:0[1-9]|1[0-2])"
			inc_func: "month"
			cursor: "month"
		DD:
			regexp: "[0-3][0-9]"
			inc_func: "day"
			cursor: "day"
		HH:
			regexp: "[0-2][0-9]"
			inc_func: "hour"
			cursor: "hour"
		hh:
			regexp: "[0-1][0-9]"
			inc_func: "hour"
			cursor: "hour"
		mm:
			regexp: "[0-5][0-9]"
			inc_func: "minute"
			cursor: "minute"
		ss:
			regexp: "[0-5][0-9]"
			inc_func: "second"
			cursor: "second"
		A:
			regexp: "(?:AM|PM)"
			inc_func: @incAMPM
			cursor: "am_pm"
		a:
			regexp: "(?:am|pm)"
			inc_func: @incAMPM
			cursor: "am_pm"
		Y:
			regexp: "(?:-|)[0-9]{1,}"
			inc_func: "year"
			cursor: "year"

	incAMPM: (mom) ->
		current_hour = mom.hour()
		if current_hour < 12 # AM
			# set PM
			mom.add(12,"hour")
		else
			mom.subtract(12,"hour")

	initValue: ->
		super()
		value = @getValue()
		parsedValue = @parseValue(value, "store")
		if parsedValue
			# When the parsedValue and the value are different in a display format, it means that there is something wrong.
			# We do not compare only the store value because they can be different but represent the same value if they have different timezones.
			_value = @format(value)
			_parsedValue = @format(parsedValue)
			if _parsedValue != _value
				console.warn("CUI.DateTime.initValue: Corrected value in data:", parsedValue, "Original value:", value)
				@__data[@_name] = parsedValue
		@

	getValueForDisplay: ->
		value = @getValue()?.trim?()

		if CUI.util.isEmpty(value)
			return ""

		mom = @parse(value)

		if not mom.isValid()
			return value

		return CUI.DateTime.formatMomentWithBc(mom, @getCurrentFormatDisplay())

	getValueForInput: (v = @getValue()) ->
		if CUI.util.isEmpty(v?.trim())
			return ""

		mom = @parse(v)
		if not mom.isValid()
			return v

		return CUI.DateTime.formatMomentWithBc(mom, @__input_format.input)

	__checkInput: (value) ->
		@__calendarButton.enable()

		if not CUI.util.isEmpty(value?.trim())
			mom = @parse(value)
			if not mom.isValid()
				return false

			if mom.bc or value.startsWith("-")
				@__calendarButton.disable()

		else
			@__input_format = @initFormat(@__default_format)
		return true

	__getInputBlocks: (v) ->
		# console.debug "getInputBlocks", v, @__input_format.regexp
		match = v.match(@__input_format.regexp)
		if not match
			return false
		blocks = []
		pos = 0
		for m, idx in match
			if idx == 0
				continue

			if idx % 2 == 0
				blocks.push new CUI.DateTimeInputBlock
					start: pos
					string: m
					datetime: v
					input_format: @__input_format
					matcher: @__input_format.matcher[idx/2-1]

			pos += m.length

			if idx % 2 == 1
				continue

		blocks

	start_day: 1

	storeValue: (value, flags={}) ->
		mom = @parse(value)
		if mom.isValid()
			if mom.bc
				value = "-"+mom.bc
			else
				value = mom.format(@__input_format.store)

		else if @_store_invalid and value.trim().length > 0
			value = 'invalid'
		else
			value = null
		super(value, flags)
		@

	getDigiDisplay: (format) ->
		digits = []
		for d in format.split("")
			if (idx = ["H","h","m","s","A","a"].indexOf(d)) > -1
				cursor = ["hour", "hour", "minute", "second", "am_pm", "am_pm"][idx]
				if d in ["A", "a"]
					digits.push(mask: "[aApP]", attr: cursor: cursor, title: cursor)
					digits.push(mask: "[mM]", attr: cursor: cursor, title: cursor)
				else
					digits.push(mask: "[0-9]", attr: cursor: cursor)
			else if d == "*"
				digits.push(mask: "[0-9A-Z+\-:\. ]")
			else
				digits.push(static: ":")

		# console.debug digits
		@__digiDisplay = new CUI.DigiDisplay(digits: digits)


	openPopover: (btn) ->
		@initDateTimePicker()
		@__popover = new CUI.Popover
			element: btn
			handle_focus: false
			onHide: =>
				@displayValue()
				@closePopover()
			placement: "se"
			class: "cui-date-time-popover"
			pane:
				content: @__dateTimeTmpl
		@updateDateTimePicker()
		@setCursor("day")
		# if not @__current_moment.__now
		# 	@setInputFromMoment()
		@__popover.show()
		@

	closePopover: ->
		# if @__updatePopoverInterval
		# 	CUI.clearTimeout(@__updatePopoverInterval)
		# 	@__updatePopoverInterval = null
		if @__popover
			@__popover.destroy()
			delete(@__popover)
		@


	updateDateTimePicker: ->

		@setMomentFromInput()
		# if @__current_moment.__now
		# 	@__updatePopoverInterval = CUI.setTimeout =>
		# 		@updateDateTimePicker()
		# 		@__updatePopoverInterval = null
		# 	,
		# 		1000*30 # update the popover every 30 seconds

		console.debug "updating popover...", @__input_format

		@drawDate()
		# @drawHourMinute()
		@setClock()
		@setDigiClock()
		@setPrintClock()
		# @pop.position()
		@

	destroy: ->
		# console.debug "destroying popover"
		@closePopover()
		super()

	setClock: (mom = @__current_moment) ->
		hour = mom.hour()
		minute = mom.minute()
		second = mom.second()
		millisecond = 0 # mom.millisecond()

		seconds = second + millisecond / 1000
		minutes = minute + seconds / 60
		hours = (hour%12) + minutes / 60

		CUI.dom.setStyleOne(@__hour, "transform", "rotate(" + hours * 30 + "deg)")
		CUI.dom.setStyleOne(@__minute, "transform", "rotate(" + minutes * 6 + "deg)")
		CUI.dom.setStyleOne(@__second, "transform", "rotate(" + seconds * 6 + "deg)")


	setDigiClock: (mom = @__current_moment) ->
		f = @__input_format.digi_clock
		console.debug "setDigiClock", f, mom, mom.format(f)
		if f
			@__digiDisplay.display(mom.format(f))
		@

	setPrintClock: (mom = @__current_moment) ->
		if not @__input_format.timezone_display
			return @

		mom_tz = mom.clone()
		mom_tz.tz(CUI.tz_data.tz)
		# console.debug @__input_format.timezone_display, mom_tz.format(@__input_format.timezone_display)
		CUI.dom.empty(@__timezone_display)
		CUI.dom.append(@__timezone_display, mom_tz.format(@__input_format.timezone_display))

	setTimezone: ->


	UNUSEDgetTimezoneData: ->
		if @__tz_data
			return CUI.resolvedPromise()

		$.get("#{CUI.getPathToScript()}/moment-timezone-meta.json")
		.done (tz_data) =>
			names = []
			by_name = {}

			for tz in tz_data
				tz.geo = tz.lat+"/"+tz.long
				# tz.print_name = tz.name.split("/").slice(-1)[0]
				tz.print_name = tz.name
				names.push(tz.print_name)
				by_name[tz.print_name] = tz

			names.sort()

			@__tz_data = []
			for n in names
				@__tz_data.push(by_name[n])

			# console.debug "timezone data loaded", @__tz_data

	getTimezoneOpts: ->
		if @__current_moment
			mom = @__current_moment.clone()

		opts = []
		for tz, idx in @__tz_data
			if not mom and tz.name != CUI.DateTimeFormats["de-DE"].timezone
				continue

			if mom
				span = CUI.dom.span("cui-timezone-offset").setAttribute("title", tz.geo)
				span.textContent = mom.tz(tz.name).format("zZ")
				span
			else
				span = null

			opts.push
				text: tz.print_name
				right: span
				value: tz.name
		opts

	# s: string to parse
	# formats: format to check
	# use_formats: formats which are used to call our "initFormat", if format
	#              matched is not among them, init to the first check format.
	#              these formats are the "allowed" formats, this is used in __checkInput

	parse: (stringValue, formats = @__input_formats, use_formats = formats) ->
		if not (stringValue?.trim?().length > 0)
			return moment.invalid()

		for format in formats

			mom = @__parseFormat(format, stringValue)
			if mom
				if format in use_formats
					@__input_format = @initFormat(format)
				else
					@__input_format = @initFormat(@__default_format)
				mom.locale(moment.locale())

				if mom.year() > @_max_year # Year must not be greater than max year.
					return moment.invalid()

				return mom

		if not formats.some((format) -> format.support_bc)
			return moment.invalid()

		# Moment support not all BC dates, we get here
		# if the year is below that, or ends with a supported
		# appendix like "v. Chr."

		# lets see if the date is below zero
		checkBC = false
		hasBCAppendix = false
		if stringValue.startsWith("-")
			checkBC = true
			stringValue = stringValue.substring(1)
		else
			us = stringValue.toLocaleUpperCase()
			for appendix in CUI.DateTime.defaults.bc_appendix
				ua = appendix.toLocaleUpperCase()
				if us.endsWith(" "+ua)
					stringValue = stringValue.substring(0, stringValue.length - ua.length).trim()
					hasBCAppendix = checkBC = true
					break

		if not checkBC
			return moment.invalid()

		# set bc to the value
		m = stringValue.match(/^[0-9]+$/)
		if not m
			return moment.invalid()

		# fake a moment
		mom = moment()
		mom.bc = parseInt(stringValue)
		if hasBCAppendix # If it has BC appendix, means that the number value of the year is one less.
			mom.bc--

		if mom.bc < 10
			mom.bc = "000"+mom.bc
		else if mom.bc < 100
			mom.bc = "00"+mom.bc
		else if mom.bc < 1000
			mom.bc = "0"+mom.bc
		else
			mom.bc = ""+mom.bc

		return mom


	# like parse, but it used all known input formats
	# to recognize the value
	parseValue: (value, output_format = null) ->
		input_formats = @__input_formats.slice(0)
		for format in @__input_formats_known
			CUI.util.pushOntoArray(format, input_formats)
		mom = @parse(value, input_formats, @__input_formats)
		if not output_format
			return mom

		if not mom.isValid()
			return null

		if mom.bc
			return "-"+mom.bc
		else
			return mom.format(@__input_format[output_format])

	__parseFormat: (f, s) ->
		for k in CUI.DateTime.formatTypes
			CUI.util.assert(f[k], "CUI.DateTime.__parseFormat", ".#{k} must be set", format: f)
			mom = moment(s, f[k], true) # true the input format
			if mom.isValid()
				return mom

		for p in f.parse
			mom = moment(s, p, true)
			if mom.isValid()
				return mom

		return

	setMomentFromInput: ->
		inp = @__input.value.trim()
		if inp.length > 0
			@__current_moment = @parse(inp)

		if inp == "" or not @__current_moment.isValid()
			@__current_moment = moment()
			@__current_moment.__now = true
			@__input_format = @initFormat(@__default_format)

		return

	setInputFromMoment: ->
		@__clearOverwriteMonthAndYear()
		# @__input.value = @__current_moment.format(@__input_format.input)
		# console.error "stored value:", @__input.val()
		# @storeValue(@__input.val())
		@setValue(@__current_moment.format(@__input_format.input), no_trigger: false)
		@

	__clearOverwriteMonthAndYear: ->
		@__overwrite_month = null
		@__overwrite_year = null

	drawDate: (_mom) ->
		if not _mom
			mom = @__current_moment.clone()
			mom.bc = @__current_moment.bc
		else
			mom = _mom

		@updateCalendar(mom, false)

	updateCalendar: (mom, update_current_moment = true) ->
		CUI.dom.empty(@__calendar)

		CUI.dom.append(@__calendar, @getDateTimeDrawer(mom))
		CUI.dom.append(@__calendar, @drawMonthTable(mom))
		CUI.dom.append(@__calendar, @drawYearMonthsSelect(mom))

		if update_current_moment
			@__current_moment = mom.clone()
			@__current_moment.bc = mom.bc
			@setInputFromMoment()

		console.info("CUI.DateTime.updateCalendar:", @__current_moment.format(@__input_format.input))

		@markDay()
		@


	getDateTimeDrawer: (mom) ->

		am_pm = @__input_formats[0].clock_am_pm

		data =
			month: mom.month()
			year: mom.year()
			date: mom.date()
			hour: null
			minute: null
			second: null
			am_pm: null

		if @__input_format.clock
			data.hour = mom.hour()
			data.minute = mom.minute()
			data.second = mom.second()

			if am_pm
				data.am_pm = Math.floor(data.hour / 12)*12
				data.hour = data.hour%12

		pad0 = (n) ->
			if n < 10
				"0"+n
			else
				""+n

		date_title = new CUI.Label(
			text: @__locale_format.tab_date
			class: "cui-select-date-title"
		)

		date_sel = new CUI.Select(
			name: "date"
			menu_class: "cui-date-time--select-menu"
			data: data
			group: "date"
			onDataChanged: =>
				@updateCalendar(mom.date(data.date))
			options: =>
				opts = []
				for day in [1..mom.daysInMonth()]
					opts.push
						text: pad0(day)
						value: day

				opts
		).start()

		month_sel = new CUI.Select(
			name: "month"
			menu_class: "cui-date-time--select-menu"
			data: data
			group: "date"
			onDataChanged: =>
				@updateCalendar(mom.month(data.month))
			options: =>
				opts = []
				for month in [0..11]
					opts.push
						text: pad0(month+1)
						value: month

				opts
		).start()

		year_sel = new CUI.Select(
			name: "year"
			menu_class: "cui-date-time--select-menu"
			data: data
			group: "date"
			onDataChanged: =>
				@updateCalendar(mom.year(data.year))
			options: =>
				options = []
				minYear = data.year - 20
				if minYear < @_min_year
					minYear = @_min_year

				for year in [minYear..data.year + 20]
					options.push
						text: "#{year}"
						value: year

				options
		).start()

		if @__input_formats[0].clock

			if @__input_format_no_time
				emtpy_clock_opts = [
					text: ''
					value: null
				]
			else
				emtpy_clock_opts = []

			time_title = new CUI.Label(
				text: @__locale_format.tab_time
				class: "cui-select-time-title"
			)				

			hour_sel = new CUI.Select(
				name: "hour"
				menu_class: "cui-date-time--select-menu"
				data: data
				group: "time"
				onDataChanged: (_data) =>
					if _data.hour == null
						@setInputFormat(false)
						@updateCalendar(mom)
					else
						@setInputFormat(true)
						if am_pm
							@updateCalendar(mom.hour(data.hour+data.am_pm))
						else
							@updateCalendar(mom.hour(data.hour))
					@__popover.position()
				options: =>
					opts = emtpy_clock_opts.slice(0)
					if am_pm
						for hour in [1..12]
							opts.push
								text: pad0(hour)
								value: hour%12
					else
						for hour in [0..23]
							opts.push
								text: pad0(hour)
								value: hour
					opts
			).start()

			# minute_colon = new CUI.Label(text: ":")

			minute_sel = new CUI.Select(
				class: "cui-date-time-60-select"
				name: "minute"
				menu_class: "cui-date-time--select-menu"
				group: "time"
				data: data
				onDataChanged: (_data) =>
					if _data.minute == null
						@setInputFormat(false)
						@updateCalendar(mom)
					else
						@setInputFormat(true)
						@updateCalendar(mom.minute(data.minute))
					@__popover.position()
				options: =>

					opts = emtpy_clock_opts.slice(0)
					for minute in [0..59]
						opts.push
							text: pad0(minute)
							value: minute

					opts
			).start()

			if am_pm
				am_pm_sel = new CUI.Select(
					class: "cui-date-time-am-pm-select"
					name: "am_pm"
					group: "time"
					data: data
					onDataChanged: (_data) =>
						if _data.am_pm == null
							@setInputFormat(false)
							@updateCalendar(mom)
						else
							@setInputFormat(true)
							@updateCalendar(mom.hour(data.hour+data.am_pm))
						@__popover.position()

					options: =>
						opts = emtpy_clock_opts.slice(0)
						for am_pm in ["AM", "PM"]
							opts.push
								text: am_pm
								value: if am_pm == "AM" then 0 else 12 # offset in hours
						opts
				).start()

			# second_colon = new CUI.Label(text: ":")

			# second_sel = new CUI.Select(
			# 	class: "cui-date-time-60-select"
			# 	name: "second"
			# 	data: data
			# 	onDataChanged: =>
			# 		@updateCalendar(mom.second(data.second))
			# 	options: =>
			# 		opts = []
			# 		for second in [0..59]
			# 			opts.push
			# 				text: pad0(second)
			# 				value: second

			# 		opts
			# ).start()

		new CUI.Buttonbar(
			buttons: [	
				date_title			
				date_sel
				month_sel
				year_sel
				time_title
				hour_sel
				# minute_colon
				minute_sel
				am_pm_sel
				# second_colon
				# second_sel
			]
		).DOM


	drawYearMonthsSelect: (mom) ->

		year = null

		updateCalendar = =>
			@updateCalendar(mom.year(year))

		data =
			month: mom.month()
			year: mom.year()

		month_opts = []
		for m, idx in moment.months()
			month_opts.push
				text: m
				value: idx

		now_year = moment().year()

		month_label_max_chars = 0

		for opt in month_opts
			if opt.text?.length > month_label_max_chars
				month_label_max_chars = opt.text?.length

		month_label = new CUI.Label
			text: month_opts[data.month].text

		month_label.setTextMaxChars(month_label_max_chars)

		##### HEADER includes YEAR and MONTH
		header_year_month = new CUI.HorizontalLayout
			maximize_vertical: false
			maximize_horizontal: true
			class: "cui-date-time-footer"
			left:
				content: new CUI.Buttonbar
					class: "cui-date-time-header-month"
					buttons:
						[
							icon: "left"
							onClick: (ev) =>
								if mom.clone().subtract(1, "months").year() < @_min_year
									return

								mom.subtract(1, "months")
								@drawDate(mom)
						,
							month_label
							# new CUI.Select(
							# 	attr:
							# 		cursor: "month"
							# 	class: "cui-date-time-month-select"
							# 	data: data
							# 	name: "month"
							# 	onShow: =>
							# 		@setCursor("month")
							# 	onHide: =>
							# 		@setCursor("month")
							# 	mark_changed: false
							# 	onDataChanged: (_data, element, ev) =>
							# 		@updateCalendar(mom.month(data.month))
							# 	options: month_opts

							# ).start()
						,
							icon: "right"
							onClick: (ev) =>
								if mom.clone().add(1, "months").year() > @_max_year
									return

								mom.add(1, "months")
								@drawDate(mom)
						]
			right:
				content: new CUI.Buttonbar
					class: "cui-date-time-header-year"
					buttons: [
						icon: "left"
						group: "year"
						onClick: =>
							if data.year - 1 < @_min_year
								return

							mom.subtract(1, "years")
							@drawDate(mom)
					,
						new CUI.NumberInput(
							attr:
								cursor: "year"
							max: @_max_year
							min: @_min_year
							placeholder: ""+now_year
							data: data
							name: "year"
							group: "year"
							onDataChanged: (data) =>
								if CUI.util.isEmpty(data.year)
									year = now_year
								else
									year = data.year
								CUI.scheduleCallback(ms: 500, call: updateCalendar)
						).start()
					,
						icon: "right"
						group: "year"
						onClick: =>
							if data.year + 1 > @_max_year
								return
							mom.add(1, "years")
							@drawDate(mom)
					]

		header_year_month.DOM


	drawMonthTable: (_mom) ->
		month = _mom.month()
		year = _mom.year()

		# set first day of month as start
		mom = moment([
			year
			month
			1
			_mom.hour()
			_mom.minute()
			_mom.second()
			0
		]) # .utc()


		month_table = CUI.dom.table("cui-date-time-date")

		CUI.Events.listen
			node: month_table
			type: "click"
			call: (ev) =>
				ev.stopPropagation()
				target = ev.getTarget()
				# console.debug "click on date table", ev.getTarget()
				if CUI.dom.closest(target, ".cui-date-time-day")
					data = CUI.dom.data(CUI.dom.closest(target, "td,.cui-td"))

					@__input_format = @initFormat(@__default_format)
					# order here is important, we need to set the month
					# before we set the date!
					@__current_moment.year(data.year)
					@__current_moment.month(data.month)
					@__current_moment.date(data.date)

					@updateCalendar(@__current_moment)
					if @__input_formats[0].clock
						@__popover.position()
					else
						@closePopover()
				return

		# Wk, Mo, Tu, We, Th...
		tr = CUI.dom.tr("cui-date-time-month-header")
		CUI.dom.append(month_table, tr)

		td_func = CUI.dom.th

		tabWeekDiv = CUI.dom.div("cui-date-time-dow")
		tabWeekDiv.textContent = @__locale_format.tab_week
		CUI.dom.append(tr, CUI.dom.append(td_func("cui-date-time-week-title"), tabWeekDiv))
		for dow in [@start_day..@start_day+6]
			weekday = moment.weekdaysMin(dow%7)
			day_div = CUI.dom.div("cui-date-time-dow")
			day_div.textContent = weekday
			CUI.dom.addClass(day_div, "cui-date-time-day-"+weekday.toLowerCase())
			CUI.dom.append(tr, CUI.dom.append(td_func(), day_div))

		# Weeks
		mom.subtract((mom.day()-@start_day+7)%7, "days")
		dow = @start_day
		weeks = 0
		now = moment()
		loop
			curr_y = mom.year()
			curr_m = mom.month()
			day_no = mom.date()
			if (dow-@start_day)%7 == 0
				if weeks ==6
					# if ((curr_m > m and date.getUTCFullYear() == year) or date.getUTCFullYear() > year)
					break
				tr = CUI.dom.tr()
				CUI.dom.append(month_table, tr)
				week_no = mom.week() #@start_day==0)
				CUI.dom.append(tr, CUI.dom.append(CUI.dom.td("cui-date-time-week"), CUI.dom.text(week_no)))
				weeks++

			div_type = CUI.dom.td

			day_span = CUI.dom.span()
			day_span.textContent = day_no
			day_div = div_type("cui-date-time-day", cursor: "day", datestr: [curr_y, curr_m, day_no].join("-"))
			CUI.dom.append(day_div, day_span)

			if curr_m < month
				CUI.dom.addClass(day_div, "cui-date-time-previous-month")
			else if curr_m > month
				CUI.dom.addClass(day_div, "cui-date-time-next-month")
			else
				CUI.dom.addClass(day_div, "cui-date-time-same-month")
				if year == now.year() and month == now.month() and day_no == now.date()
					CUI.dom.addClass(day_div, "cui-date-time-now")

			CUI.dom.addClass(day_div, "cui-date-time-day-"+mom.format("dd").toLowerCase())

			td = day_div
			CUI.dom.append(tr, td)

			CUI.dom.data(td,
				date: day_no
				month: curr_m
				year: curr_y
			)

			mom.add(1, "days")
			dow++

		month_table

	markDay: ->

		for el in CUI.dom.matchSelector(@__dateTimeTmpl.DOM, ".cui-date-time-calendar .cui-date-time-selected")
			CUI.dom.removeClass(el, "cui-date-time-selected")

		# console.debug "markDay", @__current_moment, @__current_moment.__now
		if @__current_moment.__now
			return

		datestr = [
			@__current_moment.year()
			@__current_moment.month()
			@__current_moment.date()
		].join("-")

		# console.debug "markDay", datestr
		for el in CUI.dom.matchSelector(@__calendar, "[datestr=\"#{datestr}\"]")
			CUI.dom.addClass(el, "cui-date-time-selected")
		return


	# drawHourMinute: ->

	# 	if @__gridTable
	# 		@markTime()
	# 		return

	# 	@__gridTable = CUI.dom.table("cui-date-time-day-grid")
	# 	@__hour_minute.empty().append(@__gridTable)

	# 	CUI.Events.listen
	# 		node: @__hour_minute
	# 		type: "click"
	# 		call: (ev) =>
	# 			if not @__gridTable
	# 				return

	# 			ev.stopPropagation()
	# 			$target = $(ev.getTarget())
	# 			# console.debug "clicked on ", $target
	# 			if $target.closest(".cui-date-time-grid-hour").length
	# 				hour = DOM.data($target.closest("td,.cui-td")[0], "hour")
	# 				if @__input_formats[0].clock_am_pm
	# 					current_hour = @__current_moment.hour()
	# 					if current_hour < 12 # AM
	# 						@__current_moment.hour(hour%12)
	# 					else
	# 						@__current_moment.hour(hour%12+12)
	# 				else
	# 					@__current_moment.hour(hour)
	# 				@__current_moment.second(0)
	# 				if @__current_moment.minute() % 5 != 0
	# 					@__current_moment.minute(0)

	# 				if @__input_formats[0].clock_am_pm
	# 					cursor = "am_pm"
	# 				else
	# 					cursor = "minute"

	# 			if $target.closest(".cui-date-time-grid-am-pm").length
	# 				current_hour = @__current_moment.hour()
	# 				am_pm = $target.closest("td,.cui-td").data("am_pm")
	# 				if am_pm == "AM"
	# 					if current_hour >= 12
	# 						@__current_moment.hour(current_hour-12)
	# 				else
	# 					if current_hour < 12
	# 						@__current_moment.hour(current_hour+12)
	# 				@__current_moment.second(0)
	# 				cursor = "minute"

	# 			if $target.closest(".cui-date-time-grid-minute").length
	# 				@__current_moment.minute(DOM.data($target.closest("td,.cui-td")[0], "minute"))
	# 				@__current_moment.second(0)
	# 				cursor = "blur"

	# 			delete(@__current_moment.__now)
	# 			@markTime()
	# 			@setInputFromMoment()

	# 			if cursor == "blur"
	# 				@closePopover()
	# 			else
	# 				@setCursor(cursor)

	# 			return

	# 	#CUI.dom.tr().appendTo(table).append(
	# 	#	CUI.dom.td("cui-date-time-hour-minute-label", colspan: 6).append(CUI.dom.text("Hour"))
	# 	#)
	# 	if not @__input_formats[0].clock_am_pm
	# 		for hour in [0..23]
	# 			if hour % 6 == 0
	# 				tr = CUI.dom.tr("cui-date-time-grid-hour-row").appendTo(@__gridTable)
	# 			tr.append(
	# 				td = CUI.dom.td("cui-date-time-grid-hour")
	# 				.setAttribute("hour", hour)
	# 				.append(CUI.dom.text(hour))
	# 			)
	# 			DOM.data(td[0], "hour", hour)
	# 		tr.addClass("cui-date-time-grid-row-last")
	# 	else
	# 		for hour in [1..12]
	# 			if (hour-1) % 6 == 0
	# 				tr = CUI.dom.tr("cui-date-time-grid-hour-row").appendTo(@__gridTable)
	# 			tr.append(
	# 				td = CUI.dom.td("cui-date-time-grid-hour")
	# 				.setAttribute("hour", hour)
	# 				.append(CUI.dom.text(hour))
	# 			)
	# 			DOM.data(td[0], "hour", hour)
	# 		tr.addClass("cui-date-time-grid-row-last")
	# 		# ----------------------
	# 		tr = CUI.dom.tr("cui-date-time-grid-am-pm-row").appendTo(@__gridTable)
	# 		for am_pm in ["AM","PM"]
	# 			tr.append(
	# 				td = CUI.dom.td("cui-date-time-grid-am-pm")
	# 				.setAttribute("am_pm", am_pm)
	# 				.append(CUI.dom.text(am_pm))
	# 			)
	# 			DOM.data(td[0], "am_pm", am_pm)
	# 		tr.append(CUI.dom.td("",colspan:4))

	# 		tr.addClass("cui-date-time-grid-row-last")

	# 	#CUI.dom.tr().appendTo(table).append(
	# 	#	CUI.dom.td("cui-date-time-hour-minute-label", colspan: 6).append(CUI.dom.text("Minute"))
	# 	#)

	# 	for minute in [0..59] by 5
	# 		if minute % 6 == 0
	# 			tr = CUI.dom.tr("cui-date-time-grid-minute-row").appendTo(@__gridTable)
	# 		if minute < 10
	# 			_minute = ":0"+minute
	# 		else
	# 			_minute = ":"+minute
	# 		tr.append(
	# 			td = CUI.dom.td("cui-date-time-grid-minute")
	# 			.setAttribute("minute", minute)
	# 			.append(CUI.dom.text(_minute))
	# 		)

	# 		DOM.data(td[0], "minute", minute)

	# 	tr.addClass("cui-date-time-grid-minute-row-last")
	# 	@markTime()
	# 	return


	# markTime: ->
	# 	@__dateTimeTmpl.DOM.find(".cui-date-time-day-grid .cui-date-time-selected").removeClass("cui-date-time-selected")

	# 	for k in ["hour", "minute"]
	# 		if @__current_moment.__now
	# 			continue

	# 		units = @__current_moment[k]()
	# 		if k == "hour" and @__input_formats[0].clock_am_pm
	# 			units = (units+11)%12+1 # convert hours in visible hour format

	# 		if k == "minute"
	# 			units = units - (units % 5)

	# 		@__gridTable.find("[#{k}=\"#{units}\"]").addClass("cui-date-time-selected")


	# 	if @__input_formats[0].clock_am_pm
	# 		for _c in @__gridTable.find("[am_pm]")
	# 			c = _c
	# 			if @__current_moment.__now
	# 				continue

	# 			if @__current_moment.hour() < 12
	# 				if c.getAttribute("am_pm") == "AM"
	# 					c.addClass("cui-date-time-selected")
	# 			else
	# 				if c.getAttribute("am_pm") == "PM"
	# 					c.addClass("cui-date-time-selected")
	# 	return

	# Keys when try parsing
	@formatTypes: ["store", "input", "display", "display_short"]

	@setLocale: (locale) ->
		CUI.util.assert(CUI.DateTimeFormats[locale], "CUI.DateTime.setLocale", "Locale #{locale} unknown", DateTimeFormats: CUI.DateTimeFormats)
		CUI.DateTime.__locale = locale

	@getLocale: ->
		if CUI.DateTime.__locale
			locale = CUI.DateTime.__locale
		else
			for locale of CUI.DateTimeFormats
				break
		return locale

	# format the date_str
	# output_format "display_short", "display", "store", "input"
	# output_type "date_time", "date", "date_time_secons", "year_month",v "year"
	@format: (datestr_or_moment, output_format, output_type, parseZone = false) ->
		dt = new CUI.DateTime()
		str = dt.format(datestr_or_moment, output_format, output_type, parseZone)
		# console.debug "DateTime.format", date, type, output_type, DateTime.__locale, str
		str

	# limit output to the given types
	# the library is very awkward here...
	@formatWithInputTypes: (datestr, output_types, output_format) ->
		if not datestr
			return null

		dt = new CUI.DateTime(input_types: output_types)
		mom = dt.parseValue(datestr)
		if not mom.isValid()
			return null

		dt.format(mom, output_format)

	@display: (datestr_or_moment, opts={}) ->
		if not opts.hasOwnProperty("input_types")
			opts.input_types = null

		dt = new CUI.DateTime(opts)
		mom = dt.parseValue(datestr_or_moment)

		if not mom.isValid()
			return null

		@formatMomentWithBc(mom, dt.getCurrentFormatDisplay())

	@formatMoment: (mom, format, parseZone) ->
		if mom.bc
			return "-"+mom.bc

		if parseZone and mom.year() > 0
			mom.parseZone() # Only parseZone if necessary, in case it is wanted to keep the timezone.

		return mom.format(format)

	# BC appendix always adds one year. Therefore year 0 is 1 BC.
	@formatMomentWithBc: (mom, format) ->
		if mom.year() == 0
			return "1 #{CUI.DateTime.defaults.bc_appendix[0]}"

		if mom.bc
			bc = parseInt(mom.bc) + 1
			return "#{(bc)} #{CUI.DateTime.defaults.bc_appendix[0]}"

		if mom.year() > 0
			v = mom.format(format)
			# remove the "+" and all possible zeros.
			replace = "^\\+?0*#{mom.year()}";
			regexp = new RegExp(replace);
			return v.replace(regexp, ""+mom.year())

		mom.subtract(1, "year")
		v = mom.format(format) + " " + CUI.DateTime.defaults.bc_appendix[0]
		# remove the "-" and all possible zeros.
		replace = "^\\-0*#{-1 * mom.year()}";
		regexp = new RegExp(replace);
		return v.replace(regexp, ""+(-1 * mom.year()))

	@toMoment: (datestr) ->
		if CUI.util.isEmpty(datestr)
			return null
		dt = new CUI.DateTime(input_types: null)
		dt.parse(datestr)

	@stringToDateRange: (string, locale) ->
		return CUI.DateTimeRangeGrammar.stringToDateRange(string, locale)

	@dateRangeToString: (from, to, locale) ->
		return CUI.DateTimeRangeGrammar.dateRangeToString(from, to, locale)