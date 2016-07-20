class CUI.FileReader extends FileUpload
	initOpts: ->
		super()
		@removeOpt("url")

	readOpts: ->
		Element::readOpts.call(@)

	getUploadFileClass: ->
		FileReaderFile

	uploadFile: (file) ->
		CUI.debug "filereader upload file", file
		file.upload(file)

