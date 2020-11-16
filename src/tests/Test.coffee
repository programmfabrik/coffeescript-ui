###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Test
	constructor: ->

	run: ->
		@idx = 0

	eq: (a, b) ->
		if JSON.stringify(a) == JSON.stringify(b)
			console.info("Test passed: eq: ", a, b)
			return true
		console.error("Test failed: eq: ", a, b, @test_func.toString())

	test: (@test_func) ->
		# console.info CUI.util.getObjectClass(@)+"##{@idx}", f.toString()
		@test_func()
		@idx++

	@tests: []

	@register: (test) ->
		CUI.util.assert(test instanceof Test, "Test.register", "Test needs to be instance of Test", test: test)
		test.idx = @tests.length
		@tests.push(test)

	@run: ->
		for test in @tests
			console.info("Running Test", CUI.util.getObjectClass(test))
			test.run()
		return
