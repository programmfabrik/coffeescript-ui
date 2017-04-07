###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.FileReader extends FileUpload
	initOpts: ->
		super()
		@removeOpt("url")

	readOpts: ->
		CUI.Element::readOpts.call(@)

	getUploadFileClass: ->
		FileReaderFile

	uploadFile: (file) ->
		CUI.debug "filereader upload file", file
		file.upload(file)

	@save: (filename, data, type = "text/csv") ->
		blob = new Blob([data], type: type)
		if (window.navigator.msSaveOrOpenBlob)
	        window.navigator.msSaveBlob(blob, filename)
	    else
	        elem = window.document.createElement('a')
	        elem.href = window.URL.createObjectURL(blob)
	        elem.download = filename
	        document.body.appendChild(elem);
	        elem.click();
	        document.body.removeChild(elem);
			window.URL.revokeObjectURL(blob)
