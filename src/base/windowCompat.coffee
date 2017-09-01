# This code copies the CUI namespace to the
# global window namespace. This needs to be removed
# as soon as possible, but for now we are stuck with it.
window.marked = require('marked')
window.moment = require('moment')

CUI.windowCompat.protect.push("TouchEvent")
CUI.windowCompat.protect.push("Element")
CUI.windowCompat.protect.push("Deferred")
CUI.windowCompat.protect.push("Promise")
CUI.windowCompat.protect.push("KeyboardEvent")
CUI.windowCompat.protect.push("MouseEvent")
CUI.windowCompat.protect.push("WheelEvent")
CUI.windowCompat.protect.push("alert", "Alert", "problem")
CUI.windowCompat.protect.push("confirm", "Confirm")
CUI.windowCompat.protect.push("prompt")
CUI.windowCompat.protect.push("FileReader")
CUI.windowCompat.protect.push("Event")

CUI.windowCompat.start()