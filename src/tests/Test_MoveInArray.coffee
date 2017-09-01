###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Test.Test_MoveInArray extends CUI.Test
	run: ->
		super()
		#
		@test =>
			a = [0,1,2,3,4]
			CUI.util.moveInArray(0, 1, a)
			@eq(a, [0,1,2,3,4])

		@test =>
			a = [0,1,2,3,4]
			CUI.util.moveInArray(0, 2, a)
			@eq(a, [1,0,2,3,4])

		@test =>
			a = [0,1,2,3,4]
			CUI.util.moveInArray(0, 3, a)
			@eq(a, [1,2,0,3,4])

		@test =>
			a = [0,1,2,3,4]
			CUI.util.moveInArray(1, 0, a)
			@eq(a, [1,0,2,3,4])

		@test =>
			a = [0,1,2,3,4,5]
			CUI.util.moveInArray(0, 5, a, true)
			@eq(a, [1,2,3,4,5,0])

		@test =>
			a = [0,1,2,3,4,5]
			CUI.util.moveInArray(0, 5, a)
			@eq(a, [1,2,3,4,0,5])

		@test =>
			a = [2,1]
			CUI.util.moveInArray(0, 1, a)
			@eq(a, [2,1])

		@test =>
			a = [0,1,2,3,4,5]
			CUI.util.moveInArray(0, 6, a)
			@eq(a, [1,2,3,4,5,0])

		@test =>
			a = [0,1,2,3,4]
			CUI.util.moveInArray(2, 3, a)
			@eq(a, [0,1,2,3,4])

		@test =>
			a = [0,1,2,3,4]
			CUI.util.moveInArray(3, 3, a)
			@eq(a, [0,1,2,3,4])

		@test =>
			a = [0,1,2,3,4]
			CUI.util.moveInArray(3, 3, a, true)
			@eq(a, [0,1,2,3,4])

		@test =>
			a = [0,1,2,3,4]
			CUI.util.moveInArray(3, 1, a)
			@eq(a, [0,3,1,2,4])

		@test =>
			a = [0,1,2,3,4,5]
			CUI.util.moveInArray(3, 4, a, true)
			@eq(a, [0,1,2,4,3,5])


		@test =>
			a = [0,1,2,3,4]
			CUI.util.moveInArray(3, 1, a, true)
			@eq(a, [0,1,3,2,4])

		@test =>
			a = [0,1,2,3,4]
			CUI.util.moveInArray(0, 3, a, true)
			@eq(a, [1,2,3,0,4])

		@test =>
			a = [0,1,2,3,4]
			CUI.util.moveInArray(0, 4, a, true)
			@eq(a, [1,2,3,4,0])

CUI.Test.register(new CUI.Test.Test_CUI.util.moveInArray())
