###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Icon extends CUI.Element
	constructor: (opts) ->
		super(opts)
		svg_cls = ""
		cls = ""
		if @_icon
			cls = CUI.Icon.icon_map[@_icon]
			if CUI.util.isEmpty(cls)
				cls = @_icon

			if cls.startsWith("svg-")
				svg_cls = cls
				cls = ""

		if not CUI.util.isEmpty(@_class)
			cls += " "+@_class

		if svg_cls
			@DOM = CUI.dom.htmlToNodes("<svg class=\"cui-icon-svg #{svg_cls} #{cls}\"><use xlink:href=\"##{svg_cls.split(" ")[0]}\"></svg>")[0]
		else
			@DOM = CUI.dom.element("I", class: "fa "+cls)

		if @_tooltip
			@_tooltip.element = @DOM
			new CUI.Tooltip(@_tooltip)

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
		copyIcon = super()
		styles = CUI.dom.getStyle(@)
		CUI.dom.setStyle(copyIcon, styles)
		return copyIcon

	hide: ->
		CUI.dom.hideElement(@DOM)

	show: ->
		CUI.dom.showElement(@DOM)

	@icon_map:
		trash: "svg-trash"
		reset: "svg-reset"
		spinner: "svg-spinner cui-spin-stepped"
		remove: "svg-close"
		close: "svg-close"
		folder: "svg-folder"
		folder_shared: "svg-folder-shared"
		folder_upload: "svg-folder-upload"
		folder_shared_upload: "svg-folder-shared-upload"
		info_circle: "svg-info-circle"
		external_link: "svg-external-link"
		crop: "fa-crop"
		fullscreen: "fa-arrows-alt"
		failed: "fa-warning"
		no_right: "fa-slack"
		file: "fa-file"
		filter: "fa-filter"
		sliders: "fa-sliders"
		refresh: "fa-refresh"
		zip: "fa fa-file-archive-o"
		rotate_right: "fa-rotate-right"
		rotate_left: "fa-rotate-left"
		rotate_vertical: "fa-arrows-v"
		rotate_horizontal: "fa-arrows-h"
		calendar: "fa-calendar"
		show: "fa-question"
		help: "fa-question"
		question: "fa-question"
		settings: "fa-cog"
		download: "fa-download"
		export: "fa-download"
		list: "fa-question"
		upload: "fa-upload"
		envelope: "fa-envelope-o"
		envelope_active: "fa-envelope"
		save: "fa-floppy-o"
		heart: "fa-heart"
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
		tree_open: "fa-caret-right"
		tree_close: "fa-caret-down"
		ellipsis_h: "fa-ellipsis-h"
		ellipsis_v: "fa-ellipsis-v" #used for sidemenu buttons
		menu: "fa-bars"
		info: "fa-info-circle"
		bolt: "fa-bolt"
		check: "fa-check"
		warning: "fa-warning"
		legal: "fa-legal"
		cloud: "fa-cloud"
		left: "fa-angle-left"
		right: "fa-angle-right"
		dive: "fa-angle-right"
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


CUI.proxyMethods(CUI.Icon, CUI.Button, ["hide", "show", "isShown","isHidden"])

