DateTimeFormats = {}

DateTimeFormats["de-DE"] =
	timezone: "Europe/Berlin"
	moment_locale: "de-DE"
	tab_date: "Datum"
	tab_time: "Zeit"
	tab_week: "Wo"
	formats: [
		text: "Datum+Zeit"
		invalid: "Datum ungültig"
		type: "date_time"
		clock: true
		store: "YYYY-MM-DDTHH:mm:00Z"
		clock_seconds: false
		# digi_clock: "HH:mm"
		input: "DD.MM.YYYY HH:mm"
		display: "dddd, DD.MM.YYYY HH:mm"
		display_short: "DD.MM.YYYY HH:mm"
		# timezone_display: "dddd, DD.MM.YYYY HH:mm zZ"
		parse: [
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
		invalid: "Datum ungültig"
		# input: "YYYY-MM-DD HH:mm:ss"
		type: "date_time_seconds"
		input: "DD.MM.YYYY HH:mm:ss"
		store: "YYYY-MM-DDTHH:mm:ssZ"
		display: "dddd, DD.MM.YYYY HH:mm:ss"
		display_short: "DD.MM.YYYY HH:mm:ss"
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
		]
	,
		text: "Datum"
		input: "DD.MM.YYYY"
		invalid: "Datum ungültig"
		display: "dddd, DD.MM.YYYY"
		display_short: "DD.MM.YYYY"
		store: "YYYY-MM-DD"
		type: "date"
		# digi_clock: false
		clock: false
		parse: [
			"D.M.YYYY"
			"D.MM.YYYY"
			"DD.M.YYYY"
		]
	,
		text: "Jahr-Monat"
		input: "MM.YYYY"
		invalid: "Datum ungültig"
		store: "YYYY-MM"
		display: "MMMM YYYY"
		display_short: "MM YYYY"
		type: "year_month"
		# digi_clock: false
		clock: false
		parse: [
			"M.YYYY"
		]
	,
		text: "Jahr"
		input: "YYYY"
		invalid: "Datum ungültig"
		display: "YYYY"
		display_short: "YYYY"
		store: "YYYY"
		type: "year"
		# digi_clock: false
		clock: false
		parse: [
			"YYYY"
		]
	]

DateTimeFormats["it-IT"] =
	timezone: "Europe/Berlin"
	moment_locale: "de-DE"
	tab_date: "Datum"
	tab_time: "Zeit"
	tab_week: "Wk"
	formats: [
		text: "Datum+Zeit"
		invalid: "Datum ungültig"
		type: "date_time"
		clock: true
		store: "YYYY-MM-DDTHH:mm:00Z"
		clock_seconds: false
		# digi_clock: "HH:mm"
		input: "DD.MM.YYYY HH:mm"
		display: "dddd, DD.MM.YYYY HH:mm"
		display_short: "DD.MM.YYYY HH:mm"
		# timezone_display: "dddd, DD.MM.YYYY HH:mm zZ"
		parse: [
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
		invalid: "Datum ungültig"
		# input: "YYYY-MM-DD HH:mm:ss"
		type: "date_time_seconds"
		input: "DD.MM.YYYY HH:mm:ss"
		store: "YYYY-MM-DDTHH:mm:ssZ"
		display: "dddd, DD.MM.YYYY HH:mm:ss"
		display_short: "DD.MM.YYYY HH:mm:ss"
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
		input: "DD.MM.YYYY"
		invalid: "Datum ungültig"
		display: "dddd, DD.MM.YYYY"
		display_short: "DD.MM.YYYY"
		store: "YYYY-MM-DD"
		type: "date"
		# digi_clock: false
		clock: false
		parse: [
			"D.M.YYYY"
			"D.MM.YYYY"
			"DD.M.YYYY"
		]
	,
		text: "Jahr-Monat"
		input: "MM.YYYY"
		invalid: "Datum ungültig"
		store: "YYYY-MM"
		display: "MMMM YYYY"
		display_short: "MM YYYY"
		type: "year_month"
		# digi_clock: false
		clock: false
		parse: [
			"M.YYYY"
		]
	,
		text: "Jahr"
		input: "YYYY"
		invalid: "Datum ungültig"
		display: "YYYY"
		display_short: "YYYY"
		store: "YYYY"
		type: "year"
		# digi_clock: false
		clock: false
		parse: [
			"YYYY"
		]
	]

DateTimeFormats["es-ES"] =
	timezone: "Europe/Berlin"
	moment_locale: "de-DE"
	tab_date: "Datum"
	tab_time: "Zeit"
	tab_week: "Wk"
	formats: [
		text: "Datum+Zeit"
		invalid: "Datum ungültig"
		type: "date_time"
		clock: true
		store: "YYYY-MM-DDTHH:mm:00Z"
		clock_seconds: false
		# digi_clock: "HH:mm"
		input: "DD.MM.YYYY HH:mm"
		display: "dddd, DD.MM.YYYY HH:mm"
		display_short: "DD.MM.YYYY HH:mm"
		# timezone_display: "dddd, DD.MM.YYYY HH:mm zZ"
		parse: [
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
		invalid: "Datum ungültig"
		# input: "YYYY-MM-DD HH:mm:ss"
		type: "date_time_seconds"
		input: "DD.MM.YYYY HH:mm:ss"
		store: "YYYY-MM-DDTHH:mm:ssZ"
		display: "dddd, DD.MM.YYYY HH:mm:ss"
		display_short: "DD.MM.YYYY HH:mm:ss"
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
		input: "DD.MM.YYYY"
		invalid: "Datum ungültig"
		display: "dddd, DD.MM.YYYY"
		display_short: "DD.MM.YYYY"
		store: "YYYY-MM-DD"
		type: "date"
		# digi_clock: false
		clock: false
		parse: [
			"D.M.YYYY"
			"D.MM.YYYY"
			"DD.M.YYYY"
		]
	,
		text: "Jahr-Monat"
		input: "MM.YYYY"
		invalid: "Datum ungültig"
		store: "YYYY-MM"
		display: "MMMM YYYY"
		display_short: "MM YYYY"
		type: "year_month"
		# digi_clock: false
		clock: false
		parse: [
			"M.YYYY"
		]
	,
		text: "Jahr"
		input: "YYYY"
		invalid: "Datum ungültig"
		display: "YYYY"
		display_short: "YYYY"
		store: "YYYY"
		type: "year"
		# digi_clock: false
		clock: false
		parse: [
			"YYYY"
		]
	]


DateTimeFormats["en-US"] =
	timezone: "Europe/Berlin"
	moment_locale: "en-US"
	tab_date: "Date"
	tab_time: "Time"
	tab_week: "Wk"
	formats: [
		text: "Date+Time"
		invalid: "Invalid Date"
		type: "date_time"
		clock: true
		store: "YYYY-MM-DDTHH:mm:00Z"
		clock_am_pm: true
		clock_seconds: false
		# digi_clock: "HH:mm"
		input: "MM/DD/YYYY HH:mm"
		display: "dddd, MM/DD/YYYY HH:mm"
		display_short: "MM/DD/YYYY HH:mm"
		# timezone_display: "dddd, DD.MM.YYYY HH:mm zZ"
		parse: [
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
		invalid: "Invalid Date"
		# input: "YYYY-MM-DD HH:mm:ss"
		type: "date_time_seconds"
		store: "YYYY-MM-DDTHH:mm:ssZ"
		input: "MM/DD/YYYY HH:mm:ss"
		display: "dddd, MM/DD/YYYY HH:mm:ss"
		display_short: "MM/DD/YYYY HH:mm:ss"
		# timezone_display: "dddd, DD.MM.YYYY HH:mm:ss zZ"
		clock: true
		clock_am_pm: true
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
		text: "Date"
		input: "MM/DD/YYYY"
		invalid: "Invalid date"
		display: "dddd, MM/DD/YYYY"
		display_short: "MM/DD/YYYY"
		store: "YYYY-MM-DD"
		type: "date"
		# digi_clock: false
		clock: false
		parse: [
			"D.M.YYYY"
			"D.MM.YYYY"
			"DD.M.YYYY"
		]
	,
		text: "Jahr-Monat"
		input: "MM/YYYY"
		invalid: "Invalid date"
		store: "YYYY-MM"
		display: "MMMM YYYY"
		display_short: "MM YYYY"
		type: "year_month"
		# digi_clock: false
		clock: false
		parse: [
			"M.YYYY"
		]
	,
		text: "Jahr"
		input: "YYYY"
		invalid: "Invalid date"
		display: "YYYY"
		display_short: "YYYY"
		store: "YYYY"
		type: "year"
		# digi_clock: false
		clock: false
		parse: [
			"YYYY"
		]
	]
