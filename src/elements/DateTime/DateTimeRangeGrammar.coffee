class CUI.DateTimeRangeGrammar

	@REGEXP_DATE = /^[0-9]+[-/.][0-9]+[-/.][0-9]+$/ # Exact date
	@REGEXP_MONTH = /^[0-9]+[-/.][0-9]+$/ # Matches if the date has Year and month (no day)
	@REGEXP_YEAR = /^\-?[0-9]+$/ # Matches if the date has Year. (no day, no month)
	@REGEXP_YEAR_DOT = /^[0-9]+.$/ # Matches Year ending with dot.
	@REGEXP_CENTURY = /^[0-9]+th$/ # Matches Year ending with th.
	@REGEXP_SPACE = /\s+/
	@TYPE_DATE = "DATE"
	@TYPE_YEAR = "YEAR"
	@TYPE_YEAR_DOT = "YEAR_DOT"
	@TYPE_CENTURY = "CENTURY"
	@TYPE_CENTURY_RANGE = "CENTURY_RANGE"
	@DASH = "-"
	@STORE_FORMAT = "store"
	@OUTPUT_YEAR = "year"
	@OUTPUT_DATE = "date"
	@DISPLAY_ATTRIBUTE_YEAR_MONTH = "year-month"

	### How to add new grammars:
	# [<GRAMMAR>, <FUNCTION>, <ARRAY_TOKEN_POSITION>, <ARRAY_FUNCTION_ARGUMENTS>, <KEY>]
	#
	# GRAMMAR: Plain text with tokens to identify dates.
	#  - Tokens available: DATE (full date), YEAR (only year), YEAR_DOT (year with dot), CENTURY (year with th)
	#
	# FUNCTION: Function which is going to be used to parse, in string.
	#  - Functions available: millennium, century, earlyCentury, lateCentury, range, yearRange, getFromTo
	#
	# ARRAY_TOKEN_POSITION: Array of integers with the position of the date tokens.
	# ARRAY_FUNCTION_ARGUMENTS: (optional) Array with arguments that will be given to the function.
	#  - Dates are given as arguments automatically.
	#
	# KEY: (optional) Identifier that is used in the format method.
	###
	@PARSE_GRAMMARS = {} # TODO: Add ES & IT.
	@PARSE_GRAMMARS["de-DE"] = [
		["DATE bis DATE", "range", [0, 2], null, "RANGE"]
		["YEAR bis YEAR", "range", [0, 2]]
		["YEAR - YEAR n. Chr.", "range", [0, 2]]
		["YEAR bis YEAR n. Chr.", "range", [0, 2]]
		["zwischen YEAR bis YEAR", "range", [1, 3]]
		["zwischen YEAR und YEAR", "range", [1, 3]]
		["zwischen DATE bis DATE", "range", [1, 3]]
		["zwischen DATE und DATE", "range", [1, 3]]
		["von YEAR bis YEAR", "range", [1, 3]]
		["YEAR v. Chr. - YEAR n. Chr.", "range", [0, 4], [true]]
		["YEAR - YEAR v. Chr.", "range", [0, 2], [true, true]]
		["YEAR BC - YEAR n. Chr.", "range", [0, 3], [true]]
		["YEAR BC - YEAR nach Chr.", "range", [0, 3], [true]]
		["YEAR B.C. - YEAR n. Chr.", "range", [0, 3], [true]]
		["YEAR B.C. - YEAR nach Chr.", "range", [0, 3], [true]]
		["YEAR bc - YEAR n. Chr.", "range", [0, 3], [true]]
		["YEAR bc - YEAR nach Chr.", "range", [0, 3], [true]]
		["YEAR ac - YEAR n. Chr.", "range", [0, 3], [true]]
		["YEAR ac - YEAR nach Chr.", "range", [0, 3], [true]]
		["bis YEAR", "yearRange", [1], [false, true]]
		["um YEAR", "yearRange", [1], [false, true, true], "AROUND"]
		["ca. YEAR", "yearRange", [1], [false, true, true]]
		["um YEAR bc", "yearRange", [1], [true, true, true]]
		["um YEAR v. Chr.", "yearRange", [1], [true, true, true], "AROUND_BC"]
		["ca. YEAR bc", "yearRange", [1], [true, true, true]]
		["ca. YEAR v. Chr.", "yearRange", [1], [true, true, true]]
		["vor YEAR", "yearRange", [1], [false, true], "BEFORE"]
		["vor YEAR bc", "yearRange", [1], [true, true]]
		["vor YEAR v. Chr.", "yearRange", [1], [true, true], "BEFORE_BC"]
		["nach YEAR", "yearRange", [1], [false, false, true], "AFTER"]
		["nach YEAR ad", "yearRange", [1], [false, false, true]]
		["nach YEAR A.D.", "yearRange", [1], [false, false, true]]
		["ab YEAR", "yearRange", [1], [false, false, true]]
		["ab YEAR ad", "yearRange", [1], [false, false, true]]
		["ab YEAR A.D.", "yearRange", [1], [false, false, true]]
		["nach YEAR bc", "yearRange", [1], [true, false, true]]
		["nach YEAR v. Chr.", "yearRange", [1], [true, false, true], "AFTER_BC"]
		["YEAR v. Chr.", "getFromTo", [0], [true]]
		["YEAR n. Chr.", "getFromTo", [0]]
		["YEAR_DOT Jhd. vor Chr", "century", [0], [true]]
		["YEAR_DOT Jhd. vor Chr.", "century", [0], [true]]
		["YEAR_DOT Jhd. v. Chr", "century", [0], [true]]
		["YEAR_DOT Jhd. v. Chr.", "century", [0], [true], "CENTURY_BC"]
		["YEAR_DOT Jhd vor Chr", "century", [0], [true]]
		["YEAR_DOT Jhd vor Chr.", "century", [0], [true]]
		["YEAR_DOT Jhd v. Chr", "century", [0], [true]]
		["YEAR_DOT Jhd v. Chr.", "century", [0], [true]]
		["YEAR_DOT Jh vor Chr", "century", [0], [true]]
		["YEAR_DOT Jh vor Chr.", "century", [0], [true]]
		["YEAR_DOT Jh v. Chr", "century", [0], [true]]
		["YEAR_DOT Jh v. Chr.", "century", [0], [true]]
		["YEAR_DOT Jh. vor Chr", "century", [0], [true]]
		["YEAR_DOT Jh. vor Chr.", "century", [0], [true]]
		["YEAR_DOT Jh. v. Chr", "century", [0], [true]]
		["YEAR_DOT Jh. v. Chr.", "century", [0], [true]]
		["YEAR Jhd. vor Chr", "century", [0], [true]]
		["YEAR Jhd. vor Chr.", "century", [0], [true]]
		["YEAR Jhd. v. Chr", "century", [0], [true]]
		["YEAR Jhd. v. Chr.", "century", [0], [true]]
		["YEAR Jhd vor Chr", "century", [0], [true]]
		["YEAR Jhd vor Chr.", "century", [0], [true]]
		["YEAR Jhd v. Chr", "century", [0], [true]]
		["YEAR Jhd v. Chr.", "century", [0], [true]]
		["YEAR Jhd ac", "century", [0], [true]]
		["YEAR Jh ac", "century", [0], [true]]
		["YEAR Jh. ac", "century", [0], [true]]
		["YEAR Jhd.", "century", [0]]
		["YEAR Jhd", "century", [0]]
		["YEAR Jh", "century", [0]]
		["YEAR Jh.", "century", [0]]
		["YEAR_DOT Jhd.", "century", [0], null, "CENTURY"]
		["YEAR_DOT Jhd", "century", [0]]
		["YEAR_DOT Jhd nach Chr.", "century", [0]]
		["YEAR_DOT Jhd. nach Chr.", "century", [0]]
		["YEAR_DOT Jhd. nach Chr", "century", [0]]
		["YEAR_DOT Jhd nach Chr", "century", [0]]
		["YEAR_DOT Jhd. n. Chr.", "century", [0]]
		["YEAR_DOT Jhd. n. Chr", "century", [0]]
		["YEAR_DOT Jhd n. Chr.", "century", [0]]
		["YEAR_DOT Jhd n. Chr", "century", [0]]
		["YEAR_DOT Jt. v. Chr.", "millennium", [0], [true], "MILLENNIUM_BC"]
		["YEAR_DOT Jt v. Chr.", "millennium", [0], [true]]
		["YEAR_DOT Jt bc", "millennium", [0], [true]]
		["YEAR_DOT Jt. bc", "millennium", [0], [true]]
		["YEAR_DOT Jt BC", "millennium", [0], [true]]
		["YEAR_DOT Jt. BC", "millennium", [0], [true]]
		["YEAR_DOT Jt.", "millennium", [0], null, "MILLENNIUM"]
		["YEAR_DOT Jt.", "millennium", [0]]
		["YEAR_DOT Jt", "millennium", [0]]
		["YEAR Jt. v. Chr.", "millennium", [0], [true]]
		["YEAR Jt v. Chr.", "millennium", [0], [true]]
		["YEAR Jt bc", "millennium", [0], [true]]
		["YEAR Jt. bc", "millennium", [0], [true]]
		["YEAR Jt BC", "millennium", [0], [true]]
		["YEAR Jt. BC", "millennium", [0], [true]]
		["YEAR Jt.", "millennium", [0]]
		["YEAR Jt.", "millennium", [0]]
		["YEAR Jt", "millennium", [0]]
		["Anfang YEAR_DOT Jhd", "earlyCentury", [1]]
		["Anfang YEAR_DOT Jh", "earlyCentury", [1]]
		["Anfang YEAR_DOT Jh.", "earlyCentury", [1], null, "EARLY_CENTURY"]
		["Anfang YEAR_DOT Jhd v. Chr.", "earlyCentury", [1], [true]]
		["Anfang YEAR_DOT Jh v. Chr.", "earlyCentury", [1], [true]]
		["Anfang YEAR_DOT Jh. v. Chr.", "earlyCentury", [1], [true], "EARLY_CENTURY_BC"]
		["Ende YEAR_DOT Jhd", "lateCentury", [1]]
		["Ende YEAR_DOT Jh", "lateCentury", [1]]
		["Ende YEAR_DOT Jh.", "lateCentury", [1], null, "LATE_CENTURY"]
		["Ende YEAR_DOT Jhd v. Chr.", "lateCentury", [1], [true]]
		["Ende YEAR_DOT Jh v. Chr.", "lateCentury", [1], [true]]
		["Ende YEAR_DOT Jh. v. Chr.", "lateCentury", [1], [true], "LATE_CENTURY_BC"]
		["YEAR_DOT Jhd. - YEAR_DOT Jhd.", "centuryRange", [0, 3], null, "CENTURY_RANGE"]
		["YEAR_DOT Jhd - YEAR_DOT Jhd", "centuryRange", [0, 3]]
		["YEAR Jhd. - YEAR Jhd.", "centuryRange", [0, 3]]
		["YEAR Jhd - YEAR Jhd", "centuryRange", [0, 3]]
		["YEAR Jh. - YEAR Jh.", "centuryRange", [0, 3]]
		["YEAR Jh - YEAR Jh", "centuryRange", [0, 3]]
		["YEAR_DOT Jh. - YEAR_DOT Jh.", "centuryRange", [0, 3]]
		["YEAR_DOT Jh - YEAR_DOT Jh", "centuryRange", [0, 3]]
		["YEAR_DOT Jhd. v. Chr. - YEAR_DOT Jhd.", "centuryRange", [0, 5], [true], "CENTURY_RANGE_FROM_BC"]
		["YEAR_DOT Jhd v. Chr. - YEAR_DOT Jhd", "centuryRange", [0, 5], [true]]
		["YEAR Jhd. v. Chr. - YEAR Jhd.", "centuryRange", [0, 5], [true]]
		["YEAR Jhd v. Chr. - YEAR Jhd", "centuryRange", [0, 5], [true]]
		["YEAR Jh. v. Chr. - YEAR Jh.", "centuryRange", [0, 5], [true]]
		["YEAR Jh v. Chr. - YEAR Jh", "centuryRange", [0, 5], [true]]
		["YEAR_DOT Jh. v. Chr. - YEAR_DOT Jh.", "centuryRange", [0, 5], [true]]
		["YEAR_DOT Jh v. Chr. - YEAR_DOT Jh", "centuryRange", [0, 5], [true]]
		["YEAR_DOT Jhd. v. Chr. - YEAR_DOT Jhd. v. Chr.", "centuryRange", [0, 5], [true, true], "CENTURY_RANGE_BC"]
		["YEAR_DOT Jhd v. Chr. - YEAR_DOT Jhd v. Chr.", "centuryRange", [0, 5], [true, true]]
		["YEAR Jhd. v. Chr. - YEAR Jhd. v. Chr.", "centuryRange", [0, 5], [true, true]]
		["YEAR Jhd v. Chr. - YEAR Jhd v. Chr.", "centuryRange", [0, 5], [true, true]]
		["YEAR Jh. v. Chr. - YEAR Jh. v. Chr.", "centuryRange", [0, 5], [true, true]]
		["YEAR Jh v. Chr. - YEAR Jh v. Chr.", "centuryRange", [0, 5], [true, true]]
		["YEAR_DOT Jh. v. Chr. - YEAR_DOT Jh. v. Chr.", "centuryRange", [0, 5], [true, true]]
		["YEAR_DOT Jh v. Chr. - YEAR_DOT Jh v. Chr.", "centuryRange", [0, 5], [true, true]]
	]
	@PARSE_GRAMMARS["en-US"] = [
		["DATE to DATE", "range", [0, 2], null, "RANGE"]
		["YEAR to YEAR", "range", [0, 2]]
		["YEAR - YEAR A.D.", "range", [0, 2]]
		["YEAR - YEAR AD", "range", [0, 2]]
		["YEAR to YEAR A.D.", "range", [0, 2]]
		["YEAR to YEAR AD", "range", [0, 2]]
		["from YEAR to YEAR", "range", [1, 3]]
		["YEAR BC - YEAR A.D.", "range", [0, 3], [true]]
		["YEAR BC - YEAR AD", "range", [0, 3], [true]]
		["YEAR BC - YEAR CE", "range", [0, 3], [true]]
		["YEAR BC - YEAR ad", "range", [0, 3], [true]]
		["YEAR B.C. - YEAR A.D.", "range", [0, 3], [true]]
		["YEAR B.C. - YEAR AD", "range", [0, 3], [true]]
		["YEAR B.C. - YEAR CE", "range", [0, 3], [true]]
		["YEAR B.C. - YEAR ad", "range", [0, 3], [true]]
		["YEAR B.C. to YEAR", "range", [0, 3], [true]]
		["YEAR bc - YEAR A.D.", "range", [0, 3], [true]]
		["YEAR bc - YEAR AD", "range", [0, 3], [true]]
		["YEAR bc - YEAR CE", "range", [0, 3], [true]]
		["YEAR bc - YEAR ad", "range", [0, 3], [true]]
		["YEAR ac - YEAR A.D.", "range", [0, 3], [true]]
		["YEAR ac - YEAR AD", "range", [0, 3], [true]]
		["YEAR ac - YEAR CE", "range", [0, 3], [true]]
		["YEAR ac - YEAR ad", "range", [0, 3], [true]]
		["YEAR - YEAR BC", "range", [0, 2], [true, true]]
		["YEAR - YEAR B.C.", "range", [0, 2], [true, true]]
		["after YEAR", "yearRange", [1], [false, false, true], "AFTER"]
		["after YEAR BC", "yearRange", [1], [true, false, true], "AFTER_BC"]
		["before YEAR", "yearRange", [1], [false, true], "BEFORE"]
		["before YEAR BC", "yearRange", [1], [true, true], "BEFORE_BC"]
		["around YEAR", "yearRange", [1], [false, true, true], "AROUND"]
		["around YEAR BC", "yearRange", [1], [true, true, true], "AROUND_BC"]
		["YEAR_DOT millennium", "millennium", [0], null, "MILLENNIUM"]
		["YEAR_DOT millennium BC", "millennium", [0], [true], "MILLENNIUM_BC"]
		["YEAR millennium", "millennium", [0]]
		["YEAR millennium BC", "millennium", [0], [true]]
		["YEAR BCE", "getFromTo", [0], [true]]
		["YEAR bc", "getFromTo", [0], [true]]
		["YEAR BC", "getFromTo", [0], [true]]
		["YEAR B.C.", "getFromTo", [0], [true]]
		["YEAR AD", "getFromTo", [0]]
		["YEAR A.D.", "getFromTo", [0]]
		["CENTURY century", "century", [0], null, "CENTURY"]
		["CENTURY century BC", "century", [0], [true], "CENTURY_BC"]
		["Early CENTURY century", "earlyCentury", [1], null, "EARLY_CENTURY"]
		["Early CENTURY century BC", "earlyCentury", [1], [true], "EARLY_CENTURY_BC"]
		["Late CENTURY century", "lateCentury", [1], null, "LATE_CENTURY"]
		["Late CENTURY century BC", "lateCentury", [1], [true], "LATE_CENTURY_BC"]
		["CENTURY century - CENTURY century", "centuryRange", [0, 3], null, "CENTURY_RANGE"]
		["CENTURY century BC - CENTURY century", "centuryRange", [0, 4], [true], "CENTURY_RANGE_FROM_BC"]
		["CENTURY century B.C. - CENTURY century", "centuryRange", [0, 4], [true]]
		["CENTURY century BC - CENTURY century BC", "centuryRange", [0, 4], [true, true], "CENTURY_RANGE_BC"]
		["CENTURY century B.C. - CENTURY century B.C.", "centuryRange", [0, 4], [true, true]]
	]

	@dateRangeToString: (from, to) ->
		if not CUI.util.isString(from) or not CUI.util.isString(to)
			return

		locale = CUI.DateTime.getLocale()
		fromMoment = CUI.DateTimeRangeGrammar.getMoment(from)
		toMoment = CUI.DateTimeRangeGrammar.getMoment(to)

		if not fromMoment?.isValid() or not toMoment?.isValid()
			return CUI.DateTimeFormats[locale].formats[0].invalid

		if CUI.DateTimeRangeGrammar.REGEXP_YEAR.test(from)
			fromIsYear = true
			fromYear = parseInt(from)
		else if fromMoment.isValid() and fromMoment.date() == 1 and fromMoment.month() == 0 # First day of year.
			fromYear = fromMoment.year()

		if from == to
			return CUI.DateTime.format(from, "display_short")

		if CUI.DateTimeRangeGrammar.REGEXP_YEAR.test(to)
			toIsYear = true
			toYear = parseInt(to)
		else if toMoment.isValid() and toMoment.date() == 31 and toMoment.month() == 11 # Last day of year
			toYear = toMoment.year()

		grammars = CUI.DateTimeRangeGrammar.PARSE_GRAMMARS[locale]
		getPossibleString = (key, parameters) ->
			for _grammar in grammars
				if _grammar[4] == key
					grammar = _grammar
					break

			if not grammar
				return

			possibleStringArray = grammar[0].split(CUI.DateTimeRangeGrammar.REGEXP_SPACE)
			tokenPositions = grammar[2]

			for value, index in tokenPositions
				if parameters[index]
					if possibleStringArray[value] == "YEAR_DOT"
						parameters[index] += "."
					else if possibleStringArray[value] == "CENTURY"
						parameters[index] += "th"
					else if CUI.util.isString(parameters[index])
						parameters[index] = CUI.DateTime.format(parameters[index], "display_short")
					possibleStringArray[value] = parameters[index]

			possibleString = possibleStringArray.join(" ")
			output = CUI.DateTimeRangeGrammar.stringToDateRange(possibleString)
			if not output or output.to != to or output.from != from
				return

			return possibleString

		if not CUI.util.isUndef(fromYear) and not CUI.util.isUndef(toYear)
			if fromYear == toYear
				return "#{fromYear}"

			isBC = fromYear <= 0
			if isBC
				possibleString = getPossibleString("AFTER_BC", [Math.abs(fromYear)])
			else
				possibleString = getPossibleString("AFTER", [Math.abs(fromYear)])

			if possibleString
				return possibleString

			isBC = toYear <= 0
			if isBC
				possibleString = getPossibleString("BEFORE_BC", [Math.abs(toYear)])
			else
				possibleString = getPossibleString("BEFORE", [Math.abs(toYear)])

			if possibleString
				return possibleString

			centerYear = (toYear + fromYear) / 2
			isBC = centerYear <= 0
			if isBC
				possibleString = getPossibleString("AROUND_BC", [Math.abs(centerYear)])
			else
				possibleString = getPossibleString("AROUND", [Math.abs(centerYear)])

			if possibleString
				return possibleString

			yearsDifference = toYear - fromYear
			if yearsDifference == 999 # Millennium
				isBC = toYear <= 0
				if isBC
					millennium = (-from + 1) / 1000
					possibleString = getPossibleString("MILLENNIUM_BC", [millennium])
				else
					millennium = to / 1000
					possibleString = getPossibleString("MILLENNIUM", [millennium])


				if possibleString
					return possibleString
			else if yearsDifference == 99 # Century
				isBC = toYear <= 0
				if isBC
					century = -(fromYear - 1) / 100
					possibleString = getPossibleString("CENTURY_BC", [century])
				else
					century = toYear / 100
					possibleString = getPossibleString("CENTURY", [century])

				if possibleString
					return possibleString
			else if yearsDifference == 15 # Early/Late
				isBC = fromYear <= 0
				century = Math.ceil(Math.abs(fromYear) / 100)
				if isBC
					for key in ["EARLY_CENTURY_BC", "LATE_CENTURY_BC"]
						possibleString = getPossibleString(key, [century])
						if possibleString
							return possibleString
				else
					for key in ["EARLY_CENTURY", "LATE_CENTURY"]
						possibleString = getPossibleString(key, [century])
						if possibleString
							return possibleString
			else if (yearsDifference + 1) % 100 == 0 and (fromYear - 1) % 100 == 0 and toYear % 100 == 0
				fromCentury = (fromYear + 99) / 100
				toCentury = toYear / 100
				possibleString = getPossibleString("CENTURY_RANGE", [fromCentury, toCentury])
				if possibleString
					return possibleString

		if fromMoment.year() == toMoment.year() and
			fromMoment.month() == toMoment.month() and
			fromMoment.date() == 1 and toMoment.date() == toMoment.endOf("month").date()
				for format in CUI.DateTimeFormats[locale].formats
					if format.display_attribute == CUI.DateTimeRangeGrammar.DISPLAY_ATTRIBUTE_YEAR_MONTH
						return toMoment.format(format.display_short)

		if fromIsYear or toIsYear
			if fromIsYear
				from = CUI.DateTime.format(from, "display_short")
			if toIsYear
				to = CUI.DateTime.format(to, "display_short")

				# Removes the 'BC' / v. Chr. from 'from' to only show it in the end. For example: 15 - 10 v. Chr.
				fromSplit = from.split(CUI.DateTimeRangeGrammar.REGEXP_SPACE)
				toSplit = to.split(CUI.DateTimeRangeGrammar.REGEXP_SPACE)
				if fromSplit[1] == toSplit[1]
					from = fromSplit[0]
			return "#{from} - #{to}"

		possibleString = getPossibleString("RANGE", [from, to])
		if possibleString
			return possibleString

		return "#{from} - #{to}"

	# Main method to check against every grammar.
	@stringToDateRange: (input) ->
		if CUI.util.isEmpty(input) or not CUI.util.isString(input)
			return error: "Input needs to be a non empty string: #{input}"

		input = input.trim()

		tokens = []
		for s in input.split(CUI.DateTimeRangeGrammar.REGEXP_SPACE)
			value = s
			if CUI.DateTimeRangeGrammar.REGEXP_DATE.test(s) or CUI.DateTimeRangeGrammar.REGEXP_MONTH.test(s)
				type = CUI.DateTimeRangeGrammar.TYPE_DATE
			else if CUI.DateTimeRangeGrammar.REGEXP_YEAR.test(s)
				type = CUI.DateTimeRangeGrammar.TYPE_YEAR
			else if CUI.DateTimeRangeGrammar.REGEXP_YEAR_DOT.test(s)
				type = CUI.DateTimeRangeGrammar.TYPE_YEAR_DOT
				value = s.split(".")[0]
			else if CUI.DateTimeRangeGrammar.REGEXP_CENTURY.test(s)
				type = CUI.DateTimeRangeGrammar.TYPE_CENTURY
				value = s.split("th")[0]
			else
				type = s # The type for everything else is the value.

			tokens.push
				type: type
				value: value

		stringToParse = tokens.map((token) -> token.type).join(" ").toUpperCase()

		# Check if there is a grammar that applies to the input.
		for _, grammars of CUI.DateTimeRangeGrammar.PARSE_GRAMMARS
			for grammar in grammars
				if grammar[0].toUpperCase() == stringToParse
					method = CUI.DateTimeRangeGrammar[grammar[1]]
					if not CUI.util.isFunction(method) or not grammar[2]
						continue
					tokenPositions = grammar[2]
					if CUI.util.isArray(tokenPositions)
						if tokenPositions.length == 0
							continue
						methodArguments = tokenPositions.map((index) -> tokens[index].value)
					else
						methodArguments = [tokenPositions]
					if extraArguments = grammar[3]
						if CUI.util.isArray(extraArguments)
							methodArguments = methodArguments.concat(extraArguments)
						else
							methodArguments.push(extraArguments)
					value = method.apply(@, methodArguments)
					if value
						return value

		# If there is no grammar available, we try to parse the date.
		[from, to] = input.split(/\s+\-\s+/)
		if from and to
			output = CUI.DateTimeRangeGrammar.range(from, to)
			if output
				return output

		output = CUI.DateTimeRangeGrammar.getFromTo(from)
		if output
			return output

		return error: "NoDateRangeFound #{input}"


	@millennium: (millennium, isBC) ->
		if isBC
			from = -(millennium * 1000 - 1)
			to = -((millennium - 1) * 1000)
		else
			to = millennium * 1000
			from = to - 999
		return CUI.DateTimeRangeGrammar.getFromToWithRange("#{from}", "#{to}")

	@century: (century, isBC) ->
		century = century * 100
		if isBC
			to = -(century - 100)
			from = -century + 1
		else
			to = century
			from = century - 99
		return CUI.DateTimeRangeGrammar.getFromToWithRange("#{from}", "#{to}")

	@centuryRange: (centuryFrom, centuryTo, fromIsBC, toIsBC) ->
		from = @century(centuryFrom, fromIsBC)
		to = @century(centuryTo, toIsBC)
		return from: from.from, to: to.to

	# 15 -> 1401 - 1416
	# 15 -> 1499 1484
	@earlyCentury: (century, isBC) ->
		century = century * 100
		if isBC
			from = -century + 1
			to = from + 15
		else
			from = century - 99
			to = from + 15
		return CUI.DateTimeRangeGrammar.getFromToWithRange("#{from}", "#{to}")

	# 15 - -1416 -1401
	# 15 - 1484 - 1499
	@lateCentury: (century, isBC) ->
		century = century * 100
		if isBC
			to = -(century - 101)
			from = to - 15
		else
			to = century
			from = to - 15

		return CUI.DateTimeRangeGrammar.getFromToWithRange("#{from}", "#{to}")

	@range: (from, to, fromBC = false, toBC = false) ->
		if toBC and not to.startsWith(CUI.DateTimeRangeGrammar.DASH)
			to = @__toBC(to)

		if (fromBC or toBC) and not from.startsWith(CUI.DateTimeRangeGrammar.DASH)
			from = @__toBC(from)

		return CUI.DateTimeRangeGrammar.getFromToWithRange(from, to)
		
	@yearRange: (year, isBC = false, fromAddYears = false, toAddYears = false) ->
		if isBC and not year.startsWith(CUI.DateTimeRangeGrammar.DASH)
			year = "-#{year}"

		momentInputFrom = CUI.DateTimeRangeGrammar.getMoment(year)
		if not momentInputFrom?.isValid()
			return

		if fromAddYears or toAddYears
			_year = momentInputFrom.year()
			if _year % 1000 == 0
				yearsToAdd = 500
			else if _year % 100 == 0
				yearsToAdd = 50
			else if _year % 50 == 0
				yearsToAdd = 15
			else if _year % 10 == 0
				yearsToAdd = 5
			else
				yearsToAdd = 2

		momentInputTo = momentInputFrom.clone()

		if fromAddYears
			momentInputFrom.add(-yearsToAdd, "year")
		if toAddYears
			momentInputTo.add(yearsToAdd, "year")

		momentInputFrom.startOf("year")
		momentInputTo.endOf("year")

		from = CUI.DateTimeRangeGrammar.format(momentInputFrom)
		to = CUI.DateTimeRangeGrammar.format(momentInputTo)

		return from: from, to: to

	@getFromTo: (inputString, isBC = false) ->
		if isBC and not inputString.startsWith(CUI.DateTimeRangeGrammar.DASH)
			inputString = @__toBC(inputString)

		momentInput = CUI.DateTimeRangeGrammar.getMoment(inputString)

		if not momentInput?.isValid()
			return

		if inputString.match(CUI.DateTimeRangeGrammar.REGEXP_YEAR)
			from = to = CUI.DateTimeRangeGrammar.format(momentInput)
		else if inputString.match(CUI.DateTimeRangeGrammar.REGEXP_MONTH)
			from = CUI.DateTimeRangeGrammar.format(momentInput, false)
			momentInput.endOf('month');
			to = CUI.DateTimeRangeGrammar.format(momentInput, false)
		else
			from = to = CUI.DateTimeRangeGrammar.format(momentInput, false)

		return from: from, to: to

	@getFromToWithRange: (fromDate, toDate) ->
		from = CUI.DateTimeRangeGrammar.getFromTo(fromDate)
		to = CUI.DateTimeRangeGrammar.getFromTo(toDate)
		if not from or not to
			return

		return from: from.from, to: to.to

	@format: (dateMoment, yearFormat = true) ->
		if yearFormat
			outputType = CUI.DateTimeRangeGrammar.OUTPUT_YEAR
		else
			outputType = CUI.DateTimeRangeGrammar.OUTPUT_DATE

		return CUI.DateTime.format(dateMoment, CUI.DateTimeRangeGrammar.STORE_FORMAT, outputType)

	@getMoment: (inputString) ->
		if not CUI.util.isString(inputString)
			return

		dateTime = new CUI.DateTime()
		momentInput = dateTime.parseValue(inputString);
		dateTime.destroy()
		return momentInput

	@__toBC: (inputString) ->
		if inputString.match(CUI.DateTimeRangeGrammar.REGEXP_YEAR)
			inputString = parseInt(inputString) - 1
		return "-#{inputString}"