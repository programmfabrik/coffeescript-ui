###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###


assert = (condition, caller, message, debug_output) ->
	if not CUI.defaults.asserts
		return

	if condition
		return

	#TODO find a way to make it more readable (one function per line) . e.g. cut away the server name or make the alert box bigger.
	try
		e = new Error('dummy')
		stack = e.stack.replace(/^[^\(]+?[\n$]/gm, '')
			.replace(/^\s+at\s+/gm, '')
			.replace(/^Object.<anonymous>\s*\(/gm, '{anonymous}()@')
			.replace()
			.split('\n');
	catch e
		stack = "Can't get callstack in this browser. Try using Stacktrace.js"


	parms = []
	if debug_output
		args = [ "#{caller}:" ]
		for key, value of debug_output
			args.push("#{key}:")
			parms.push(key)
			args.push(value)

		CUI.debug.apply(console, args)

	if parms.length
		msg = "#{caller}(#{parms.join(",")})"
	else
		msg = caller

	if message
		msg += ": #{message}"

	# msg += "\nCallstack:\n"+stack+"\n"
	if false and CUI.problem
		CUI.problem(title: "ASSERT", text: msg)
	else
		alert(msg)

	throw new Error(msg)

assertImplements = (inst, methods) ->
	if not CUI.defaults.asserts
		return

	needs = []
	for method in methods
		if not CUI.isFunction(inst[method])
			needs.push(method)
	assert(needs.length == 0, "#{getObjectClass(inst)}", "Needs implementations for #{needs.join(', ')}.", instance: inst)
	return


assertInstanceOf = (variableName, classClass, opts, value=undefined) ->
	if not CUI.defaults.asserts
		return

	if not CUI.isFunction(classClass) and not classClass == "PlainObject"
		throw "assertInstanceOf: class is not a Function"

	if value == undefined
		value = opts[variableName]
		assert(CUI.isPlainObject(opts), "new #{arguments.callee.caller.name}", "opts needs to be PlainObject but it is #{getObjectClass(opts)}.", opts: opts)

	if classClass == "Array"
		cn = "Array"
		cond = value instanceof Array
	else if classClass == "Integer"
		cn = "Integer"
		cond = isInteger(value)
	else if classClass == "PlainObject"
		cn = "PlainObject"
		cond = CUI.isPlainObject(value)
	else if (new String) instanceof classClass
		cn = "String"
		cond = isString(value)
	else if (new Boolean) instanceof classClass
		cn = "Boolean"
		cond = value == true or value == false
	else
		cond = value instanceof classClass
		cn = classClass.name

	if cond
		return

	fn = arguments.callee.caller.name
	if not fn
		fn = getObjectClass(@)

	assert(false, "new #{fn}", "opts.#{variableName} needs to be instance of #{cn} but it is #{getObjectClass(value)}.", opts: opts, value: value, classClass: classClass)
	return


$elementIsInDOM = ($el) ->
	$el.parents().last().is("html")

# for our self repeating mousemove event we
# track a scrollPageX and scrollPageY offset
# from our own dragscroller
getCoordinatesFromEvent = (ev) ->
	coord =
		pageX: ev.pageX()
		pageY: ev.pageY()

	# scrollPageX and scrollPageY are faked attributes
	# which are set by DragDropSelect
	if ev.scrollPageY
		coord.pageY += ev.scrollPageY
	if ev.scrollPageX
		coord.pageX += ev.scrollPageX
	coord


# return the difference of the absolute position
# of coordinates and element
elementGetPosition = (coordinates, el) ->
	rect = DOM.getRect(el)
	# CUI.debug(coordinates.pageX, coordinates.pageY, offset);
	position =
		left: coordinates.pageX  - rect.left # (offset.left + $el.cssInt("border-left-width"))
		top: coordinates.pageY - rect.top # (offset.top + $el.cssInt("border-top-width"))

	if el != document.body
		position.left += el.scrollLeft
		position.top += el.scrollTop

	return position



# Returns the class name of the argument or undefined if
# it's not a valid JavaScript object.
getObjectClass = (obj) ->
	if obj and obj.constructor and obj.constructor.toString
        arr = obj.constructor.toString().match(/function\s*(\w+)/)

        if arr and arr.length == 2
            return arr[1]
    return undefined

isUndef = (obj) ->
	(typeof obj == "undefined")

isNull = (obj) ->
	(isUndef(obj) or obj == null)

isString = (obj) ->
	(typeof obj == "string")

isEmpty = (obj) ->
	(isNull(obj) || obj == "")

isTrue = (obj) ->
	(!isNull(obj) && (obj == 1 || obj == true || obj == "1" || obj == "true"))

isFalse = (obj) ->
	(isNull(obj) || obj == 0 || obj == false || obj == "0" || obj == "false")

isBoolean = (obj) ->
	obj == true or obj == false

isElement = (obj) ->
	obj instanceof HTMLElement

isPosInt = (obj) ->
	isInteger(obj) and obj >= 0

isContent = (obj) ->
	isElement(obj) or obj instanceof HTMLCollection or obj instanceof NodeList or CUI.isArray(obj) or CUI.isFunction(obj) or isElement(obj?.DOM)

isNumber = (n) ->
	isInteger(n) or isFloat(n)

isFloat = (n) ->
	`n===+n && n!==(n|0)`

isInteger = (n) ->
	`n===+n && n===(n|0)`

isPromise = (n) ->
	if n instanceof CUI.Promise or n instanceof CUI.Deferred
		true
	else
		false

isDeferred = (n) ->
	if n instanceof CUI.Deferred
		true
	else
		false

escapeRegExp = (str) ->
  str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")

getIntOrString = (s) ->
	getInt(s, true)

getInt = (s, ret_as_is=false) ->
	if isNull(s)
		return null

	i = parseInt(s)
	if isNaN(i) or (i+"").length != (s+"").trim().length
		if ret_as_is
			return s
		else
			return null
	return i

getFloat = (s) ->
	if isNull(s)
		return null

	f = parseFloat(s)
	if isNaN(f)
		null
	else
		f

xor = (a,b) ->
	!!((a && !b) || (!a && b))

toHtml = (data, space2nbsp) ->
	if isNull(data) or !isString(data)
		return ""

	data = data.replace(/&/g, "&amp;").replace(/\'/g, "&#39;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/\"/g, "&quot;")

	if space2nbsp
		data.replace(/\s/g, "&nbsp;")
	else
		data


copyObject = (obj, deep = false, level = 0) ->
	if typeof(obj) in ["string", "number", "boolean", "function"]
		return obj

	if isNull(obj)
		return obj

	if obj instanceof CUI.Element
		if level == 0 or deep
			return obj.copy()
		else
			return obj

	if obj instanceof HTMLElement
		return obj

	if obj instanceof CUI.Dummy
		return obj

	if CUI.isPlainObject(obj)
		new_obj = {}
		for k, v of obj
			if deep
				try
					new_obj[k] = copyObject(v, true, level+1)
				catch e
					console.error "Error during Object copy:", e.toString(), "Key:", k, "Object:", obj
					throw(e)
			else
				new_obj[k] = v

		return new_obj

	if CUI.isArray(obj)
		if !deep
			return obj.slice(0)

		new_arr = []
		for o in obj
			new_arr.push(copyObject(o, true, level+1))

		return new_arr

	assert(false, "copyObject", "Only {},[],string, boolean, and number can be copied. Object is: #{getObjectClass(obj)}", obj: obj, deep: deep)

dump = (obj, space="\t") ->
	clean_obj = (obj) ->
		if CUI.isArray(obj)
			result = []
			for item in obj
				result.push(clean_obj(item))
			return result
		else if CUI.isPlainObject(obj)
			result = {}
			for k, v of obj
				result[k] = clean_obj(v)
			return result
		else if typeof(obj) in ["string", "number", "boolean"]
			return obj
		else if isUndef(obj)
			return "<undefined>"
		else if isNull(obj)
			return "<null>"
		else
			return getObjectClass(obj)

	try
		return JSON.stringify(clean_obj(obj), null, space)
	catch e
		CUI.error(e)
		return "Unable to dump object"
alert_dump = (v) -> alert(dump(v, "    "))


# convert camel case to dash
toDash = (s) ->
	s = s + "U"
	s1 = (s.substring(0,1) + s.substring(1).replace(/([A-Z](?![A-Z0-9]))/g, ($1)->"-#{$1.toLowerCase()}"))
	s1 = s1.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase()
	s1 = s1.substring(0,s1.length-2)
	s1.replace(/\./g, "-")


# convert to class compatible string
toClass = (s) ->
	toDash(s).replace(/_/g,"-").replace(/\s+/g, "-")

# convert to class compatible string
toDot = (s) ->
	toDash(s).replace(/-/g,".")

# convert dash to camel
toCamel = (s, includeFirst=false) ->
	if includeFirst
		s.replace /((\-|^)[a-z])/g, ($1)-> $1.toUpperCase().replace('-','')
	else
		s.replace /(\-[a-z])/g, ($1)-> $1.toUpperCase().replace('-','')

# remove all occurrances of value from array
# returns the number of items removed
removeFromArray = (value, arr, compFunc) ->
	assert(CUI.isArray(arr), "removeFromArray", "Second parameter needs to be an Array", value: value, array: arr, compFunc: compFunc)
	removed = 0
	while true
		idx = idxInArray(value, arr, compFunc)
		if idx > -1
			arr.splice(idx, 1)
			removed++
		else
			break
	removed

moveInArray = (from, to, arr, after = false) ->
	# console.debug "moveInArray:", from, to , after
	if from == to
		return to

	if from > to
		if after
			to++
	else
		if not after
			to--

	move = arr.splice(from, 1)[0]
	arr.splice(to, 0, move)
	to

# use in sort
compareIndex = (a_idx, b_idx) ->
	if a_idx < b_idx
		-1
	else if a_idx > b_idx
		1
	else
		0

# pushes value onto array, if not exists
# returns index of the pushed value
pushOntoArray = (value, arr, compFunc) ->
	idx = idxInArray(value, arr, compFunc)
	if idx == -1
		arr.push(value)
		return arr.length-1
	else
		return idx

idxInArray = (value, arr, compFunc) ->
	if not compFunc
		return arr.indexOf(value)

	idx = -1
	# compFunc needs to be a method name or a function
	for a, i in arr
		if CUI.isFunction(compFunc)
			if compFunc(a, value)
				idx = i
				break
		else if a[compFunc](value)
			idx = i
			break
	idx

findInArray = (value, arr, compFunc) ->
	idx = idxInArray(value, arr, compFunc)
	if idx == -1
		undefined
	else
		arr[idx]

addToArray = (value, arr, compFunc) ->
	assert(CUI.isArray(arr), "addToArray", "Second parameter needs to be an Array", value: value, array: arr, compFunc: compFunc)
	idx = idxInArray(value, arr, compFunc)
	if idx == -1
		arr.push(value)
		return arr.length - 1
	else
		return idx

String.prototype.startsWith = (s) ->
	@substr(0, s.length) == s

String.prototype.endsWith = (s) ->
	@substr(@length-s.length) == s

Date.prototype.getWeek = (us=false) ->
	if us
		# US week
		start_day = 0
		start_on_jan_1st = true
		days_week_in_next_year = 6
	else
		# get the ISO week
		start_day = 1
		start_on_jan_1st = false
		days_week_in_next_year = 3

	day_offset = 24*60*60*1000
	week_offset = day_offset * 7
	d = new Date(this)
	d.setUTCHours(0,0,0,0)
	current_ms = d.getTime()
	next_year_jan_1st = new Date(d)
	next_year_jan_1st.setUTCFullYear(d.getUTCFullYear()+1,0,1)

	# CUI.debug "asked day", d
	d.setUTCMonth(0,1)
	first_day = d.getUTCDay()
	# CUI.debug "first day", first_day, d
	first_day_of_week_ms = d.getTime() - ((first_day-start_day+7)%7)*day_offset
	if first_day in [5, 6, 0] and not start_on_jan_1st
		first_day_of_week_ms += week_offset
	d.setTime(first_day_of_week_ms)

	if (next_year_jan_1st.getTime()-current_ms) / day_offset <= days_week_in_next_year
		week_no = 1
	else
		week_no = Math.floor((current_ms - first_day_of_week_ms) / week_offset) + 1
	# CUI.debug "first day of week", d.getUTCFullYear(), d
	# CUI.debug "next jan 1st", next_year_jan_1st, (next_year_jan_1st.getTime()-current_ms) / day_offset
	# CUI.debug "diff_ms", current_ms - first_day_of_week_ms, week_no
	week_no


getMs = ->
	(new Date()).getTime()

RegExp.escape= (s) ->
    s.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')
