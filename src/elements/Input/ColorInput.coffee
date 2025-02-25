###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2025 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.ColorInput extends CUI.Input

    initOpts: ->
        super()

    readOpts: ->
        @opts.leftControlElement = new CUI.Button
            tabindex: -1
            onClick: (ev, btn) =>
                @__input.focus()
        super()

    onDataChanged: (ev, info) ->
        super(ev, info)
        @__toggleColor()

    initValue: ->
        super()
        if not @__data[@_name] or @__data[@_name].length == 0
            @_leftControlElement.hide(true)
        else
            @_leftControlElement.DOM.style.setProperty("--btn-background", @__data[@_name]);
            @_leftControlElement.show(true)

    __toggleColor: ->
        if @__input.value.length > 0 and @__checkInputInternal()
            # Set the background color of the @_leftControlElement to the value of the input
            @_leftControlElement.DOM.style.setProperty("--btn-background", @__input.value);
            @_leftControlElement.show(true)
        else
            @_leftControlElement.hide(true)
