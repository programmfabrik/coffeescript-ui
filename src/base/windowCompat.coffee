# This code copies the CUI namespace to the
# global window namespace. This needs to be removed
# as soon as possible, but for now we are stuck with it.
window.marked = require('marked')
window.moment = require('moment')

CUI.windowCompat.start()