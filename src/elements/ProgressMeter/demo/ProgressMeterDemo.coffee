class ProgressMeterDemo extends Demo

	getName: () ->
		"ProgressMeter & Waitblock"

	display: ->

		@demo_table = new DemoTable("progressmeter-demo-table")

		@createProgressMeterExample()

		@createWaitBlockExample()

		@demo_table.table


	__table: null

	createWaitBlockExample: ->
		@__wait_block_container = $div("cui-waiting-block-demo")

		#make sure __wait_block_container has position: relative or absolute in its style! otherwise waitblock gets fullscreen
		wait_block = new WaitBlock(element: @__wait_block_container )
		wait_block.show()

		controls = [
			new Buttonbar
				buttons: [
					new Button
						text: "Wait"
						group: "a"
						onClick: ->
							wait_block.show()
				,
					new Button
						text: "Stop Waiting"
						group: "a"
						onClick: ->
							wait_block.hide()
				]
			.DOM
		]


		@demo_table.addExample("Wait Block", @__wait_block_container, controls)


	createProgressMeterExample: ->
		progress_meter = new ProgressMeter
			class: "cui-progress-meter-demo"
			#TODO demo is not showing this icons currently
			icon_waiting: "fa-spinner"
			icon_spinning: "fa-spinner cui-spin-stepped"


		stepMeter = (startover=false) ->
			state = progress_meter.getState()
			next_timeout_ms = 100
			if state == 100
				#finished 'loading'
				state = "spinning"
			else if startover
				#begin 'loading' by setting state as number
				state = 0
			else if state != "waiting" and  state != "spinning"
				#means that state is now a number that we use to count the progress!
				next_timeout_ms = 10
				state++
			progress_meter.setState(state)
			CUI.setTimeout(stepMeter, next_timeout_ms)

		DOM.waitForDOMInsert(node: progress_meter)
		.done =>
			assert( $elementIsInDOM(progress_meter.DOM),"progress_meter gets DOM insert event without being in DOM." )
			stepMeter(true)

		parent_meter_container = $div("cui-progress-meter-demo-container").append(progress_meter.DOM)

		controls = [
			new Buttonbar
				buttons: [
					new Button
						text: "Waiting"
						group: "a"
						onClick: ->
							progress_meter.setState("waiting")
				,
					new Button
						text: "Go!"
						group: "a"
						onClick: ->
							stepMeter(true)
				,
					new Button
						text: "Spinning"
						group: "a"
						onClick: ->
							progress_meter.setState("spinning")
				]
			.DOM
		]

		@demo_table.addExample( "Progress Meter", parent_meter_container, controls )




Demo.register( new ProgressMeterDemo() )