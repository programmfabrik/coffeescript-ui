###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class XHRDemo extends Demo
	getGroup: ->
		"Core"

	display: ->
		log_xhr = (xhr) =>
			html = []
			@log("Status: <b>"+xhr.status()+"</b> StatusText: <b>"+xhr.statusText()+"</b>")
			for k, v of xhr.getResponseHeaders()
				html.push(toHtml(k)+": <b>"+toHtml(v.join(", "))+"</b>")
			@log(html.join("</br>"))
			return

		start_xhr = (xhr) =>
			xhr.start()
			.done (data, status, statusText) =>
				@logTxt("OK:"+JSON.stringify(data))
				log_xhr(xhr)
				CUI.debug "OK", xhr.getXHR(), xhr.getResponseHeaders()
			.progress (type, loaded, total, percent) =>
				@logTxt("PROGRESS: "+type+" #{loaded}/#{total} #{percent}%")
				CUI.debug "PROGRESS", type, loaded, total, percent
			.fail (data, status, statusText) =>
				@log("FAILED:"+JSON.stringify(data))
				log_xhr(xhr)
				CUI.debug "FAIL", xhr.getXHR(), xhr.getResponseHeaders()

		timeout_form = (=>
			xhr = null
			new Form
				horizontal: true
				maximize: false
				fields: [
					type: FormButton
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
					type: FormButton
					form:
						label: "right"
					text: "Abort XHR"
					onClick: =>
						xhr.abort()
				]
		)()

		form = new Form
			maximize: true
			fields: [
				type: FormButton
				text: "Start XHR"
				onClick: =>
					start_xhr new CUI.XHR
						url: "/easydbui/demo/XHRTest.php"
			,
				type: FormButton
				text: "Start XHR (Timeout 0.5s)"
				onClick: =>
					start_xhr new CUI.XHR
						url: "/easydbui/demo/XHRTest.php?sleep=1"
						timeout: 500
			,
				timeout_form
			,
				type: FormButton
				text: "Start XHR (404)"
				onClick: =>
					start_xhr new CUI.XHR
						url: "/easydbui/demo/XHRTest404.json"
			,
				type: FormButton
				text: "Start XHR (DNS_ERROR)"
				onClick: =>
					start_xhr new CUI.XHR
						url: "http://illehal.url.yppp/"
			]
		.start()

		file_upload = CUI.DOM.element("input", type: "file", multiple: true)

		Events.listen
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
				CUI.debug "change on fileupload", file_upload.files, uploads

				CUI.chainedCall.apply(CUI, uploads)
				return

		[form, file_upload]

Demo.register(new XHRDemo())