all:
	npm install
	npm run build

watch:
	npm run build:watch

code:
	npm run build:no-minify

.PHONY: all
