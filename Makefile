all:
	npm install
	npm run build

watch:
	npm run build:watch

code:
	npm run build:no-minify

wipe:
	find . -name '*~' -or -name '#*#' | xargs rm -f

.PHONY: all wipe code watch
