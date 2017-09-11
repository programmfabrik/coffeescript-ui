all:
	npm install
	npm run build -- --env.minify --env.noCss

watch:
	npm run build:watch -- --env.noCss

code:
	npm run build -- --env.noCss

demo:
	npm run build

wipe:
	find . -name '*~' -or -name '#*#' | xargs rm -f

.PHONY: all wipe code watch demo
