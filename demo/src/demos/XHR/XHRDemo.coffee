###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class Demo.XHRDemo extends Demo
	getGroup: ->
		"Core"

	display: ->
		log_xhr = (xhr) =>
			html = []
			@log("Status: <b>"+xhr.status()+"</b> StatusText: <b>"+xhr.statusText()+"</b>")
			for k, v of xhr.getResponseHeaders()
				html.push(CUI.util.toHtml(k)+": <b>"+CUI.util.toHtml(v.join(", "))+"</b>")
			@log(html.join("</br>"))
			return

		start_xhr = (xhr) =>
			xhr.start()
			.done (data, status, statusText) =>
				@logTxt("OK:"+JSON.stringify(data))
				log_xhr(xhr)
				console.debug "OK", xhr.getXHR(), xhr.getResponseHeaders()
			.progress (type, loaded, total, percent) =>
				@logTxt("PROGRESS: "+type+" #{loaded}/#{total} #{percent}%")
				console.debug "PROGRESS", type, loaded, total, percent
			.fail (data, status, statusText) =>
				@log("FAILED:"+JSON.stringify(data))
				log_xhr(xhr)
				console.debug "FAIL", xhr.getXHR(), xhr.getResponseHeaders()

		timeout_form = (=>
			xhr = null
			new CUI.Form
				horizontal: true
				maximize: false
				fields: [
					type: CUI.FormButton
					form:
						label: "left"
					text: "Start XHR (Timeout 3s)"
					onClick: =>
						xhr = new CUI.XHR
							url: "/easydbui/demo/XHRTest.php?sleep=1"
							timeout: 3000
						start_xhr(xhr)
						return
				,
					type: CUI.FormButton
					form:
						label: "right"
					text: "Abort XHR"
					onClick: =>
						xhr.abort()
				]
		)()

		form = new CUI.Form
			maximize: true
			fields: [
				type: CUI.FormButton
				text: "Start XHR"
				onClick: =>
					start_xhr new CUI.XHR
						url: "/easydbui/demo/XHRTest.php"
			,
				type: CUI.FormButton
				text: "Start XHR (Timeout 0.5s)"
				onClick: =>
					start_xhr new CUI.XHR
						url: "/easydbui/demo/XHRTest.php?sleep=1"
						timeout: 500
			,
				timeout_form
			,
				type: CUI.FormButton
				text: "Start XHR (404)"
				onClick: =>
					start_xhr new CUI.XHR
						url: "/easydbui/demo/XHRTest404.json"
			,
				type: CUI.FormButton
				text: "Start XHR (DNS_ERROR)"
				onClick: =>
					start_xhr new CUI.XHR
						url: "http://illehal.url.yppp/"
			]
		.start()

		file_upload = CUI.dom.element("input", type: "file", multiple: true)

		CUI.Events.listen
			type: "change"
			node: file_upload
			call: (ev) =>
				uploads = []
				for file in file_upload.files
					idx = uploads.length
					do (idx) =>
						uploads.push(=>
							xhr = new CUI.XHR
								url: "FileUpload.php"
								form:
									"files[]": file

							promise = start_xhr(xhr)
							.done =>
								@logTxt("file:", idx, "uploaded:", file.name)
							.progress (loaded, total, percent) =>
								@logTxt(file.name, loaded+"/"+total+" "+percent+"%")

						)
				console.debug "change on fileupload", file_upload.files, uploads

				CUI.chainedCall.apply(CUI, uploads)
				return

		[form, file_upload]

Demo.register(new Demo.XHRDemo())