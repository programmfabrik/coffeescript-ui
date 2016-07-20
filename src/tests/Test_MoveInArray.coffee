class Test_MoveInArray extends CUI.Test
	run: ->
		super()
		#
		@test =>
			a = [0,1,2,3,4]
			moveInArray(0, 1, a)
			@eq(a, [0,1,2,3,4])

		@test =>
			a = [0,1,2,3,4]
			moveInArray(0, 2, a)
			@eq(a, [1,0,2,3,4])

		@test =>
			a = [0,1,2,3,4]
			moveInArray(0, 3, a)
			@eq(a, [1,2,0,3,4])

		@test =>
			a = [0,1,2,3,4]
			moveInArray(1, 0, a)
			@eq(a, [1,0,2,3,4])

		@test =>
			a = [0,1,2,3,4,5]
			moveInArray(0, 5, a, true)
			@eq(a, [1,2,3,4,5,0])

		@test =>
			a = [0,1,2,3,4,5]
			moveInArray(0, 5, a)
			@eq(a, [1,2,3,4,0,5])

		@test =>
			a = [0,1,2,3,4,5]
			moveInArray(0, 6, a)
			@eq(a, [1,2,3,4,5,0])

		@test =>
			a = [0,1,2,3,4]
			moveInArray(2, 3, a)
			@eq(a, [0,1,2,3,4])

		@test =>
			a = [0,1,2,3,4]
			moveInArray(3, 3, a)
			@eq(a, [0,1,2,3,4])

		@test =>
			a = [0,1,2,3,4]
			moveInArray(3, 3, a, true)
			@eq(a, [0,1,2,3,4])

		@test =>
			a = [0,1,2,3,4]
			moveInArray(3, 1, a)
			@eq(a, [0,3,1,2,4])

		@test =>
			a = [0,1,2,3,4,5]
			moveInArray(3, 4, a, true)
			@eq(a, [0,1,2,4,3,5])


		@test =>
			a = [0,1,2,3,4]
			moveInArray(3, 1, a, true)
			@eq(a, [0,1,3,2,4])

		@test =>
			a = [0,1,2,3,4]
			moveInArray(0, 3, a, true)
			@eq(a, [1,2,3,0,4])

		@test =>
			a = [0,1,2,3,4]
			moveInArray(0, 4, a, true)
			@eq(a, [1,2,3,4,0])

CUI.Test.register(new Test_MoveInArray())
