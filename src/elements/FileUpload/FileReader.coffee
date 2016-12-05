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

