###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

CUI.Template.loadTemplateText(require('./MultiInputInput.html'));

class CUI.MultiInputInput extends CUI.Input
	getTemplate: ->
		new Template
			name: "data-field-multi-input"
			map:
				center: true
				right: true

	getTemplateKeyForRender: ->
		"center"
