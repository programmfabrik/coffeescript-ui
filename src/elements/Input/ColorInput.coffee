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
                if @isDisabled()
                    return
                @__colorPicker?.click()
        super()

    render: ->
        super()
        @__colorPicker = CUI.dom.$element("input", "cui-color-picker-native",
            type: "color"
            tabindex: "-1"
        )

        CUI.Events.listen
            node: @__colorPicker
            type: "input"
            call: =>
                @__input.value = @__colorPicker.value
                @__toggleColor()

        CUI.Events.listen
            node: @__colorPicker
            type: "change"
            call: =>
                @__input.value = @__colorPicker.value
                @__toggleColor()
                new CUI.Event(type: "input", node: @__input).dispatch()

        CUI.dom.append(@DOM, @__colorPicker)
        @

    onDataChanged: (ev, info) ->
        super(ev, info)
        @__toggleColor()

    initValue: ->
        super()
        if not @__data[@_name] or @__data[@_name].length == 0
            @_leftControlElement.addClass('is-empty')
        else
            @_leftControlElement.DOM.style.setProperty("--btn-background", @__data[@_name])
            @_leftControlElement.removeClass('is-empty')
            @__syncColorPicker(@__data[@_name])

    __syncColorPicker: (value) ->
        if not @__colorPicker
            return
        if value and /^#[0-9a-fA-F]{6}$/.test(value)
            @__colorPicker.value = value

    __toggleColor: ->
        if @__input.value.length > 0 and @__checkInputInternal()
            @_leftControlElement.DOM.style.setProperty("--btn-background", @__input.value)
            @_leftControlElement.removeClass('is-empty')
            @__syncColorPicker(@__input.value)
        else
            @_leftControlElement.DOM.style.removeProperty("--btn-background")
            @_leftControlElement.addClass('is-empty')
