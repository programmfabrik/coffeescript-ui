###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2023 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Socket extends CUI.Element
  getGroup: ->
    "Core"

  initOpts: ->
    super()
    @addOpts
      url:
        mandatory: true
        check: String
        check: (v) ->
          v.trim().length > 0

      onmessage:
        check: Function

      onclose:
        check: Function

      onopen:
        check: Function

      onerror:
        check: Function

    @

  @states:
    0 : "OPENING"
    1 : "OPEN"
    2 : "CLOSING"
    3 : "CLOSED"

  readOpts: ->
    super()

    location = CUI.parseLocation(@_url)
    switch location.protocol
      when "http", "ws"
        @__protocol = "ws"
      when "https", "wss"
        @__protocol = "wss"
    @_url = @_url.replace(location.protocol, @__protocol)

    return @

  open: ->
    dfr = new CUI.Deferred
    @__webSocket = new WebSocket(@_url)
    @__webSocket.onerror = (e) =>
      dfr.reject()
    @__webSocket.onopen = (ev) =>
      @__onOpen(ev)
      dfr.resolve()
    @__webSocket.onclose = (ev) =>
      @__onClose(ev)


    return dfr.promise()

  __onOpen: (ev) ->
    if @_onopen
      @_onopen(ev)
    @__webSocket.onmessage = (evt) =>
      data = {}
      if not CUI.util.isEmpty(evt.data)
        data = JSON.parse(evt.data)
      @_onmessage(evt, data)

  __onClose: (ev) ->
    if @_onclose
      @_onclose()

  close: ->
    @__webSocket.close()

  send: (msg) ->
    if @getStatus() == "OPEN"
      @__websocket.send(msg)

  getStatus: (asText = true) ->
    status = @__websocket.readyState
    if asText
      return @states[status]
    return status

