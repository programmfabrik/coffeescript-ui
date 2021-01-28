all: npm_install
	npm run build:all

watch:
	npm run build:watch

npm_install:
	npm install

.PHONY: all watch npm_install
