class PopoverDemo extends ModalDemo

	display: ->
		tp = $table("cui-demo-popover-demo")
		fss = ["both", "auto", "horizontal", "vertical", null]

		ths = ["Direction"]

		@mod = null

		mod_opts3 = @getOpts()
		#mod_opts3.backdrop = true
		mod_opts3.modal = false
		mod_opts3.content = @getBlindText()

		mod_opts4 = copyObject(mod_opts3,true)
		mod_opts4.content = "Horst is a good something thatHorst is a good something thatHorst is a good something thatHorst is a good something thatHorst is a good something thatHorst is a good something that"
		mod_opts4.class = "cui-popover-demo-small-layer"


		for p in Layer::getPlacements()
			tds = [p]
			for fs, idx in fss
				if not ths[idx*2+1]
					if fs
						ths[idx*2+1] = fs
					else
						ths[idx*2+1] = "Ohne"
					ths[idx*2+2] = ""
				do (p, fs) =>
					if fs
						pt = "#{p} [#{fs}]"
					else
						pt = p

					tds.push (new Button
						text: pt
						onClick: (ev, btn) =>
							mod_opts3.fill_space = fs or null
							mod_opts3.element = btn
							mod_opts3.placements = [ p ]
							mod_opts3.placement = p
							#mod_opts3.backdrop = true

							@mod?.destroy()
							@mod = new Popover(mod_opts3).show()
					).DOM

					tds.push (new Button
						text: pt
						size: "big"
						onClick: (ev, btn) =>
							mod_opts4.fill_space = fs or null
							mod_opts4.element = btn
							mod_opts4.placements = [ p ]
							mod_opts4.placement = p
							#mod_opts4.backdrop = true

							@mod?.destroy()
							@mod = new Popover(mod_opts4).show()
					).DOM
			tp.append($tr_one_row.apply($tr_one_row, tds))

		tp.prepend($tr_one_row.apply($tr_one_row, ths))
		tp.prepend($tr_one_row($td().text("Popover"), $td().text("Fill Space", colspan: fss.length)))

		d = $div()
			.append(tp)
			.append($div("cui-demo-popover-demo-bottom-box"))

		d


Demo.register(new PopoverDemo())