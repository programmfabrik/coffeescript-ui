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
            icon: "fa-star"
            onClick: (ev, btn) =>
                @__input.focus()
        super()

    onDataChanged: (ev, info) ->
        super(ev, info)
        @__toggleIcon()

    initValue: ->
        super()
        if not @__data[@_name] or @__data[@_name].length == 0
            @_leftControlElement.hide(true)
        else
            @_leftControlElement.setIcon(@__data[@_name])

    __toggleIcon: ->
        if @__input.value.length > 0
            @_leftControlElement.setIcon(@__input.value)
            @_leftControlElement.show(true)
        else
            @_leftControlElement.setIcon("")
            @_leftControlElement.hide(true)
