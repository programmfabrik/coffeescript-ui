###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###
CoordinatesParser = require('coordinate-parser');
CoordinatesFormat = require('formatcoords');

marked = require('marked')
moment = require('moment')

class CUI.util

	@assert: (condition, caller, message, debug_output) ->
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

			console.debug.apply(console, args)

		if parms.length
			msg = "#{caller}(#{parms.join(",")})"
		else
			msg = caller

		if message
			msg += ": #{message}"

		# msg += "\nCallstack:\n"+stack+"\n"
		#
		switch CUI.defaults.asserts_alert
			when 'debugger'
				debugger
			when 'js'
				alert(msg)
			when 'cui'
				CUI.problem(text: msg)
			else
				; # ignore 'off' or other values

		if CUI.__in_error
			console.error("Another assert occurred, cannot throw Error to avoid loop: ", msg)
			return

		CUI.__in_error = true

		CUI.setTimeout =>
			CUI.__in_error = false

		throw(new Error(msg))


	@assertImplements: (inst, methods) ->
		if not CUI.defaults.asserts
			return

		needs = []
		for method in methods
			if not CUI.util.isFunction(inst[method])
				needs.push(method)
		CUI.util.assert(needs.length == 0, "#{CUI.util.getObjectClass(inst)}", "Needs implementations for #{needs.join(', ')}.", instance: inst)
		return

	@assertInstanceOf: (variableName, classClass, value) ->
		if not CUI.defaults.asserts
			return

		if not CUI.util.isFunction(classClass) and not classClass == "PlainObject"
			throw "assertInstanceOf: class is not a Function"

		if classClass == "Array"
			cn = "Array"
			cond = value instanceof Array
		else if classClass == "Integer"
			cn = "Integer"
			cond = CUI.util.isInteger(value)
		else if classClass == "PlainObject"
			cn = "PlainObject"
			cond = CUI.util.isPlainObject(value)
		else if (new String) instanceof classClass
			cn = "String"
			cond = CUI.util.isString(value)
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
			fn = CUI.util.getObjectClass(@)

		CUI.util.assert(false, "new #{fn}", "opts.#{variableName} needs to be instance of #{cn} but it is #{CUI.util.getObjectClass(value)}.", value: value, classClass: classClass)
		return

	@$elementIsInDOM: ($el) ->
		parents = CUI.dom.parents($el)
		lastParent = parents[parents.length - 1]
		return CUI.dom.is(lastParent, "html")

	# for our self repeating mousemove event we
	# track a scrollPageX and scrollPageY offset
	# from our own dragscroller
	@getCoordinatesFromEvent: (ev) ->
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
	@elementGetPosition: (coordinates, el) ->
		rect = CUI.dom.getRect(el)
		# console.debug(coordinates.pageX, coordinates.pageY, offset);
		position =
			left: coordinates.pageX  - rect.left # (offset.left + $el.cssInt("border-left-width"))
			top: coordinates.pageY - rect.top # (offset.top + $el.cssInt("border-top-width"))

		if el != document.body
			position.left += el.scrollLeft
			position.top += el.scrollTop

		return position

	@getObjectClassRegexp: /^function\s*(\w+)/

	# Returns the class name of the argument or undefined if
	# it's not a valid JavaScript object.
	@getObjectClass: (obj) ->
		if not obj or not obj.constructor
			return undefined

		if CUI.browser.ie
			str = obj.constructor.toString().trim()
			if str.substr(0, 8) == "function"
				arr = str.match(CUI.util.getObjectClassRegexp)
				if arr and arr.length == 2
					return arr[1]
				else
					return undefined
			else
				return undefined
		else
			return obj.constructor.name

	@isUndef: (obj) ->
		(typeof obj == "undefined")

	@isNull: (obj) ->
		(CUI.util.isUndef(obj) or obj == null)

	@isString: (obj) ->
		(typeof obj == "string")

	@isJSON: (obj) ->
		if not @isString(obj)
			return false
		try
			JSON.parse(obj)
			return true

		return false

	@isEmpty: (obj) ->
		if CUI.util.isArray(obj)
			obj.length == 0
		else if CUI.util.isPlainObject(obj)
			CUI.util.isEmptyObject(obj)
		else
			(CUI.util.isNull(obj) || obj == "" || obj == false)

	@isTrue: (obj) ->
		(!CUI.util.isNull(obj) && (obj == 1 || obj == true || obj == "1" || obj == "true"))

	@isFalse: (obj) ->
		(CUI.util.isNull(obj) || obj == 0 || obj == false || obj == "0" || obj == "false")

	@isBoolean: (obj) ->
		obj == true or obj == false

	@isElement: (obj) ->
		obj instanceof HTMLElement

	@isPosInt: (obj) ->
		CUI.util.isInteger(obj) and obj >= 0

	@isContent: (obj) ->
		CUI.util.isElement(obj) or obj instanceof HTMLCollection or obj instanceof NodeList or CUI.util.isArray(obj) or CUI.util.isFunction(obj) or CUI.util.isElement(obj?.DOM)

	@isNumber: (n) ->
		CUI.util.isInteger(n) or CUI.util.isFloat(n)

	@isFloat: (n) ->
		`n===+n && n!==(n|0)`

	@isInteger: (n) ->
		Number.isInteger(n)

	@isPromise: (n) ->
		n instanceof CUI.Promise or n instanceof CUI.Deferred

	@isDeferred: (n) ->
		n instanceof CUI.Deferred

	@escapeRegExp: (str) ->
		str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")

	@getIntOrString: (s) ->
		CUI.util.getInt(s, true)

	@getInt: (s, ret_as_is=false) ->
		if CUI.util.isNull(s)
			return null

		i = parseInt(s)
		if isNaN(i) or (i+"").length != (s+"").trim().length
			if ret_as_is
				return s
			else
				return null
		return i

	@getFloat: (s) ->
		if CUI.util.isNull(s)
			return null

		f = parseFloat(s)
		if isNaN(f)
			null
		else
			f

	@xor: (a,b) ->
		!!((a && !b) || (!a && b))

	@toHtml: (data, space2nbsp) ->
		if CUI.util.isNull(data) or !CUI.util.isString(data)
			return ""

		data = data.replace(/&/g, "&amp;").replace(/\'/g, "&#39;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/\"/g, "&quot;")

		if space2nbsp
			data.replace(/\s/g, "&nbsp;")
		else
			data

	@copyObject: (obj, deep = false, level = 0) ->

		if level > 100
			console.error("CUI.util.copyObject: ***Recursion protection after 100 levels.***")
			return

		if typeof(obj) in ["string", "number", "boolean", "function"]
			return obj

		if CUI.util.isNull(obj)
			return obj

		if obj instanceof CUI.Element
			if level == 0 or deep
				return obj.copy()
			else
				return obj

		if obj instanceof HTMLElement
			if obj.cloneNode
				return obj.cloneNode(true)
			return obj

		if obj instanceof CUI.Dummy
			return obj

		if CUI.util.isPlainObject(obj)
			new_obj = {}
			for k, v of obj
				if deep
					try
						new_obj[k] = CUI.util.copyObject(v, true, level+1)
					catch e
						console.error "Error during Object copy:", e.toString(), "Key:", k, "Object:", obj
						throw(e)
				else
					new_obj[k] = v

			return new_obj

		if CUI.util.isArray(obj)
			if !deep
				return obj.slice(0)

			new_arr = []
			for o in obj
				new_arr.push(CUI.util.copyObject(o, true, level+1))

			return new_arr

		CUI.util.assert(false, "copyObject", "Only {},[],string, boolean, and number can be copied. Object is: #{CUI.util.getObjectClass(obj)}", obj: obj, deep: deep)

	@copyObjectV2 = (obj, deep = false, visited = new WeakMap()) ->
		# Handle primitives, functions, and null values.
		if obj is null or typeof obj in ['string', 'number', 'boolean', 'function']
			return obj

		# If the object has already been copied, return its copy to handle cyclic references.
		if visited.has(obj)
			return visited.get(obj)

		if CUI.util.isNull(obj)
			return obj

		# Special handling for CUI.Element objects.
		if obj instanceof CUI.Element
			result = if deep then obj.copy() else obj
			visited.set(obj, result)
			return result

		# Special handling for HTMLElement objects.
		if obj instanceof HTMLElement
			result = if obj.cloneNode then obj.cloneNode(true) else obj
			visited.set(obj, result)
			return result

		# Special handling for CUI.Dummy objects.
		if obj instanceof CUI.Dummy
			visited.set(obj, obj)
			return obj

		# If the object is a plain object.
		if CUI.util.isPlainObject(obj)
			copy = {}
			visited.set(obj, copy)
			for key, value of obj when obj.hasOwnProperty(key)
				copy[key] = if deep then @copyObjectV2(value, true, visited) else value
			return copy

		# If the object is an array.
		if CUI.util.isArray(obj)
			copy = []
			visited.set(obj, copy)
			for element in obj
				copy.push(if deep then @copyObjectV2(element, true, visited) else element)
			return copy

		# If the object type is unsupported, throw an error.
		CUI.util.assert false, "copyObjectV2", "Only plain objects, arrays, strings, booleans, numbers, and functions can be copied. Object is: #{CUI.util.getObjectClass(obj)}", { obj: obj, deep: deep }

	@dump: (obj, space="\t") ->
		clean_obj = (obj) ->
			if CUI.util.isArray(obj)
				result = []
				for item in obj
					result.push(clean_obj(item))
				return result
			else if CUI.util.isPlainObject(obj)
				result = {}
				for k, v of obj
					result[k] = clean_obj(v)
				return result
			else if typeof(obj) in ["string", "number", "boolean"]
				return obj
			else if CUI.util.isUndef(obj)
				return "<undefined>"
			else if CUI.util.isNull(obj)
				return "<null>"
			else
				return CUI.util.getObjectClass(obj)

		try
			return JSON.stringify(clean_obj(obj), null, space)
		catch e
			console.error(e)
			return "Unable to dump object"

	@alert_dump: (v) -> alert(CUI.util.dump(v, "    "))


	# convert camel case to dash
	@toDash: (s) ->
		s = s + "U"
		s1 = (s.substring(0,1) + s.substring(1).replace(/([A-Z](?![A-Z0-9]))/g, ($1)->"-#{$1.toLowerCase()}"))
		s1 = s1.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase()
		s1 = s1.substring(0,s1.length-2)
		s1.replace(/\./g, "-")


	# convert to class compatible string
	@toClass: (s) ->
		CUI.util.toDash(s).replace(/_/g,"-").replace(/\s+/g, "-")

	# convert to class compatible string
	@toDot: (s) ->
		CUI.util.toDash(s).replace(/-/g,".")

	# convert dash to camel
	@toCamel: (s, includeFirst=false) ->
		if includeFirst
			s.replace /((\-|^)[a-z])/g, ($1)-> $1.toUpperCase().replace('-','')
		else
			s.replace /(\-[a-z])/g, ($1)-> $1.toUpperCase().replace('-','')

	# remove all occurrances of value from array
	# returns the number of items removed
	@removeFromArray: (value, arr, compFunc) ->
		CUI.util.assert(CUI.util.isArray(arr), "removeFromArray", "Second parameter needs to be an Array", value: value, array: arr, compFunc: compFunc)
		removed = 0
		while true
			idx = CUI.util.idxInArray(value, arr, compFunc)
			if idx > -1
				arr.splice(idx, 1)
				removed++
			else
				break
		removed

	@moveInArray: (from, to, arr, after = false) ->
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
	@compareIndex: (a_idx, b_idx) ->
		if a_idx < b_idx
			-1
		else if a_idx > b_idx
			1
		else
			0

	# pushes value onto array, if not exists
	# returns index of the pushed value
	@pushOntoArray: (value, arr, compFunc) ->
		idx = CUI.util.idxInArray(value, arr, compFunc)
		if idx == -1
			arr.push(value)
			return arr.length-1
		else
			return idx

	@idxInArray: (value, arr, compFunc) ->
		if not compFunc
			return arr.indexOf(value)

		idx = -1
		# compFunc needs to be a method name or a function
		for a, i in arr
			if CUI.util.isFunction(compFunc)
				if compFunc(a, value)
					idx = i
					break
			else if a[compFunc](value)
				idx = i
				break
		idx

	@findInArray: (value, arr, compFunc) ->
		idx = CUI.util.idxInArray(value, arr, compFunc)
		if idx == -1
			undefined
		else
			arr[idx]

	# ucs-2 string to base64 encoded ascii
	@utoa: (str) ->
		window.btoa(unescape(encodeURIComponent(str)))

	# base64 encoded ascii to ucs-2 string
	@atou: (str) ->
		decodeURIComponent(escape(window.atob(str)))

	# coordinates is a string, almost every coordinates format is accepted.
	# Returns an object with lat and lng attributes, or false if wasn't possible to parse or if coordinates is null.
	@parseCoordinates: (coordinates) ->
		if CUI.util.isNull(coordinates)
			return false

		CUI.util.assert(CUI.util.isString(coordinates), "parseCoordinates", "Parameter coordinates is String and mandatory.", value: coordinates)

		try
			coordinates = new CoordinatesParser(coordinates)
			position = lat: coordinates.getLatitude(), lng: coordinates.getLongitude()
			if CUI.Map.isValidPosition(position)
				return position
			else
				return false
		catch
			return false

	# coordinates is a PlainObject with lat and lng attributes, format is a string which indicates what format will be used.
	# It is possible that format be a function, and it is invoked with coordinates as parameter.
	# Returns a string formatted.
	@formatCoordinates: (coordinates, format) ->
		CUI.util.assert(CUI.Map.isValidPosition(coordinates), "formatCoordinates", "Coordinates must be a valid position object, with latitude and longitude attributes.", value: coordinates)

		if CUI.util.isFunction(format)
			return format(coordinates)

		CUI.util.assert(CUI.util.isString(format) and not CUI.util.isEmpty(format), "formatCoordinates", "Parameter format is String, mandatory and not empty.", value: coordinates)

		coordinates = CoordinatesFormat(coordinates.lat, coordinates.lng)
		return coordinates.format(format)

	@isArray: (v) ->
		Array.isArray(v)

	@inArray: (value, array) ->
		array.indexOf(value)

	@isEqual: (x, y, debug) ->
		#// if both are function
		if x instanceof Function
			if y instanceof Function
				return x.toString() == y.toString()
			return false

		if x == null or x == undefined or y == null or y == undefined
			return x == y

		if x == y or x.valueOf() == y.valueOf()
			return true

		# if one of them is date, they must had equal valueOf
		if x instanceof Date
			return false

		if y instanceof Date
			return false

		# if they are not function or strictly equal, they both need to be Objects
		if not (x instanceof Object)
			return false

		if not (y instanceof Object)
			return false

		p = Object.keys(x)
		if Object.keys(y).every( (i) -> return p.indexOf(i) != -1 )
			return p.every((i) =>
				eq = @isEqual(x[i], y[i], debug)
				if not eq
					if debug
						console.debug("X: ",x)
						console.debug("Differs to Y:", y)
						console.debug("Key differs: ", i)
						console.debug("Value X:", x[i])
						console.debug("Value Y:", y[i])
					return false
				else
					return true
			)
		else
			return false


	@isMap: (v) ->
		@isPlainObject(v)

	@isFunction: (v) ->
		v and typeof(v) == "function"

	@isPlainObject: (v) ->
		v and typeof(v) == "object" and v.constructor?.prototype.hasOwnProperty("isPrototypeOf")

	@isEmptyObject: (v) ->
		for k of v
			return false
		return true

	@revertMap: (map) ->
		map_reverted = {}
		for k, v of map
			map_reverted[v] = k
		map_reverted

	@stringMapReplace: (s, map) ->
		regex = []
		for key of map
			if CUI.util.isEmpty(key)
				continue
			regex.push(key.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&"))

		if regex.length > 0
			s.replace(new RegExp(regex.join('|'),"g"), (word) -> map[word])
		else
			s

	# mergeMap merges mergeMap values to targetMap, if
	# the targetMap does not contain a value
	@mergeMap: (targetMap, mergeMap) ->
		for k, v of mergeMap
			if not targetMap.hasOwnProperty(k)
				targetMap[k] = v
			else if CUI.util.isPlainObject(targetMap[k]) and CUI.util.isPlainObject(v)
				CUI.util.mergeMap(targetMap[k], v)
		targetMap

	@copyToClipboard: (text) ->
		if not text
			return

		textarea = CUI.dom.element("textarea",
			style:
				position: 'absolute'
				left: '-9999px'
		)
		textarea.value = text
		CUI.dom.append(document.body, textarea)
		textarea.select()
		document.execCommand('copy')
		CUI.dom.remove(textarea)
		return

	# removePropertyRecursively removes a property from an object recursively
	@removePropertyRecursively: (obj, propertyToRemove, seen = new Set()) ->
		# If the object has already been seen, exit to avoid circular references
		return if seen.has(obj)

		# Add the current object to the set of seen objects
		seen.add(obj)

		# If the object is an array, iterate over it
		if Array.isArray(obj)
			for item in obj
				CUI.util.removePropertyRecursively(item, propertyToRemove, seen)  # Recursively for each element in the array
		# If it's an object
		else if typeof obj is 'object' and obj isnt null
			# Iterate over all properties of the object
			for key, value of obj
				# If we find the property to remove, delete it
				if key is propertyToRemove
					delete obj[key]
				# If the property is another object or array, call the function recursively
				else if typeof value is 'object'
					CUI.util.removePropertyRecursively(value, propertyToRemove, seen)

CUI.util.moment = moment
CUI.util.marked = marked

String.prototype.startsWith = (s) ->
	@substr(0, s.length) == s

String.prototype.startsWithIgnoreCase = (s) ->
	@toUpperCase().startsWith(s.toUpperCase())

String.prototype.endsWith = (s) ->
	@substr(@length-s.length) == s

RegExp.escape= (s) ->
    s.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')
