class DialogDemo extends Demo

	__addDivider: (text) ->
		@demo_table.addDivider(text)

	__add_btn: (kind, opts={}) ->
		@demo_table.addExample(kind, new Button(opts).DOM)


	display: =>
		@demo_table = new DemoTable('cui-modal-demo')
		@demo_table.table


		@mod = null

		mod_opts = @getOpts()
		#mod_opts.fill_space = "auto"

		mod_opts2 = copyObject(mod_opts)
		mod_opts3 = copyObject(mod_opts)
		mod_opts4 = copyObject(mod_opts)
		mod_opts5 = copyObject(mod_opts)
		mod_optsFullScreen = copyObject(mod_opts)

		@__addDivider("Modal dialogs.")

		multiline_text =
			"""
			Please confirm all you can.
			Multiline
			Multiline
			"""

		@__add_btn("Normal button header and text size",
			text: "Open"
			onClick: =>
				@mod = new Modal
					class: "cui-modal-demo-normal-sizes"
					pane:
						header_left: new Label
							text: "Normal"
						footer_right: new Button
							text: "Ok"
							onClick: =>
								@mod.destroy()
						content: new Label
							icon: "spinner"
							text: "Normal size."
				@mod.show()
		)

		@__add_btn("Big button header and text size",
			text: "Open"
			onClick: =>
				@mod = new Modal
					class: "cui-modal-demo-big-sizes"
					pane:
						header_left: new Label
							text: "Big"
						footer_right: new Button
							text: "Ok"
							onClick: =>
								@mod.destroy()
						content: new Label
							icon: "spinner"
							text: "Big size."
				@mod.show()
		)

		@__add_btn("Bigger button header and text size",
			text: "Open"
			onClick: =>
				@mod = new Modal
					class: "cui-modal-demo-bigger-sizes"
					pane:
						header_left: new Label
							text: "Bigger"
						footer_right: new Button
							text: "Ok"
							onClick: =>
								@mod.destroy()
						content: new Label
							icon: "spinner"
							text: "Bigger size."
				@mod.show()
		)


		@__add_btn("Progress Information Dialog",
			text: "Open"
			onClick: =>
				@mod = new Modal
					class: "cui-progress-info-dialog"
					pane:
						header_left: new Label
							text: "Save"
						footer_right: new Button
							text: "Ok"
							onClick: =>
								@mod.destroy()
						content: new Label
							icon: "spinner"
							text: "Saving ..."
				@mod.show()
		)

		@__add_btn("Confirmation Dialog",
			text: "Open"
			onClick: =>
				@mod = new CUI.ConfirmationDialog
					text: multiline_text
					title: "Confirm"
					icon: "question"
					buttons: [
						text: "Cancel"
						onClick: =>
							@mod.destroy()
					,
						text: "Ok"
						onClick: =>
							@mod.destroy()
					]
				@mod.show()
		)

		@__add_btn("Confirmation Choice",
			text: "Open"
			onClick: =>
				@mod = new CUI.ConfirmationChoice
					text: "What's your favorite color?"
					title: "Color Decision"
					icon: "question"
					cancel: true
					onCancel: =>
						CUI.confirm(text: "Cancel?")
					onChoice: (ev, choice) =>
						CUI.debug "choice?", ev, choice, choice._value
					backdrop:
						background_effect: "darken"
					choices: [
						text: "Cancel"
						cancel: true
						_value: "cancelled..."
					,
						text: "Red"
						_value: "red"
						onClick: =>
							CUI.alert(text: "red is fine!")
					,
						text: "Green"
						_value: "green"
						onClick: =>
							CUI.confirm(text: "green, really?")
					,
						text: "Blue"
						_value: "blue"
					,
						text: "Create Own"
						onClick: (ev, choice) =>
							CUI.prompt(text: "Which color do you want?")
							.done (color) =>
								choice._value = color
					]
				@mod.open()
				.done (choice) =>
					@log("Your choice: ", choice._value)
				.fail (choice, ret) =>
					@log("Your canceled, why?", choice?._value)
		)

		@__add_btn("Alert",
			text: "Alert"
			onClick: =>
				CUI.alert(text: "Alert!")
				.done =>
					@log("Done with alarm.")
		)

		@__add_btn("Confirm",
			text: "Confirm"
			onClick: =>
				CUI.confirm(text: "Really?")
				.done =>
					@log("Ok then.")
				.fail =>
					@log("Canceled, fine.")
		)

		@__add_btn("Prompt",
			text: "Prompt"
			onClick: =>
				CUI.prompt(text: "How much?", "1")
				.done (input) =>
					@log("Ok then:"+input)
				.fail =>
					@log("Canceled, fine.")
		)

		@__add_btn("Problem",
			text: "Problem"
			onClick: =>
				CUI.alert(text: "Problem!")
				.done =>
					@log("Done with problem.")
		)


		@__addDivider("Unsorted examples.")

		@__add_btn("Simple Modal",
			text: "Open"
			onClick: =>
				@mod = new Modal(mod_opts)
				@mod.show()
		)


		@__add_btn("Modal Custom Width/Height",
			text: "Open"
			onClick: =>
				@mod = new Modal
					class: "modal-demo-custom"
					pane:
						content: @getBlindText()
						footer_right: =>
							[
								new Button
									text: "Ok"
									class: "cui-dialog"
									onClick: =>
										@mod.destroy()
							]
				@mod.show()
		)

		@__add_btn("Modal Minimal/Maximal Width/Height",
			text: "Open"
			icon_left: new Icon(class: "fa-arrows")
			onClick: =>
				@mod = new Modal
					class: "modal-demo-min-max"
					pane:
						content: @getBlindText()
						header_left: new Label( text: "LEFT" )
						header_right: new Label( text: "RIGHT" )
						footer_right: =>
							[
								new Button
									text: "Fill"
									class: "cui-dialog"
									onClick: =>
										@mod.append(@getBlindText())
							,
								new Button
									text: "AutoSize"
									class: "cui-dialog"
									onClick: =>
										@mod.autoSize()
							,
								new Button
									text: "AutoSize Immediate"
									class: "cui-dialog"
									onClick: =>
										@mod.autoSize(true)
							,
								new Button
									text: "Ok"
									class: "cui-dialog"
									onClick: =>
										@mod.destroy()
							]



				@mod.show()
		)

		@__add_btn("Modal Autosize",
			text: "Open"
			icon_left: new Icon(class: "fa-arrows")
			onClick: =>
				@mod = new Modal
					placement: "c"
					pane:
						content: "No Content. Fill it."
						header_left: new Label( text: "LEFT" )
						header_right: new Label( text: "RIGHT" )
						footer_right: =>
							[
								new Button
									text: "Fill"
									class: "cui-dialog"
									onClick: =>
										@mod.append(@getBlindText())
							,
								new Button
									text: "AutoSize"
									class: "cui-dialog"
									onClick: =>
										@mod.autoSize()
							,
								new Button
									text: "Ok"
									class: "cui-dialog"
									onClick: =>
										@mod.destroy()
							]



				@mod.show()
		)


		mod_opts3.pane.content = @getBlindText()

		mod_opts2.cancel = true
		mod_opts2.fill_screen_button = true
		mod_opts2.pane =
			header_left: new Label( text: "LEFT" )
			header_center: new Label( text: "CENTER" )
			header_right: new Label( text: "RIGHT" )
			content: @getBlindText()


		@__add_btn("Modal (Fill Screen)",
			text: "Open"
			icon_left: new Icon(class: "fa-arrows-alt")
			onClick: =>
				@mod = new Modal(mod_opts2)
				@mod.show()
		)

		mod_optsFullScreen.fill_space = "both"

		@__add_btn("Modal Full-Screen",
			text: "Open"
			icon_left: new Icon(class: "fa-arrows-alt")
			onClick: =>
				@mod = new Modal(mod_optsFullScreen)
				@mod.show()
		)


		@__addDivider("Overlapping dialogs")

		@__add_btn("Overlapping",
			text: "Open"
			icon_left: new Icon(class: "fa-arrows-alt")
			onClick: =>
				@background_dialog = new Modal(
					fill_space: "horizontal"
					pane:
						content: $text("background")
						footer_right: =>
							[
								new Button(
									text: "Ok"
									class: "cui-dialog"
									onClick: =>
										@background_dialog.destroy()
								)
							]
				)
				@background_dialog.show()

				@foreground_dialog = new Modal(
					pane:
						content: $text("foreground")
						footer_right: =>
								[
									new Button(
										text: "Ok"
										class: "cui-dialog"
										onClick: =>
											@foreground_dialog.destroy()
									)
								]
							)
				@foreground_dialog.show()

				#force a reposition to make sure that the window stays below
				@background_dialog.position()
		)


		@__addDivider("Non-modal dialog")

		@__add_btn("Non-modal dialog",
			text: "Open"
			icon_left: new Icon(class: "fa-arrows-alt")
			onClick: =>
				@foreground_dialog = new Modal(
					modal: false
					pane:
						content: $text("You can click outside to close this Dialog. Checkout the Popover Demo for examples of non modal dialogs.")
						footer_right: =>
							[
								new Button(
									text: "Ok"
									class: "cui-dialog"
									onClick: =>
										@foreground_dialog.destroy()
								)
							]
				)
				@foreground_dialog.show()
		)

		@demo_table.table


	getOpts: =>
		onHide: ->
			# CUI.debug "Layer onHide called"
		onShow: ->
			# CUI.debug "Layer onShow called"
		onPosition: ->
			# @DOM.prop("title", @__debug.join("\n"))
		pane:
			content: =>
				@getBlindText()
			footer_left: =>
				[
					new Button
						text: "Clear"
						class: "cui-dialog"
						onClick: =>
							CUI.debug @, @mod
							@mod.empty().append("not much here")
					.DOM
				]
			footer_right: =>
				[
					new Button
						text: "Fill"
						class: "cui-dialog"
						onMouseisdown: (ev) =>
							if ev.getMilliseconds() % 200 == 0
								@mod.append(@getBlindText())
				,
					new Button
						text: "Ok"
						class: "cui-dialog"
						onClick: =>
							@mod.destroy()
				]


Demo.register(new DialogDemo())