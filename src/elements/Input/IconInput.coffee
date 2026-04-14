###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2025 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.IconInput extends CUI.Input

    initOpts: ->
        super()

    readOpts: ->
        @opts.leftControlElement = new CUI.Button
            icon: "fa-font-awesome"
            tabindex: -1
            onClick: (ev, btn) =>
                @__input.focus()
        super()

    getValueForStore: (value) ->
        if CUI.util.isString(value)
            return value.trim()
        value

    onDataChanged: (ev, info) ->
        super(ev, info)
        @__toggleIcon()

    initValue: ->
        super()
        if not @__data[@_name] or @__data[@_name].length == 0
            @_leftControlElement.addClass('is-empty')
        else
            @_leftControlElement.setIcon(@__data[@_name])
            @_leftControlElement.removeClass('is-empty')

    __toggleIcon: ->
        value = @__input.value.trim()
        if value.length > 0
            @_leftControlElement.setIcon(value)
            @_leftControlElement.removeClass('is-empty')
        else
            @_leftControlElement.setIcon("")
            @_leftControlElement.addClass('is-empty')
