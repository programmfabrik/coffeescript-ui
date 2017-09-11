all:
	npm install
	npm run build -- --env.minify --env.noCss

watch:
	npm run build:watch -- --env.noCss

code:
	npm run build -- --env.noCss

demo:
	npm run build

# Build all versions.
build_all:
	npm run build
	npm run build -- --env.noCss
	npm run build -- --env.minify
	npm run build -- --env.minify --env.noCss

wipe:
	find . -name '*~' -or -name '#*#' | xargs rm -f

.PHONY: all wipe code watch demo
