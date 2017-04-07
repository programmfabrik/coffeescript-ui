###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

CUI.tz_data = {}

class CUI.DateTime extends Input
	constructor: (@opts={}) ->
		super(@opts)
		@init()

	@defaults:
		button_tooltip: "Open calendar"

	initOpts: ->
		super()

		if DateTime.__locale
			locale = DateTime.__locale
		else
			for locale of DateTimeFormats
				break

		@addOpts
			locale:
				mandatory: true
				default: locale
				check: (v) ->
					CUI.isArray(DateTimeFormats[v]?.formats)
			input_types:
				default: ["date_time"]
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
				default: 2499
				check: "Integer"

		@removeOpt("getValueForDisplay")
		@removeOpt("getValueForInput")
		# @removeOpt("correctValueForInput")
		@removeOpt("checkInput")
		@removeOpt("getInputBlocks")

	init: ->
		@__regexpMatcher = @regexpMatcher()

		@__input_formats_known = DateTimeFormats[@_locale].formats
		@__locale_format = DateTimeFormats[@_locale]

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
				assert(found, "new DateTime", "opts.input_types contains unknown type: #{type}", formats: @__input_formats_known, input_type: @_input_types)
		@initFormat(0)
		return

	initDateTimePicker: ->
		if @__dateTimeTmpl
			return @__dateTimeTmpl

		@__dateTimeTmpl = new Template
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
		# @__timeZone = new Select
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
		new Template
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
		# CUI.debug "setCursor", cursor, @__lastCursor
		switch cursor
			when "hour", "minute", "second", "am_pm"
				title = @__locale_format.tab_time
				DOM.setAttribute(@__dateTimeTmpl.DOM[0], "browser", "time")
				@setDigiClock()
			else
				title = @__locale_format.tab_date
				DOM.setAttribute(@__dateTimeTmpl.DOM[0], "browser", "date")

		@__dateTimeTmpl.replace(new Label(text: title), "header_center")
		@

	initFormat: (idx_or_format) ->
		if isInteger(idx_or_format)
			@__input_format = @__input_formats[idx_or_format]
		else
			@__input_format = idx_or_format

		moment.locale(@__locale_format.moment_locale or @_locale)

		switch @_display_type
			when "short"
				@__input_format.__display = @__input_format.display_short
			else
				@__input_format.__display = @__input_format.display

		@_invalidHint = text: @__input_format.invalid

		for k, v of @__regexpMatcher
			v.match_str = k

		input = @__input_format.input
		rstr = "("+Object.keys(@__regexpMatcher).join("|")+")"
		re = new RegExp(rstr, "g")
		s = input.split("")
		regexp = []
		matcher = []
		last_match_end = 0
		while (match = re.exec(input)) != null
			match_str = match[0]
			match_start = match.index
			regexp.push("("+escapeRegExp(s.slice(last_match_end, match_start).join(""))+")")
			regexp.push("("+@__regexpMatcher[match_str].regexp+")")
			matcher.push(@__regexpMatcher[match_str])

			last_match_end = match_start + match_str.length

		regexp.push("("+escapeRegExp(s.slice(last_match_end).join(""))+")")

		# CUI.debug "regexp found", @__input_format.regexp, @__input_format.matcher

		@__input_format.regexp = new RegExp("^"+regexp.join("")+"$")
		@__input_format.matcher = matcher

		# CUI.debug "initFormat", @__input_format.input, @__input_format.regexp

		# if @__current_input_format != @__input_format
		# 	for k in ["digi_clock"]
		# 		if @__current_input_format?[k] != @__input_format[k]
		# 			if @__input_format[k]
		# 				@__input_format["__#{k}"] = @__input_format[k]
		# 			else
		# 				@__input_format["__#{k}"] = null
		# 			@__dateTimeTmpl.replace(@__input_format["__#{k}"], k)

		# 	@popoverSetClasses()
		# 	@pop?.position()
		# @__current_input_format = @__input_format
		@

	getTemplateKeyForRender: ->
		"center"

	render: ->
		super()
		if isEmpty(@_placeholder)
			@__input.prop("placeholder", @__input_formats[0].text)

		btn = new CUI.defaults.class.Button
			icon: "calendar"
			tooltip: text: CUI.DateTime.defaults.button_tooltip
			onClick: =>
				@openPopover(btn)

		@replace(btn, "right")
		# @append(@__status = $div("cui-date-time-status"), "center")

	format: (s, type="display", output_type=null) ->
		assert(type in DateTime.formatTypes, "DateTime.format", "type must be on of \"#{DateTime.formatTypes.join(',')}\".", parm1: s, type: type)

		if isEmpty(s)
			return null

		if moment.isMoment(s)
			mom = s
		else
			mom = @parse(s, @__input_formats_known)
			if mom.isValid() and isNull(output_type)
				output_type = @getCurrentFormat().type

		if not mom.isValid()
			formats_tried = []
			for format in @__input_formats_known
				for k in DateTime.formatTypes
					formats_tried.push(format[k])

			CUI.warn(
				"DateTime.format: Moment is invalid:"
				s
				"Tried formats:"
				formats_tried
			)
			return null

		output_format = null
		for f in @__input_formats_known
			if f.type == output_type
				output_format = f
				break

		assert(output_format, "DateTime.format", "output_type must be in known formats", formats: @__input_formats_known, output_type: output_type)

		# CUI.debug "display format", s, output_type, dump(output_format), output_format[type], type

		mom.format(output_format[type])

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

	incAMPM: (mom, diff) ->
		current_hour = mom.hour()
		if current_hour < 12 # AM
			# set PM
			mom.add(12,"hour")
		else
			mom.subtract(12,"hour")

	initValue: ->
		super()
		value = @getValue()
		corrected_value = @parseValue(value, "store")
		if corrected_value and corrected_value != value
			CUI.warn("DateTime.initValue: Corrected value in data:", corrected_value, "Original value:", value)
			@__data[@_name] = corrected_value
		@

	getValueForDisplay: ->
		value = @getValue()?.trim?()

		if isEmpty(value)
			return ""

		mom = @parse(value)

		if mom.isValid()
			mom.format(@getCurrentFormatDisplay())
		else
			value

	getValueForInput: (v = @getValue()) ->
		if isEmpty(v?.trim())
			return ""

		mom = @parse(v)
		if mom.isValid()
			return mom.format(@__input_format.input)
		else
			return v

	__checkInput: (value) ->
		if not isEmpty(value?.trim())
			mom = @parse(value)
			if not mom.isValid()
				return false
		else
			@initFormat(0)
		return true

	__getInputBlocks: (v) ->
		CUI.debug "getInputBlocks", v, @__input_format.regexp
		match = v.match(@__input_format.regexp)
		if not match
			return false
		blocks = []
		pos = 0
		for m, idx in match
			if idx == 0
				continue

			if idx % 2 == 0
				blocks.push new DateTimeInputBlock
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
			value = mom.format(@__input_format.store)
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

		# CUI.debug digits
		@__digiDisplay = new DigiDisplay(digits: digits)


	openPopover: (btn) ->
		@initDateTimePicker()
		@__popover = new Popover
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
			@__gridTable = null
			delete(@__popover)
		@


	# set classes for clock visibility
	popoverSetClasses: ->

		if @__input_format.clock_seconds
			@__dateTimeTmpl.removeClass("hide-clock-seconds")
		else
			@__dateTimeTmpl.addClass("hide-clock-seconds")

		if @__input_format.clock
			@__dateTimeTmpl.removeClass("hide-clock")
		else
			@__dateTimeTmpl.addClass("hide-clock")

		# if @__input_format.timezone_display
		# 	@__dateTimeTmpl.removeClass("hide-timezone-display")
		# else
		# 	@__dateTimeTmpl.addClass("hide-timezone-display")

		@


	updateDateTimePicker: ->

		@setMomentFromInput()
		# if @__current_moment.__now
		# 	@__updatePopoverInterval = CUI.setTimeout =>
		# 		@updateDateTimePicker()
		# 		@__updatePopoverInterval = null
		# 	,
		# 		1000*30 # update the popover every 30 seconds

		CUI.debug "updating popover...", @__input_format

		@popoverSetClasses()
		@drawDate()
		# @drawHourMinute()
		@setClock()
		@setDigiClock()
		@setPrintClock()
		# @pop.position()
		@

	destroy: ->
		# CUI.debug "destroying popover"
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

		@__hour.css("transform", "rotate(" + hours * 30 + "deg)")
		@__minute.css("transform", "rotate(" + minutes * 6 + "deg)")
		@__second.css("transform", "rotate(" + seconds * 6 + "deg)")


	setDigiClock: (mom = @__current_moment) ->
		f = @__input_format.digi_clock
		CUI.debug "setDigiClock", f, mom, mom.format(f)
		if f
			@__digiDisplay.display(mom.format(f))
		@

	setPrintClock: (mom = @__current_moment) ->
		if not @__input_format.timezone_display
			return @

		mom_tz = mom.clone()
		mom_tz.tz(CUI.tz_data.tz)
		# CUI.debug @__input_format.timezone_display, mom_tz.format(@__input_format.timezone_display)
		@__timezone_display.empty().append(mom_tz.format(@__input_format.timezone_display))

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

			# CUI.debug "timezone data loaded", @__tz_data

	getTimezoneOpts: ->
		if @__current_moment
			mom = @__current_moment.clone()

		opts = []
		for tz, idx in @__tz_data
			if not mom and tz.name != DateTimeFormats["de-DE"].timezone
				continue

			opts.push
				text: tz.print_name
				right: if mom then $span("cui-timezone-offset").prop("title", tz.geo).text(mom.tz(tz.name).format("zZ")) else null
				value: tz.name
		opts

	# s: string to parse
	# formats: format to check
	# use_formats: formats which are used to call our "initFormat", if format
	#              matched is not among them, init to the first check format.
	#              these formats are the "allowed" formats, this is used in __checkInput

	parse: (s, formats = @__input_formats, use_formats = formats) ->
		if not (s?.trim?().length > 0)
			return moment.invalid()

		for format in formats
			mom = @__parseFormat(format, s)
			if mom
				if format in use_formats
					@initFormat(format)
				else
					@initFormat(0)
				mom.locale(moment.locale())
				# CUI.debug "parsing ok", mom, f, moment.locale()
				return mom

		return moment.invalid()

	# like parse, but it used all known input formats
	# to recognize the value
	parseValue: (value, output_format = null) ->
		input_formats = @__input_formats.slice(0)
		for format in @__input_formats_known
			pushOntoArray(format, input_formats)
		mom = @parse(value, input_formats, @__input_formats)
		if not output_format
			return mom

		if mom.isValid()
			mom.format(@__input_format[output_format])
		else
			null

	__parseFormat: (f, s) ->
		for k in DateTime.formatTypes
			assert(f[k], "DateTime.__parseFormat", ".#{k} must be set", format: f)
			mom = moment(s, f[k], true) # true the input format
			if mom.isValid()
				return mom

		for p in f.parse
			mom = moment(s, p, true)
			if mom.isValid()
				return mom

		return


	setMomentFromInput: ->
		inp = @__input0.value.trim()
		if inp.length > 0
			@__current_moment = @parse(inp)

		if inp == "" or not @__current_moment.isValid()
			@__current_moment = moment()
			@__current_moment.__now = true
			@initFormat(0)

		return

	setInputFromMoment: ->
		@__clearOverwriteMonthAndYear()
		# @__input0.value = @__current_moment.format(@__input_format.input)
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
		else
			mom = _mom

		@updateCalendar(mom, false)

	updateCalendar: (mom, update_current_moment = true) ->
		@__calendar.empty()

		if CUI.__ng__
			@__calendar.append(@getDateTimeDrawer(mom))
			@__calendar.append(@drawMonthTable(mom))
			@__calendar.append(@drawYearMonthsSelect(mom))
		else
			@__calendar.append(@drawYearMonthsSelect(mom))
			@__calendar.append(@drawMonthTable(mom))

		if update_current_moment
			@__current_moment = mom.clone()
			@setInputFromMoment()

		console.info("DateTime.updateCalendar:", @__current_moment.format(@__input_format.input))

		@markDay()
		@

	getDateTimeDrawer: (mom) ->

		am_pm = @__input_formats[0].clock_am_pm

		data =
			month: mom.month()
			year: mom.year()
			date: mom.date()
			hour: mom.hour()
			minute: mom.minute()
			second: mom.second()
			am_pm: null

		if am_pm
			data.am_pm = Math.floor(data.hour / 12)*12
			data.hour = data.hour%12

		pad0 = (n) ->
			if n < 10
				"0"+n
			else
				""+n

		date_sel = new Select(
			name: "date"
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

		month_sel = new Select(
			name: "month"
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

		year_sel = new Select(
			name: "year"
			data: data
			group: "date"
			onDataChanged: =>
				@updateCalendar(mom.year(data.year))
			options: =>
				opts = []
				for year in [data.year-20..data.year+20]
					opts.push
						text: ""+year
						value: year

				opts
		).start()

		if @__input_formats[0].clock

			hour_sel = new Select(
				name: "hour"
				data: data
				group: "time"
				onDataChanged: =>
					if am_pm
						@updateCalendar(mom.hour(data.hour+data.am_pm))
					else
						@updateCalendar(mom.hour(data.hour))
				options: =>
					opts = []
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

			# minute_colon = new Label(text: ":")

			minute_sel = new Select(
				class: "cui-date-time-60-select"
				name: "minute"
				group: "time"
				data: data
				onDataChanged: =>
					@updateCalendar(mom.minute(data.minute))
				options: =>

					opts = []
					for minute in [0..59]
						opts.push
							text: pad0(minute)
							value: minute

					opts
			).start()

			if am_pm
				am_pm_sel = new Select(
					class: "cui-date-time-am-pm-select"
					name: "am_pm"
					group: "time"
					data: data
					onDataChanged: =>
						@updateCalendar(mom.hour(data.hour+data.am_pm))
					options: =>
						opts = []
						for am_pm in ["AM", "PM"]
							opts.push
								text: am_pm
								value: if am_pm == "AM" then 0 else 12 # offset in hours
						opts
				).start()

			# second_colon = new Label(text: ":")

			# second_sel = new Select(
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

		new Buttonbar(
			buttons: [
				date_sel
				month_sel
				year_sel
				hour_sel
				# minute_colon
				minute_sel
				am_pm_sel
				# second_colon
				# second_sel
			]
		).DOM


	drawYearMonthsSelect: (mom) ->

		data =
			month: mom.month()
			year: mom.year()

		month_opts = []
		for m, idx in moment.months()
			month_opts.push
				text: m
				value: idx

		now_year = moment().year()

		##### HEADER includes YEAR and MONTH
		header_year_month = new HorizontalLayout
			maximize_vertical: false
			maximize_horizontal: true
			class: "cui-date-time-footer"
			left:
				content: new Buttonbar
					class: "cui-date-time-header-month"
					buttons:
						[
							appearance: if CUI.__ng__ then undefined else "flat"
							size: if CUI.__ng__ then undefined else "mini"
							icon: "left"
							onClick: (ev) =>
								if mom.clone().subtract(1, "months").year() < @_min_year
									return

								mom.subtract(1, "months")
								@drawDate(mom)
						,
							new Label
								text: month_opts[data.month].text
							# new Select(
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
							appearance: if CUI.__ng__ then undefined else "flat"
							size: if CUI.__ng__ then undefined else "mini"
							icon: "right"
							onClick: (ev) =>
								if mom.clone().add(1, "months").year() > @_max_year
									return

								mom.add(1, "months")
								@drawDate(mom)
						]
			right:
				content: new Buttonbar
					class: "cui-date-time-header-year"
					buttons: [
						appearance: if CUI.__ng__ then undefined else "flat"
						size: if CUI.__ng__ then undefined else "mini"
						icon: "left"
						group: if CUI.__ng__ then "year" else null
						onClick: (ev) =>
							if data.year-1 < @_min_year
								return
							mom.subtract(1, "years")
							@drawDate(mom)
					,
						new NumberInput(
							attr:
								cursor: "year"
							max: @_max_year
							min: @_min_year
							placeholder: ""+now_year
							data: data
							name: "year"
							group: if CUI.__ng__ then "year" else null
							onDataChanged: (data) =>
								if isEmpty(data.year)
									year = now_year
								else
									year = data.year
								@updateCalendar(mom.year(year))
						).start()
					,
						appearance: if CUI.__ng__ then undefined else "flat"
						size: if CUI.__ng__ then undefined else "mini"
						icon: "right"
						group: if CUI.__ng__ then "year" else null
						onClick: (ev) =>
							if data.year+1 > @_max_year
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


		month_table = $table("cui-date-time-date")

		Events.listen
			node: month_table
			type: "click"
			call: (ev) =>
				ev.stopPropagation()
				$target = $(ev.getTarget())
				# CUI.debug "click on date table", ev.getTarget()
				if $target.closest(".cui-date-time-day").length
					data = DOM.data($target.closest("td,.cui-td")[0])

					# order here is important, we need to set the month
					# before we set the date!
					@__current_moment.year(data.year)
					@__current_moment.month(data.month)
					@__current_moment.date(data.date)

					@updateCalendar(@__current_moment)
					@closePopover()
				return

		# Wk, Mo, Tu, We, Th...
		tr = $tr("cui-date-time-month-header").appendTo(month_table)

		if CUI.__ng__
			td_func = $th
		else
			td_func = $td

		tr.append(td_func("cui-date-time-week-title").append($div("cui-date-time-dow").text(@__locale_format.tab_week)))
		for dow in [@start_day..@start_day+6]
			weekday = moment.weekdaysMin(dow%7)
			day_div = $div("cui-date-time-dow").text(weekday)
			day_div.addClass("cui-date-time-day-"+weekday.toLowerCase())
			tr.append(td_func().append(day_div))

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
				tr = $tr().appendTo(month_table)
				week_no = mom.week() #@start_day==0)
				tr.append($td("cui-date-time-week").append($text(week_no)))
				weeks++

			if CUI.__ng__
				div_type = $td
			else
				div_type = $div

			day_div = div_type("cui-date-time-day", cursor: "day", datestr: [curr_y, curr_m, day_no].join("-")).text(day_no)

			if curr_m < month
				day_div.addClass("cui-date-time-previous-month")
			else if curr_m > month
				day_div.addClass("cui-date-time-next-month")
			else
				day_div.addClass("cui-date-time-same-month")
				if year == now.year() and month == now.month() and day_no == now.date()
					day_div.addClass("cui-date-time-now")

			day_div.addClass("cui-date-time-day-"+mom.format("dd").toLowerCase())

			if CUI.__ng__
				td = day_div.appendTo(tr)
			else
				td = $td().append(day_div).appendTo(tr)

			DOM.data(td[0],
				date: day_no
				month: curr_m
				year: curr_y
			)

			mom.add(1, "days")
			dow++

		month_table

	markDay: ->

		@__dateTimeTmpl.DOM.find(".cui-date-time-calendar .cui-date-time-selected").removeClass("cui-date-time-selected")
		# CUI.debug "markDay", @__current_moment, @__current_moment.__now
		if @__current_moment.__now
			return

		datestr = [
			@__current_moment.year()
			@__current_moment.month()
			@__current_moment.date()
		].join("-")

		# CUI.debug "markDay", datestr
		@__calendar.find("[datestr=\"#{datestr}\"]").addClass("cui-date-time-selected")
		return


	# drawHourMinute: ->

	# 	if @__gridTable
	# 		@markTime()
	# 		return

	# 	@__gridTable = $table("cui-date-time-day-grid")
	# 	@__hour_minute.empty().append(@__gridTable)

	# 	Events.listen
	# 		node: @__hour_minute
	# 		type: "click"
	# 		call: (ev) =>
	# 			if not @__gridTable
	# 				return

	# 			ev.stopPropagation()
	# 			$target = $(ev.getTarget())
	# 			# CUI.debug "clicked on ", $target
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

	# 	#$tr().appendTo(table).append(
	# 	#	$td("cui-date-time-hour-minute-label", colspan: 6).append($text("Hour"))
	# 	#)
	# 	if not @__input_formats[0].clock_am_pm
	# 		for hour in [0..23]
	# 			if hour % 6 == 0
	# 				tr = $tr("cui-date-time-grid-hour-row").appendTo(@__gridTable)
	# 			tr.append(
	# 				td = $td("cui-date-time-grid-hour")
	# 				.attr("hour", hour)
	# 				.append($text(hour))
	# 			)
	# 			DOM.data(td[0], "hour", hour)
	# 		tr.addClass("cui-date-time-grid-row-last")
	# 	else
	# 		for hour in [1..12]
	# 			if (hour-1) % 6 == 0
	# 				tr = $tr("cui-date-time-grid-hour-row").appendTo(@__gridTable)
	# 			tr.append(
	# 				td = $td("cui-date-time-grid-hour")
	# 				.attr("hour", hour)
	# 				.append($text(hour))
	# 			)
	# 			DOM.data(td[0], "hour", hour)
	# 		tr.addClass("cui-date-time-grid-row-last")
	# 		# ----------------------
	# 		tr = $tr("cui-date-time-grid-am-pm-row").appendTo(@__gridTable)
	# 		for am_pm in ["AM","PM"]
	# 			tr.append(
	# 				td = $td("cui-date-time-grid-am-pm")
	# 				.attr("am_pm", am_pm)
	# 				.append($text(am_pm))
	# 			)
	# 			DOM.data(td[0], "am_pm", am_pm)
	# 		tr.append($td("",colspan:4))

	# 		tr.addClass("cui-date-time-grid-row-last")

	# 	#$tr().appendTo(table).append(
	# 	#	$td("cui-date-time-hour-minute-label", colspan: 6).append($text("Minute"))
	# 	#)

	# 	for minute in [0..59] by 5
	# 		if minute % 6 == 0
	# 			tr = $tr("cui-date-time-grid-minute-row").appendTo(@__gridTable)
	# 		if minute < 10
	# 			_minute = ":0"+minute
	# 		else
	# 			_minute = ":"+minute
	# 		tr.append(
	# 			td = $td("cui-date-time-grid-minute")
	# 			.attr("minute", minute)
	# 			.append($text(_minute))
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
	# 			c = $(_c)
	# 			if @__current_moment.__now
	# 				continue

	# 			if @__current_moment.hour() < 12
	# 				if c.attr("am_pm") == "AM"
	# 					c.addClass("cui-date-time-selected")
	# 			else
	# 				if c.attr("am_pm") == "PM"
	# 					c.addClass("cui-date-time-selected")
	# 	return

	# Keys when try parsing
	@formatTypes: ["store", "input", "display", "display_short"]

	@setLocale: (locale) ->
		assert(DateTimeFormats[locale], "DateTime.setLocale", "Locale #{locale} unknown", DateTimeFormats: DateTimeFormats)
		DateTime.__locale = locale

	# format the date_str
	# input_type "display_short", "display", "store", "input"
	# output_type "date_time", "date", "date_time_secons", "year_month",v "year"
	@format: (datestr_or_moment, type, output_type) ->
		dt = new DateTime()

		str = dt.format(datestr_or_moment, type, output_type)
		# CUI.debug "DateTime.format", date, type, output_type, DateTime.__locale, str
		str

	@display: (datestr_or_moment, opts={}) ->
		if not opts.hasOwnProperty("input_types")
			opts.input_types = null

		dt = new DateTime(opts)
		mom = dt.parseValue(datestr_or_moment)

		if not mom.isValid()
			return null

		return mom.format(dt.getCurrentFormatDisplay())

	@toMoment: (datestr) ->
		if isEmpty(datestr)
			return null
		dt = new DateTime(input_types: null)
		dt.parse(datestr)

DateTime = CUI.DateTime