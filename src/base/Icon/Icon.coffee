class Icon extends CUI.Element
	constructor: (@opts={}) ->
		super(@opts)
		if @_icon
			@__class = @icon_map[@_icon]
			if isEmpty(@__class)
				@__class = @_icon
			if not isEmpty(@_class)
				@__class += " "+@_class
		else if not isEmpty(@_class)
			@__class = @_class
		else
			@__class = ""

		if @_fixed_width or isEmpty(@__class)
			@__class = "#{@__class} cui-icon-fixed-width"

		@DOM = $i("fa #{@__class}")

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

	icon_map:
		crop: "fa-crop"
		fullscreen: "fa-arrows-alt"
		trash: "fa-trash-o"
		failed: "fa-warning"
		no_right: "fa-slack"
		file: "fa-file-o"
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
		settings: "fa-cogs"
		download: "fa-download"
		export: "fa-download"
		spinner: "fa-spinner cui-spin-stepped"
		list: "fa-question"
		upload: "fa-upload"
		envelope: "fa-envelope-o"
		envelope_active: "fa-envelope"
		save: "fa-floppy-o"
		heart: "fa-heart"
		remove: "fa-times"
		user: "fa-user"
		clock: "fa-clock-o"
		plus: "fa-plus"
		edit: "fa-edit"
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
		close: "fa-times"
		menu: "fa-bars"
		info: "fa-info-circle"
		bolt: "fa-bolt"
		check: "fa-check"
		warning: "fa-warning"
		legal: "fa-legal"
		cloud: "fa-cloud"
		left: "fa-chevron-left"
		right: "fa-chevron-right"
		dive: "fa-chevron-right"
		zoom_in: "fa-search-plus"
		zoom_out: "fa-search-minus"
		resize_small: "fa-compress"
		resize_full: "fa-expand"
		email: "fa-envelope-o"
		file_text_active : "fa-file-text"
		file_text : "fa-file-text-o"
		required: "fa-bullhorn"
		west: "fa-long-arrow-left"
		east: "fa-long-arrow-right"
		south: "fa-long-arrow-down"
		north: "fa-long-arrow-up"
		up: "fa-caret-up"
		down: "fa-caret-down"
		camera: "fa-camera"
		expert_search: "fa-list-ul" #"fa-binoculars" #"fa-mortar-board"
		image: "fa-picture-o"


CUI.proxyMethods(Icon, Button, ["hide", "show", "isShown","isHidden"])
