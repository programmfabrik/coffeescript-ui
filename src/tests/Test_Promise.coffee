class CUI.Test_Promise extends CUI.Test
	run: ->

		# p = new Promise((resolve, reject) ->
		# 	CUI.setTimeout
		# 		ms: 1000
		# 		call: =>
		# 			p.then (v1) =>
		# 				console.debug "hello2", v1
		# 				p.then (v1) =>
		# 					console.debug "hello3", v1
		# 				console.debug "hello4", v1

		# 			console.debug "resolve yo1"
		# 			resolve("yo1")
		# )

		# p.then (v1) =>
		# 	console.debug "hello1", v1


		p = new Promise((resolve, reject) ->
			CUI.setTimeout
				call: =>
					p.then (v1) =>
						console.debug "hello2", v1
						p.then (v1) =>
							console.debug "hello3", v1
						console.debug "hello4", v1
					console.debug "resolve yo2"
					resolve("yo2")
		)

		p.then (v1) =>
			console.debug "hello1", v1


		dfr = new CUI.Deferred()
		dfr.done (v1) =>
			console.debug "dfr1", v1

		dfr.done (v1) =>
			console.debug "dfr2", v1
			dfr.done (v1) =>
				console.debug "dfr3", v1
			console.debug "dfr4", v1

		dfr.resolve("yo3")

		return





CUI.Test.register(new CUI.Test_Promise())
