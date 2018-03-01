CodoCLI = require 'codo/lib/command.coffee'
codoCLI = new CodoCLI()
options =
	output: './doc'
	name: 'Coffeescript-UI Documentation'
	title: 'Coffeescript-UI Documentation'

codoCLI.generate "./src", options, (exitCode) -> process.exit exitCode
