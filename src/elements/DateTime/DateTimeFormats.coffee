###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

CUI.DateTimeFormats = {}

CUI.DateTimeFormats["de-DE"] =
	timezone: "Europe/Berlin"
	moment_locale: "de-DE"
	tab_date: "Datum"
	tab_time: "Zeit"
	tab_week: "Wo"
	formats: [
		text: "Datum+Zeit"
		support_bc: false
		invalid: "Datum ungültig"
		type: "date_time"
		clock: true
		store: "YYYY-MM-DDTHH:mm:00Z"
		clock_seconds: false
		# digi_clock: "HH:mm"
		input: "DD.MM.YYYY HH:mm"
		display: "dd, DD.MM.YYYY HH:mm"
		display_short: "DD.MM.YYYY HH:mm"
		display_attribute: "date-time"
		display_short_attribute: "date-time-short"
		# timezone_display: "dddd, DD.MM.YYYY HH:mm zZ"
		parse: [
			"YYYY-MM-DD HH:mm:ss"
			"YYYY-MM-DDTHH:mm:ss.SSSZ"
			"YYYY-MM-DDTHH:mm:ssZ"
			"D.M.YYYY HH:mm:ss"
			"DD.M.YYYY HH:mm:ss"
			"D.MM.YYYY HH:mm:ss"
			"D.MM.YY HH:mm:ss"
			"DD.M.YY HH:mm:ss"
			"D.M.YYYY HH:mm"
			"DD.M.YYYY HH:mm"
			"D.MM.YYYY HH:mm"
			"D.MM.YY HH:mm"
			"DD.M.YY HH:mm"
			"M/D/YYYY HH:DD:ss"
			"MM/D/YYYY HH:DD:ss"
			"M/DD/YYYY HH:DD:ss"
			"M/DD/YY HH:DD:ss"
			"MM/D/YY HH:DD:ss"
			"M/D/YYYY HH:DD"
			"MM/D/YYYY HH:DD"
			"M/DD/YYYY HH:DD"
			"M/DD/YY HH:DD"
			"MM/D/YY HH:DD"
		]
	,
		text: "Datum+Zeit+Sekunden"
		support_bc: false
		invalid: "Datum ungültig"
		# input: "YYYY-MM-DD HH:mm:ss"
		type: "date_time_seconds"
		input: "DD.MM.YYYY HH:mm:ss"
		store: "YYYY-MM-DDTHH:mm:ssZ"
		display: "dd, DD.MM.YYYY HH:mm:ss"
		display_short: "DD.MM.YYYY HH:mm:ss"
		display_attribute: "date-time-seconds"
		display_short_attribute: "date-time-seconds-short"
		# timezone_display: "dddd, DD.MM.YYYY HH:mm:ss zZ"
		clock: true
		clock_seconds: true
		# digi_clock: "HH:mm:ss"
		parse: [
			"YYYY-MM-DDTHH:mm:ssZ"
			"YYYY-MM-DD HH:mm:ss"
			"D.M.YYYY HH:mm:ss"
			"DD.M.YYYY HH:mm:ss"
			"D.MM.YYYY HH:mm:ss"
			"D.MM.YY HH:mm:ss"
			"DD.M.YY HH:mm:ss"
			"M/D/YYYY HH:DD:ss"
			"MM/D/YYYY HH:DD:ss"
			"M/DD/YYYY HH:DD:ss"
			"M/DD/YY HH:DD:ss"
			"MM/D/YY HH:DD:ss"
		]
	,
		text: "Datum"
		support_bc: false
		input: "DD.MM.YYYY"
		invalid: "Datum ungültig"
		display: "dd, DD.MM.YYYY"
		display_short: "DD.MM.YYYY"
		display_attribute: "date"
		display_short_attribute: "date-short"
		store: "YYYY-MM-DD"
		type: "date"
		# digi_clock: false
		clock: false
		parse: [
			"D.M.YYYY"
			"D.MM.YYYY"
			"DD.M.YYYY"
			"YYYYMMDD"
			"YYYY-M-D"
			"M/D/YYYY"
			"MM/D/YYYY"
			"M/DD/YYYY"
		]
	,
		text: "Jahr-Monat"
		support_bc: false
		input: "MM.YYYY"
		invalid: "Datum ungültig"
		store: "YYYY-MM"
		display: "MMMM YYYY"
		display_short: "MM.YYYY"
		display_attribute: "year-month"
		display_short_attribute: "year-month-short"
		type: "year_month"
		# digi_clock: false
		clock: false
		parse: [
			"MM YYYY"
			"MM/YYYY"
			"MM.YYYY"
			"M.YYYY"
			"YYYY-M"
			"YYYY-MM"
		]
	,
		text: "Jahr"
		support_bc: true
		input: "Y"
		invalid: "Datum ungültig"
		display: "Y"
		display_short: "Y"
		display_attribute: "year"
		display_short_attribute: "year"
		store: "YYYY"
		type: "year"
		# digi_clock: false
		clock: false
		parse: [
			"Y"
		]
	]

CUI.DateTimeFormats["it-IT"] =
	timezone: "Europe/Berlin"
	moment_locale: "de-DE"
	tab_date: "Datum"
	tab_time: "Zeit"
	tab_week: "Wk"
	formats: [
		text: "Datum+Zeit"
		support_bc: false
		invalid: "Datum ungültig"
		type: "date_time"
		clock: true
		store: "YYYY-MM-DDTHH:mm:00Z"
		clock_seconds: false
		# digi_clock: "HH:mm"
		input: "DD.MM.YYYY HH:mm"
		display: "dd, DD.MM.YYYY HH:mm"
		display_short: "DD.MM.YYYY HH:mm"
		display_attribute: "date-time"
		display_short_attribute: "date-time-short"
		# timezone_display: "dddd, DD.MM.YYYY HH:mm zZ"
		parse: [
			"YYYY-MM-DD HH:mm:ss"
			"YYYY-MM-DDTHH:mm:ss.SSSZ"
			"YYYY-MM-DDTHH:mm:ssZ"
			"D.M.YYYY HH:mm:ss"
			"DD.M.YYYY HH:mm:ss"
			"D.MM.YYYY HH:mm:ss"
			"D.MM.YY HH:mm:ss"
			"DD.M.YY HH:mm:ss"
			"D.M.YYYY HH:mm"
			"DD.M.YYYY HH:mm"
			"D.MM.YYYY HH:mm"
			"D.MM.YY HH:mm"
			"DD.M.YY HH:mm"
		]
	,
		text: "Datum+Zeit+Sekunden"
		support_bc: false
		invalid: "Datum ungültig"
		# input: "YYYY-MM-DD HH:mm:ss"
		type: "date_time_seconds"
		input: "DD.MM.YYYY HH:mm:ss"
		store: "YYYY-MM-DDTHH:mm:ssZ"
		display: "dd, DD.MM.YYYY HH:mm:ss"
		display_short: "DD.MM.YYYY HH:mm:ss"
		display_attribute: "date-time-seconds"
		display_short_attribute: "date-time-seconds-short"
		# timezone_display: "dddd, DD.MM.YYYY HH:mm:ss zZ"
		clock: true
		clock_seconds: true
		# digi_clock: "HH:mm:ss"
		parse: [
			"D.M.YYYY HH:mm:ss"
			"DD.M.YYYY HH:mm:ss"
			"D.MM.YYYY HH:mm:ss"
			"D.MM.YY HH:mm:ss"
			"DD.M.YY HH:mm:ss"
		]
	,
		text: "Datum"
		support_bc: false
		input: "DD.MM.YYYY"
		invalid: "Datum ungültig"
		display: "dd, DD.MM.YYYY"
		display_short: "DD.MM.YYYY"
		display_attribute: "date"
		display_short_attribute: "date-short"
		store: "YYYY-MM-DD"
		type: "date"
		# digi_clock: false
		clock: false
		parse: [
			"D.M.YYYY"
			"D.MM.YYYY"
			"DD.M.YYYY"
			"YYYYMMDD"
			"YYYY-M-D"
		]
	,
		text: "Jahr-Monat"
		support_bc: false
		input: "MM.YYYY"
		invalid: "Datum ungültig"
		store: "YYYY-MM"
		display: "MMMM YYYY"
		display_short: "MM.YYYY"
		display_attribute: "year-month"
		display_short_attribute: "year-month-short"
		type: "year_month"
		# digi_clock: false
		clock: false
		parse: [
			"MM YYYY"
			"MM/YYYY"
			"MM.YYYY"
			"M.YYYY"
			"YYYY-M"
			"YYYY-MM"
		]
	,
		text: "Jahr"
		support_bc: true
		input: "Y"
		invalid: "Datum ungültig"
		display: "Y"
		display_short: "Y"
		display_attribute: "year"
		display_short_attribute: "year"
		store: "YYYY"
		type: "year"
		# digi_clock: false
		clock: false
		parse: [
			"Y"
		]
	]

CUI.DateTimeFormats["es-ES"] =
	timezone: "Europe/Berlin"
	moment_locale: "de-DE"
	tab_date: "Datum"
	tab_time: "Zeit"
	tab_week: "Wk"
	formats: [
		text: "Datum+Zeit"
		support_bc: false
		invalid: "Datum ungültig"
		type: "date_time"
		clock: true
		store: "YYYY-MM-DDTHH:mm:00Z"
		clock_seconds: false
		# digi_clock: "HH:mm"
		input: "DD/MM/YYYY HH:mm"
		display: "dd, DD/MM/YYYY HH:mm"
		display_short: "DD/MM/YYYY HH:mm"
		display_attribute: "date-time"
		display_short_attribute: "date-time-short"
		# timezone_display: "dddd, DD.MM.YYYY HH:mm zZ"
		parse: [
			"YYYY-MM-DD HH:mm:ss"
			"YYYY-MM-DDTHH:mm:ss.SSSZ"
			"YYYY-MM-DDTHH:mm:ssZ"
			"D.M.YYYY HH:mm:ss"
			"DD.M.YYYY HH:mm:ss"
			"D.MM.YYYY HH:mm:ss"
			"D.MM.YY HH:mm:ss"
			"DD.M.YY HH:mm:ss"
			"D.M.YYYY HH:mm"
			"DD.M.YYYY HH:mm"
			"D.MM.YYYY HH:mm"
			"D.MM.YY HH:mm"
			"DD.M.YY HH:mm"
		]
	,
		text: "Datum+Zeit+Sekunden"
		support_bc: false
		invalid: "Datum ungültig"
		# input: "YYYY-MM-DD HH:mm:ss"
		type: "date_time_seconds"
		input: "DD.MM.YYYY HH:mm:ss"
		store: "YYYY-MM-DDTHH:mm:ssZ"
		display: "dd, DD.MM.YYYY HH:mm:ss"
		display_short: "DD.MM.YYYY HH:mm:ss"
		display_attribute: "date-time-seconds"
		display_short_attribute: "date-time-seconds-short"
		# timezone_display: "dddd, DD.MM.YYYY HH:mm:ss zZ"
		clock: true
		clock_seconds: true
		# digi_clock: "HH:mm:ss"
		parse: [
			"D.M.YYYY HH:mm:ss"
			"DD.M.YYYY HH:mm:ss"
			"D.MM.YYYY HH:mm:ss"
			"D.MM.YY HH:mm:ss"
			"DD.M.YY HH:mm:ss"
		]
	,
		text: "Datum"
		support_bc: false
		input: "DD.MM.YYYY"
		invalid: "Datum ungültig"
		display: "dd, DD.MM.YYYY"
		display_short: "DD.MM.YYYY"
		display_attribute: "date"
		display_short_attribute: "date-short"
		store: "YYYY-MM-DD"
		type: "date"
		# digi_clock: false
		clock: false
		parse: [
			"D.M.YYYY"
			"D.MM.YYYY"
			"DD.M.YYYY"
			"YYYYMMDD"
			"YYYY-M-D"
		]
	,
		text: "Jahr-Monat"
		support_bc: false
		input: "MM.YYYY"
		invalid: "Datum ungültig"
		store: "YYYY-MM"
		display: "MMMM YYYY"
		display_short: "MM.YYYY"
		display_attribute: "year-month"
		display_short_attribute: "year-month-short"
		type: "year_month"
		# digi_clock: false
		clock: false
		parse: [
			"MM YYYY"
			"MM/YYYY"
			"MM.YYYY"
			"M.YYYY"
			"YYYY-M"
			"YYYY-MM"
		]
	,
		text: "Jahr"
		support_bc: true
		input: "Y"
		invalid: "Datum ungültig"
		display: "Y"
		display_short: "Y"
		display_attribute: "year"
		display_short_attribute: "year"
		store: "YYYY"
		type: "year"
		# digi_clock: false
		clock: false
		parse: [
			"Y"
		]
	]


CUI.DateTimeFormats["en-US"] =
	timezone: "Europe/Berlin"
	moment_locale: "en-US"
	tab_date: "Date"
	tab_time: "Time"
	tab_week: "Wk"
	formats: [
		text: "Date+Time"
		support_bc: false
		invalid: "Invalid Date"
		type: "date_time"
		clock: true
		store: "YYYY-MM-DDTHH:mm:00Z"
		clock_am_pm: true
		clock_seconds: false
		# digi_clock: "HH:mm"
		input: "YYYY-MM-DD hh:mm A"
		display: "dd, YYYY-MM-DD hh:mm A"
		display_short: "YYYY-MM-DD hh:mm A"
		display_attribute: "date-time"
		display_short_attribute: "date-time-short"
		# timezone_display: "dddd, DD.MM.YYYY HH:mm zZ"
		parse: [
			"MM/DD/YYYY HH:mm:ss"
			"MM/DD/YYYYTHH:mm:ss.SSSZ"
			"MM/DD/YYYYTHH:mm:ssZ"
			"YYYY-MM-DD HH:mm:ss"
			"YYYY-MM-DDTHH:mm:ss.SSSZ"
			"YYYY-MM-DDTHH:mm:ssZ"
			"D.M.YYYY HH:mm:ss"
			"DD.M.YYYY HH:mm:ss"
			"D.MM.YYYY HH:mm:ss"
			"D.MM.YY HH:mm:ss"
			"DD.M.YY HH:mm:ss"
			"D.M.YYYY HH:mm"
			"DD.M.YYYY HH:mm"
			"D.MM.YYYY HH:mm"
			"D.MM.YY HH:mm"
			"DD.M.YY HH:mm"
		]
	,
		text: "Date+Time+Seconds"
		support_bc: false
		invalid: "Invalid Date"
		# input: "YYYY-MM-DD HH:mm:ss"
		type: "date_time_seconds"
		store: "YYYY-MM-DDTHH:mm:ssZ"
		input: "YYYY-MM-DD HH:mm:ss"
		display: "dd, YYYY-MM-DD HH:mm:ss"
		display_short: "YYYY-MM-DD HH:mm:ss"
		display_attribute: "date-time-seconds"
		display_short_attribute: "date-time-seconds-short"
		# timezone_display: "dddd, DD.MM.YYYY HH:mm:ss zZ"
		clock: true
		clock_am_pm: true
		clock_seconds: true
		# digi_clock: "HH:mm:ss"
		parse: [
			"MM/DD/YYYY HH:mm:ss"
			"D.M.YYYY HH:mm:ss"
			"DD.M.YYYY HH:mm:ss"
			"D.MM.YYYY HH:mm:ss"
			"D.MM.YY HH:mm:ss"
			"DD.M.YY HH:mm:ss"
		]
	,
		text: "Date"
		support_bc: false
		input: "YYYY-MM-DD"
		invalid: "Invalid date"
		display: "dd, YYYY-MM-DD"
		display_short: "YYYY-MM-DD"
		display_attribute: "date"
		display_short_attribute: "date-short"
		store: "YYYY-MM-DD"
		type: "date"
		# digi_clock: false
		clock: false
		parse: [
			"MM/DD/YYYY"
			"D.M.YYYY"
			"D.MM.YYYY"
			"DD.M.YYYY"
			"YYYYMMDD"
			"YYYY-M-D"
		]
	,
		text: "Jahr-Monat"
		support_bc: false
		input: "MM-YYYY"
		invalid: "Invalid date"
		store: "YYYY-MM"
		display: "MMMM YYYY"
		display_short: "MM-YYYY"
		display_attribute: "year-month"
		display_short_attribute: "year-month-short"
		type: "year_month"
		# digi_clock: false
		clock: false
		parse: [
			"MM YYYY"
			"MM/YYYY"
			"MM.YYYY"
			"M.YYYY"
			"YYYY-M"
			"YYYY-MM"
		]
	,
		text: "Jahr"
		support_bc: true
		input: "Y"
		invalid: "Invalid date"
		display: "Y"
		display_short: "Y"
		display_attribute: "year"
		display_short_attribute: "year"
		store: "YYYY"
		type: "year"
		# digi_clock: false
		clock: false
		parse: [
			"Y"
		]
	]

CUI.DateTimeFormats["ru-RU"] =
	timezone: "Europe/Berlin"
	moment_locale: "ru-RU"
	tab_date: "Datum"
	tab_time: "Zeit"
	tab_week: "Wo"
	formats: [
		text: "Datum+Zeit"
		support_bc: false
		invalid: "Datum ungültig"
		type: "date_time"
		clock: true
		store: "YYYY-MM-DDTHH:mm:00Z"
		clock_seconds: false
# digi_clock: "HH:mm"
		input: "DD.MM.YYYY HH:mm"
		display: "dd, DD.MM.YYYY HH:mm"
		display_short: "DD.MM.YYYY HH:mm"
		display_attribute: "date-time"
		display_short_attribute: "date-time-short"
# timezone_display: "dddd, DD.MM.YYYY HH:mm zZ"
		parse: [
			"YYYY-MM-DD HH:mm:ss"
			"YYYY-MM-DDTHH:mm:ss.SSSZ"
			"YYYY-MM-DDTHH:mm:ssZ"
			"D.M.YYYY HH:mm:ss"
			"DD.M.YYYY HH:mm:ss"
			"D.MM.YYYY HH:mm:ss"
			"D.MM.YY HH:mm:ss"
			"DD.M.YY HH:mm:ss"
			"D.M.YYYY HH:mm"
			"DD.M.YYYY HH:mm"
			"D.MM.YYYY HH:mm"
			"D.MM.YY HH:mm"
			"DD.M.YY HH:mm"
			"M/D/YYYY HH:DD:ss"
			"MM/D/YYYY HH:DD:ss"
			"M/DD/YYYY HH:DD:ss"
			"M/DD/YY HH:DD:ss"
			"MM/D/YY HH:DD:ss"
			"M/D/YYYY HH:DD"
			"MM/D/YYYY HH:DD"
			"M/DD/YYYY HH:DD"
			"M/DD/YY HH:DD"
			"MM/D/YY HH:DD"
		]
	,
		text: "Datum+Zeit+Sekunden"
		support_bc: false
		invalid: "Datum ungültig"
# input: "YYYY-MM-DD HH:mm:ss"
		type: "date_time_seconds"
		input: "DD.MM.YYYY HH:mm:ss"
		store: "YYYY-MM-DDTHH:mm:ssZ"
		display: "dd, DD.MM.YYYY HH:mm:ss"
		display_short: "DD.MM.YYYY HH:mm:ss"
		display_attribute: "date-time-seconds"
		display_short_attribute: "date-time-seconds-short"
# timezone_display: "dddd, DD.MM.YYYY HH:mm:ss zZ"
		clock: true
		clock_seconds: true
# digi_clock: "HH:mm:ss"
		parse: [
			"YYYY-MM-DDTHH:mm:ssZ"
			"YYYY-MM-DD HH:mm:ss"
			"D.M.YYYY HH:mm:ss"
			"DD.M.YYYY HH:mm:ss"
			"D.MM.YYYY HH:mm:ss"
			"D.MM.YY HH:mm:ss"
			"DD.M.YY HH:mm:ss"
			"M/D/YYYY HH:DD:ss"
			"MM/D/YYYY HH:DD:ss"
			"M/DD/YYYY HH:DD:ss"
			"M/DD/YY HH:DD:ss"
			"MM/D/YY HH:DD:ss"
		]
	,
		text: "Datum"
		support_bc: false
		input: "DD.MM.YYYY"
		invalid: "Datum ungültig"
		display: "dd, DD.MM.YYYY"
		display_short: "DD.MM.YYYY"
		display_attribute: "date"
		display_short_attribute: "date-short"
		store: "YYYY-MM-DD"
		type: "date"
# digi_clock: false
		clock: false
		parse: [
			"D.M.YYYY"
			"D.MM.YYYY"
			"DD.M.YYYY"
			"YYYYMMDD"
			"YYYY-M-D"
			"M/D/YYYY"
			"MM/D/YYYY"
			"M/DD/YYYY"
		]
	,
		text: "Jahr-Monat"
		support_bc: false
		input: "MM.YYYY"
		invalid: "Datum ungültig"
		store: "YYYY-MM"
		display: "MMMM YYYY"
		display_short: "MM.YYYY"
		display_attribute: "year-month"
		display_short_attribute: "year-month-short"
		type: "year_month"
# digi_clock: false
		clock: false
		parse: [
			"MM YYYY"
			"MM/YYYY"
			"MM.YYYY"
			"M.YYYY"
			"YYYY-M"
			"YYYY-MM"
		]
	,
		text: "Jahr"
		support_bc: true
		input: "Y"
		invalid: "Datum ungültig"
		display: "Y"
		display_short: "Y"
		display_attribute: "year"
		display_short_attribute: "year"
		store: "YYYY"
		type: "year"
# digi_clock: false
		clock: false
		parse: [
			"Y"
		]
	]

CUI.DateTimeFormats["pl-PL"] =
	timezone: "Europe/Berlin"
	moment_locale: "pl-PL"
	tab_date: "Datum"
	tab_time: "Zeit"
	tab_week: "Wo"
	formats: [
		text: "Datum+Zeit"
		support_bc: false
		invalid: "Datum ungültig"
		type: "date_time"
		clock: true
		store: "YYYY-MM-DDTHH:mm:00Z"
		clock_seconds: false
# digi_clock: "HH:mm"
		input: "DD.MM.YYYY HH:mm"
		display: "dd, DD.MM.YYYY HH:mm"
		display_short: "DD.MM.YYYY HH:mm"
		display_attribute: "date-time"
		display_short_attribute: "date-time-short"
# timezone_display: "dddd, DD.MM.YYYY HH:mm zZ"
		parse: [
			"YYYY-MM-DD HH:mm:ss"
			"YYYY-MM-DDTHH:mm:ss.SSSZ"
			"YYYY-MM-DDTHH:mm:ssZ"
			"D.M.YYYY HH:mm:ss"
			"DD.M.YYYY HH:mm:ss"
			"D.MM.YYYY HH:mm:ss"
			"D.MM.YY HH:mm:ss"
			"DD.M.YY HH:mm:ss"
			"D.M.YYYY HH:mm"
			"DD.M.YYYY HH:mm"
			"D.MM.YYYY HH:mm"
			"D.MM.YY HH:mm"
			"DD.M.YY HH:mm"
			"M/D/YYYY HH:DD:ss"
			"MM/D/YYYY HH:DD:ss"
			"M/DD/YYYY HH:DD:ss"
			"M/DD/YY HH:DD:ss"
			"MM/D/YY HH:DD:ss"
			"M/D/YYYY HH:DD"
			"MM/D/YYYY HH:DD"
			"M/DD/YYYY HH:DD"
			"M/DD/YY HH:DD"
			"MM/D/YY HH:DD"
		]
	,
		text: "Datum+Zeit+Sekunden"
		support_bc: false
		invalid: "Datum ungültig"
# input: "YYYY-MM-DD HH:mm:ss"
		type: "date_time_seconds"
		input: "DD.MM.YYYY HH:mm:ss"
		store: "YYYY-MM-DDTHH:mm:ssZ"
		display: "dd, DD.MM.YYYY HH:mm:ss"
		display_short: "DD.MM.YYYY HH:mm:ss"
		display_attribute: "date-time-seconds"
		display_short_attribute: "date-time-seconds-short"
# timezone_display: "dddd, DD.MM.YYYY HH:mm:ss zZ"
		clock: true
		clock_seconds: true
# digi_clock: "HH:mm:ss"
		parse: [
			"YYYY-MM-DDTHH:mm:ssZ"
			"YYYY-MM-DD HH:mm:ss"
			"D.M.YYYY HH:mm:ss"
			"DD.M.YYYY HH:mm:ss"
			"D.MM.YYYY HH:mm:ss"
			"D.MM.YY HH:mm:ss"
			"DD.M.YY HH:mm:ss"
			"M/D/YYYY HH:DD:ss"
			"MM/D/YYYY HH:DD:ss"
			"M/DD/YYYY HH:DD:ss"
			"M/DD/YY HH:DD:ss"
			"MM/D/YY HH:DD:ss"
		]
	,
		text: "Datum"
		support_bc: false
		input: "DD.MM.YYYY"
		invalid: "Datum ungültig"
		display: "dd, DD.MM.YYYY"
		display_short: "DD.MM.YYYY"
		display_attribute: "date"
		display_short_attribute: "date-short"
		store: "YYYY-MM-DD"
		type: "date"
# digi_clock: false
		clock: false
		parse: [
			"D.M.YYYY"
			"D.MM.YYYY"
			"DD.M.YYYY"
			"YYYYMMDD"
			"YYYY-M-D"
			"M/D/YYYY"
			"MM/D/YYYY"
			"M/DD/YYYY"
		]
	,
		text: "Jahr-Monat"
		support_bc: false
		input: "MM.YYYY"
		invalid: "Datum ungültig"
		store: "YYYY-MM"
		display: "MMMM YYYY"
		display_short: "MM.YYYY"
		display_attribute: "year-month"
		display_short_attribute: "year-month-short"
		type: "year_month"
# digi_clock: false
		clock: false
		parse: [
			"MM YYYY"
			"MM/YYYY"
			"MM.YYYY"
			"M.YYYY"
			"YYYY-M"
			"YYYY-MM"
		]
	,
		text: "Jahr"
		support_bc: true
		input: "Y"
		invalid: "Datum ungültig"
		display: "Y"
		display_short: "Y"
		display_attribute: "year"
		display_short_attribute: "year"
		store: "YYYY"
		type: "year"
# digi_clock: false
		clock: false
		parse: [
			"Y"
		]
	]

CUI.DateTimeFormats["cs-CZ"] =
	timezone: "Europe/Berlin"
	moment_locale: "cs-CZ"
	tab_date: "Datum"
	tab_time: "Zeit"
	tab_week: "Wo"
	formats: [
		text: "Datum+Zeit"
		support_bc: false
		invalid: "Datum ungültig"
		type: "date_time"
		clock: true
		store: "YYYY-MM-DDTHH:mm:00Z"
		clock_seconds: false
# digi_clock: "HH:mm"
		input: "DD.MM.YYYY HH:mm"
		display: "dd, DD.MM.YYYY HH:mm"
		display_short: "DD.MM.YYYY HH:mm"
		display_attribute: "date-time"
		display_short_attribute: "date-time-short"
# timezone_display: "dddd, DD.MM.YYYY HH:mm zZ"
		parse: [
			"YYYY-MM-DD HH:mm:ss"
			"YYYY-MM-DDTHH:mm:ss.SSSZ"
			"YYYY-MM-DDTHH:mm:ssZ"
			"D.M.YYYY HH:mm:ss"
			"DD.M.YYYY HH:mm:ss"
			"D.MM.YYYY HH:mm:ss"
			"D.MM.YY HH:mm:ss"
			"DD.M.YY HH:mm:ss"
			"D.M.YYYY HH:mm"
			"DD.M.YYYY HH:mm"
			"D.MM.YYYY HH:mm"
			"D.MM.YY HH:mm"
			"DD.M.YY HH:mm"
			"M/D/YYYY HH:DD:ss"
			"MM/D/YYYY HH:DD:ss"
			"M/DD/YYYY HH:DD:ss"
			"M/DD/YY HH:DD:ss"
			"MM/D/YY HH:DD:ss"
			"M/D/YYYY HH:DD"
			"MM/D/YYYY HH:DD"
			"M/DD/YYYY HH:DD"
			"M/DD/YY HH:DD"
			"MM/D/YY HH:DD"
		]
	,
		text: "Datum+Zeit+Sekunden"
		support_bc: false
		invalid: "Datum ungültig"
# input: "YYYY-MM-DD HH:mm:ss"
		type: "date_time_seconds"
		input: "DD.MM.YYYY HH:mm:ss"
		store: "YYYY-MM-DDTHH:mm:ssZ"
		display: "dd, DD.MM.YYYY HH:mm:ss"
		display_short: "DD.MM.YYYY HH:mm:ss"
		display_attribute: "date-time-seconds"
		display_short_attribute: "date-time-seconds-short"
# timezone_display: "dddd, DD.MM.YYYY HH:mm:ss zZ"
		clock: true
		clock_seconds: true
# digi_clock: "HH:mm:ss"
		parse: [
			"YYYY-MM-DDTHH:mm:ssZ"
			"YYYY-MM-DD HH:mm:ss"
			"D.M.YYYY HH:mm:ss"
			"DD.M.YYYY HH:mm:ss"
			"D.MM.YYYY HH:mm:ss"
			"D.MM.YY HH:mm:ss"
			"DD.M.YY HH:mm:ss"
			"M/D/YYYY HH:DD:ss"
			"MM/D/YYYY HH:DD:ss"
			"M/DD/YYYY HH:DD:ss"
			"M/DD/YY HH:DD:ss"
			"MM/D/YY HH:DD:ss"
		]
	,
		text: "Datum"
		support_bc: false
		input: "DD.MM.YYYY"
		invalid: "Datum ungültig"
		display: "dd, DD.MM.YYYY"
		display_short: "DD.MM.YYYY"
		display_attribute: "date"
		display_short_attribute: "date-short"
		store: "YYYY-MM-DD"
		type: "date"
# digi_clock: false
		clock: false
		parse: [
			"D.M.YYYY"
			"D.MM.YYYY"
			"DD.M.YYYY"
			"YYYYMMDD"
			"YYYY-M-D"
			"M/D/YYYY"
			"MM/D/YYYY"
			"M/DD/YYYY"
		]
	,
		text: "Jahr-Monat"
		support_bc: false
		input: "MM.YYYY"
		invalid: "Datum ungültig"
		store: "YYYY-MM"
		display: "MMMM YYYY"
		display_short: "MM.YYYY"
		display_attribute: "year-month"
		display_short_attribute: "year-month-short"
		type: "year_month"
# digi_clock: false
		clock: false
		parse: [
			"MM YYYY"
			"MM/YYYY"
			"MM.YYYY"
			"M.YYYY"
			"YYYY-M"
			"YYYY-MM"
		]
	,
		text: "Jahr"
		support_bc: true
		input: "Y"
		invalid: "Datum ungültig"
		display: "Y"
		display_short: "Y"
		display_attribute: "year"
		display_short_attribute: "year"
		store: "YYYY"
		type: "year"
# digi_clock: false
		clock: false
		parse: [
			"Y"
		]
	]