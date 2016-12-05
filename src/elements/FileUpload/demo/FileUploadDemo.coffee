###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class FileUploadDemo extends Demo
	display: ->

		update_status = (fuf) =>
			# file = fuf.getFile()
			# progress = fuf.getProgress()
			# CUI.debug "console progress on file", file, progress
			# CUI.debug("#{progress.status} #{file.name}, #{progress.loaded}, #{progress.total}, #{progress.percent}%")

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
			CUI.debug "update on file", f.getName(), f.getStatus()

			switch f.getStatus()
				when "CREATED"
					remove_btn = new Button
						icon: "trash"
						appearance: "flat"
						size: "mini"
						onClick: ->
							f.remove()

					f._tmpl = new Template
						name: "file-upload-demo"
						map:
							remove: true
							info: true
							thumb: true

					f._tmpl.DOM.appendTo(drop_zone)
					f._tmpl.append(remove_btn, "remove")
					f._tmpl.append(f.getName(), "info")
				when "DEQUEUED"
					f._tmpl.destroy()
					return

			f._tmpl.replace(f.getInfo(), "thumb")


		drop_zone_parent=$div("cui-file-upload-demo-drop-zone-parent")
		drop_zone=$div("cui-file-upload-demo-drop-zone")
		drop_zone_parent.append(drop_zone)

		fu = new FileUpload
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


		fu.initDropZone(dropZone: drop_zone)


		abort = new Button
			text: "Abort"
			disabled: true
			onClick: ->
				fu.abort()

		clear = new Button
			text: "Clear"
			onClick: ->
				fu.clear()

		demo_table = new DemoTable()

		demo_table.addDivider("upload examples")

		demo_table.addExample("Pick Multiple Files", new FileUploadButton(
			fileUpload: fu
			text: "Upload Multiple & Drop"
			drop: true
			icon: "upload"
		).DOM)

		demo_table.addExample("Pick One File", new FileUploadButton(
			fileUpload: fu
			text: "Upload One"
			multiple: false
			icon: "upload"
		).DOM)

		demo_table.addExample("Pick Directory (Chrome/Safari)", new FileUploadButton(
			fileUpload: fu
			text: "Upload Directory"
			directory: true
			icon: "upload"
		).DOM)

		demo_table.addExample("Pick One File (local upload)", new FileUploadButton(
			fileUpload: fr
			text: "Upload One"
			multiple: false
			icon: "upload"
		).DOM)

		browserUploadInput = $element("input", "", id: "browser-native-upload", type: "file")[0]

		demo_table.addExample("Browser Upload", browserUploadInput,
			new Button
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
		dropZone = $(".cui-file-upload-demo-drop-zone")[0]
		CUI.debug "dispatching event", ev
		dropZone.dispatchEvent(ev)


Demo.register(new FileUploadDemo())