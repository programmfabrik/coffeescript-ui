all:
	npm install
	npm run build -- --env.minify --env.noCss

watch:
	npm run build:watch

code:
	npm run build -- --env.noCss

wipe:
	find . -name '*~' -or -name '#*#' | xargs rm -f

.PHONY: all wipe code watch
