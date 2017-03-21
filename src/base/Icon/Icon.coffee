###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Icon extends CUI.Element
	constructor: (@opts={}) ->
		super(@opts)
		svg_cls = ""
		cls = ""
		if @_icon
			cls = @icon_map()[@_icon]
			if isEmpty(cls)
				cls = @_icon

			if cls.startsWith("svg-")
				svg_cls = cls
				cls = ""

		if not isEmpty(@_class)
			cls += " "+@_class

		if svg_cls
			@DOM = CUI.DOM.htmlToNodes("<svg class=\"cui-icon-svg #{svg_cls} #{cls}\"><use xlink:href=\"##{svg_cls}\"></svg>")[0]
		else
			@DOM = CUI.jQueryCompat(CUI.DOM.element("I", class: "fa "+cls))

		if @_tooltip
			@_tooltip.element = @DOM
			new Tooltip(@_tooltip)

	initOpts: ->
		super()
		@addOpts
			class:
				check: String
			icon:
				check: String
			fixed_width:
				check: Boolean
			tooltip:
				check: "PlainObject"

	copy: ->
		new Icon(@opts)

	hide: ->
		CUI.DOM.hideElement(@DOM)

	show: ->
		CUI.DOM.showElement(@DOM)

	icon_map: ->
		crop: "fa-crop"
		fullscreen: "fa-arrows-alt"
		trash: if CUI.__ng__ then "svg-trash" else "fa-trash-o"
		failed: "fa-warning"
		no_right: "fa-slack"
		file: if CUI.__ng__ then "fa-file" else "fa-file-o"
		filter: "fa-filter"
		refresh: "fa-refresh"
		reset: "svg-reset"
		zip: "fa fa-file-archive-o"
		rotate_right: "fa-rotate-right"
		rotate_left: "fa-rotate-left"
		rotate_vertical: "fa-arrows-v"
		rotate_horizontal: "fa-arrows-h"
		calendar: "fa-calendar"
		show: "fa-question"
		help: "fa-question"
		question: "fa-question"
		settings: if CUI.__ng__ then "fa-cog" else "fa-cogs"
		download: "fa-download"
		export: "fa-download"
		spinner: "fa-spinner cui-spin-stepped"
		list: "fa-question"
		upload: "fa-upload"
		envelope: "fa-envelope-o"
		envelope_active: "fa-envelope"
		save: "fa-floppy-o"
		heart: "fa-heart"
		remove: "svg-close"
		user: "fa-user"
		clock: "fa-clock-o"
		plus: "fa-plus"
		edit: "fa-pencil"
		copy: "fa-files-o"
		search: "fa-search"
		share: "fa-share"
		play: "fa-play"
		audio: "fa-music"
		start: "fa-play"
		stop: "fa-stop"
		print: "fa-print"
		minus: "fa-minus"
		# tree_open: "fa-plus-square-o"
		# tree_close: "fa-minus-square-o"
		tree_open: "fa-caret-right"
		tree_close: "fa-caret-down"
		ellipsis_h: "fa-ellipsis-h"
		ellipsis_v: "fa-ellipsis-v" #used for sidemenu buttons
		close: "svg-close"
		folder: "svg-folder"
		folder_shared: "svg-folder-shared"
		folder_upload: "svg-folder-upload"
		folder_shared_upload: "svg-folder-shared-upload"
		menu: "fa-bars"
		info: "fa-info-circle"
		info_circle: "svg-info-circle"
		bolt: "fa-bolt"
		check: "fa-check"
		warning: "fa-warning"
		legal: "fa-legal"
		cloud: "fa-cloud"
		left: if CUI.__ng__ then "fa-angle-left" else "fa-chevron-left"
		right: if CUI.__ng__ then "fa-angle-right" else "fa-chevron-right"
		dive: if CUI.__ng__ then "fa-angle-right" else "fa-chevron-right"
		zoom_in: "fa-search-plus"
		zoom_out: "fa-search-minus"
		resize_small: "fa-compress"
		resize_full: "fa-expand"
		email: "fa-envelope-o"
		file_text_active : "fa-file-text"
		file_text : "fa-file-text-o"
		required: "fa-bullhorn"
		west: "fa-angle-left"
		east: "fa-angle-right"
		south: "fa-angle-down"
		north: "fa-angle-up"
		up: "fa-caret-up"
		down: "fa-caret-down"
		camera: "fa-camera"
		expert_search: "fa-list-ul" #"fa-binoculars" #"fa-mortar-board"
		image: "fa-picture-o"
		external_link: "svg-external-link"


CUI.proxyMethods(CUI.Icon, CUI.Button, ["hide", "show", "isShown","isHidden"])

Icon = CUI.Icon
