class CUI.Test
	constructor: ->

	run: ->
		@idx = 0

	eq: (a, b) ->
		if JSON.stringify(a) == JSON.stringify(b)
			CUI.info("Test passed: eq: ", a, b)
			return true
		CUI.error("Test failed: eq: ", a, b, @test_func.toString())

	test: (@test_func) ->
		# CUI.info getObjectClass(@)+"##{@idx}", f.toString()
		@test_func()
		@idx++

	@tests: []

	@register: (test) ->
		assert(test instanceof Test, "Test.register", "Test needs to be instance of Test", test: test)
		test.idx = @tests.length
		@tests.push(test)

	@run: ->
		for test in @tests
			CUI.info("Running Test", getObjectClass(test))
			test.run()
		return
