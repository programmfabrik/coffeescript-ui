###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

CUI.Template.loadTemplateText(require('./FileUploadDemo.html'));

class Demo.FileUploadDemo extends Demo
	display: ->

		update_status = (fuf) =>
			# file = fuf.getFile()
			# progress = fuf.getProgress()
			# console.debug "console progress on file", file, progress
			# console.debug("#{progress.status} #{file.name}, #{progress.loaded}, #{progress.total}, #{progress.percent}%")

			fu = fuf.getFileUpload()

			info = fu.getInfo()

			if info.all_done
				abort.disable()
			else
				abort.enable()

			ss = []
			for k, v of info.status
				ss.push("#{k}: #{v}")

			@log(info.percent+"% -- "+ss.join("; ")+" -- "+info.total+"/"+info.loaded)


		update_drop_zone = (f) =>
			console.debug "update on file", f.getName(), f.getStatus()

			switch f.getStatus()
				when "CREATED"
					remove_btn = new CUI.Button
						icon: "trash"
						appearance: "flat"
						size: "mini"
						onClick: ->
							f.remove()

					f._tmpl = new CUI.Template
						name: "file-upload-demo"
						map:
							remove: true
							info: true
							thumb: true

					CUI.dom.append(drop_zone, f._tmpl.DOM)
					f._tmpl.append(remove_btn, "remove")
					f._tmpl.append(f.getName(), "info")
				when "DEQUEUED"
					f._tmpl.destroy()
					return

			f._tmpl.replace(f.getInfo(), "thumb")


		drop_zone_parent=CUI.dom.div("cui-file-upload-demo-drop-zone-parent")
		drop_zone=CUI.dom.div("cui-file-upload-demo-drop-zone")
		CUI.dom.append(drop_zone_parent, drop_zone)

		fu = new CUI.FileUpload
			url: "FileUpload.php"
			onAdd: update_status
			onProgress: update_status
			onDone: update_status
			onFail: update_status
			onDequeue: update_status
			onUpdate: update_drop_zone

		fr = new CUI.FileReader
			onAdd: update_status
			onProgress: update_status
			onDone: update_status
			onFail: update_status
			onDequeue: update_status
			onUpdate: update_drop_zone

		csv_data =
			delimiter: null
			quotechar: null
			header_rows: 1

		fr_csv = new CUI.FileReader
			onAdd: update_status
			onProgress: update_status
			onDone: (frf) =>
				update_status(frf)
				console.debug "uploaded_data", frf, frf.getResult().length

				@csvData = new CUI.CSVData()
				@csvData.parse(
					delimiter: csv_data.delimiter
					quotechar: csv_data.quotechar
					header_rows: csv_data.header_rows
					text: frf.getResult()
				)
				.done (csv_data) =>
					CUI.FileReader.save(frf.getFile().name+".json", JSON.stringify(csv_data.rows))

			onFail: update_status
			onDequeue: update_status
			onUpdate: update_drop_zone


		fu.initDropZone(dropZone: drop_zone)


		abort = new CUI.Button
			text: "Abort"
			disabled: true
			onClick: ->
				fu.abort()

		clear = new CUI.Button
			text: "Clear"
			onClick: ->
				fu.clear()

		demo_table = new Demo.DemoTable()

		demo_table.addDivider("upload examples")

		demo_table.addExample("Pick Multiple Files", new CUI.FileUploadButton(
			fileUpload: fu
			text: "Upload Multiple & Drop"
			drop: true
			icon: "upload"
		).DOM)

		demo_table.addExample("Pick One File", new CUI.FileUploadButton(
			fileUpload: fu
			text: "Upload One"
			multiple: false
			icon: "upload"
		).DOM)

		demo_table.addExample("Pick Directory (Chrome/Safari)", new CUI.FileUploadButton(
			fileUpload: fu
			text: "Upload Directory"
			directory: true
			icon: "upload"
		).DOM)

		demo_table.addExample("Pick One File (local upload)", new CUI.FileUploadButton(
			fileUpload: fr
			text: "Upload One"
			multiple: false
			icon: "upload"
		).DOM)

		demo_table.addExample("Pick One File (local upload, CSV)", [
			new CUI.FileUploadButton(
				fileUpload: fr_csv
				text: "Upload One"
				multiple: false
				icon: "upload"
			).DOM
		,
			new CUI.Select
				name: "delimiter"
				data: csv_data
				options: [
					text: "- detect -"
					value: null
				,
					value: ","
				,
					value: ";"
				]
			.start().DOM
		,
			new CUI.Select
				name: "quotechar"
				data: csv_data
				options: [
					text: "- detect -"
					value: null
				,
					value: '"'
				,
					value: "'"
				]
			.start().DOM
		,
			new CUI.Select
				name: "header_rows"
				data: csv_data
				options: [
					value: 0
				,
					value: 1
				,
					value: 2
				]
			.start().DOM
		])

		browserUploadInput = CUI.dom.$element("input", "", id: "browser-native-upload", type: "file")

		demo_table.addExample("Browser Upload", browserUploadInput,
			new CUI.Button
				text: "Upload"
				tooltip:
					text: "FileUploadDemo.dropChosenFile()"
				onClick: =>
					FileUploadDemo.dropChosenFile()
		)

		demo_table.addExample("Drop Zone", drop_zone_parent)
		demo_table.addExample("Abort", abort.DOM)
		demo_table.addExample("Clear", clear.DOM)

		demo_table.table

	@dropChosenFile: ->
		ev = document.createEvent("Event")
		ev.initEvent("drop", true, true)
		files = document.getElementById("browser-native-upload").files
		if not files.length
			alert("No files chosen.")
			return
		ev.dataTransfer = files: files
		dropZone = ".cui-file-upload-demo-drop-zone"
		console.debug "dispatching event", ev
		dropZone.dispatchEvent(ev)


Demo.register(new Demo.FileUploadDemo())