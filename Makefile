all: npm_ci
	npm run build:all

watch:
	npm run build:watch

npm_ci:
	npm ci

npm_install:
	npm install

.PHONY: all watch npm_install npm_ci
