# This code copies the CUI namespace to the
# global window namespace. This needs to be removed
# as soon as possible, but for now we are stuck with it.

class CUI.windowCompat

		@protect: [] # Array to hold properties which will not get copied

		start: ->
			for prop, func of CUI
				if prop in CUI.windowCompat.protect
					continue

				if window[prop] != undefined
					console.error("CUI.windowCompat: Already mapped! CUI."+prop+" -> window."+prop)
				else
					window[prop] = func
					console.info("CUI."+prop+" -> window."+prop)

			for prop, func of CUI.DOM
				if prop.startsWith('$')
					window[prop] = func
					console.info("CUI.DOM."+prop+" -> window."+prop)

window.marked = require('marked')
window.moment = require('moment')

# protect already stuff added from CUI
for prop, value of CUI
# protect from copying by windowCompat.coffee
	CUI.windowCompat.protect.push(prop)

CUI.windowCompat.start()