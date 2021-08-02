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
			# common map icon
			if not cls
				cls = CUI.Icon.icon_map[@_icon]

			# fallback to value of icon
			if not cls
				cls = @_icon

			if cls.startsWith("svg-")
				svg_cls = cls
				cls = ""

		if not CUI.util.isEmpty(@_class)
			cls += " "+@_class

		if svg_cls
			@DOM = CUI.dom.htmlToNodes("<svg class=\"cui-icon-svg #{svg_cls} #{cls}\"><use xlink:href=\"##{svg_cls.split(" ")[0]}\"></svg>")[0]
		else
			@DOM = CUI.dom.element("I", class: "fa " + cls)

			if @_icon and not CUI.Icon.icon_map[@_icon] and not @_icon.startsWith("fa-") and not @_icon.startsWith("css-swatch")
				span = CUI.dom.span("cui-no-icon")
				span.textContent = @_icon[0]
				CUI.dom.append(@DOM, span)

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
		audio: "fa-music"
		bolt: "fa-bolt"
		calendar: "fa-calendar-plus-o"
		camera: "fa-camera"
		check: "fa-check"
		clock: "fa-clock-o"
		close: "svg-close"
		cloud: "fa-cloud"
		copy: "fa-files-o"
		crop: "fa-crop"
		dive: "fa-angle-right"
		down: "fa-caret-down"
		download: "fa-download"
		east: "fa-angle-right"
		edit: "fa-pencil"
		ellipsis_h: "fa-ellipsis-h"
		ellipsis_v: "fa-ellipsis-v" #used for sidemenu buttons
		email: "fa-envelope-o"
		envelope_active: "fa-envelope"
		envelope: "fa-envelope-o"
		expert_search: "fa-list-ul" #"fa-binoculars" #"fa-mortar-board"
		export: "fa-download"
		external_link: "svg-external-link"
		failed: "fa-warning"
		file_text : "fa-file-text-o"
		file_text_active : "fa-file-text"
		file: "fa-file"
		filter: "fa-filter"
		folder_shared_upload: "svg-folder-shared-upload"
		folder_shared: "svg-folder-shared"
		folder_upload: "svg-folder-upload"
		folder: "svg-folder"
		fullscreen: "fa-arrows-alt"
		heart: "fa-heart"
		help: "fa-question"
		image: "fa-picture-o"
		info_circle: "svg-info-circle"
		info_circle_ng: "svg-info-circle-ng"
		info: "fa-info-circle"
		left: "fa-angle-left"
		legal: "fa-legal"
		list: "fa-question"
		menu: "fa-bars"
		minus: "fa-minus"
		no_right: "fa-slack"
		north: "fa-angle-up"
		play: "fa-play"
		plus: "fa-plus"
		print: "fa-print"
		question: "fa-question"
		refresh: "fa-refresh"
		remove: "svg-close"
		required: "fa-bullhorn"
		reset: "svg-reset"
		resize_full: "fa-expand"
		resize_small: "fa-compress"
		right: "fa-angle-right"
		rotate_horizontal: "fa-arrows-h"
		rotate_left: "fa-rotate-left"
		rotate_right: "fa-rotate-right"
		rotate_vertical: "fa-arrows-v"
		save: "fa-floppy-o"
		search: "fa-search"
		settings: "fa-cog"
		share: "fa-share"
		show: "fa-question"
		sliders: "fa-sliders"
		south: "fa-angle-down"
		spinner: "svg-spinner cui-spin-stepped"
		start: "fa-play"
		stop: "fa-stop"
		trash: "svg-trash"
		up: "fa-caret-up"
		upload: "fa-upload"
		user: "fa-user"
		warning: "fa-warning"
		west: "fa-angle-left"
		zip: "fa-file-archive-o"
		zoom_in: "fa-search-plus"
		zoom_out: "fa-search-minus"


CUI.proxyMethods(CUI.Icon, CUI.Button, ["hide", "show", "isShown","isHidden"])

