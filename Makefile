all: install build

code: build

code_dev:
	npm run build:dev

install:
	npm install

build:
	npm run build

.PHONY: all
