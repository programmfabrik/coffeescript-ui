target = ../build/demo
call_scss = sass --scss --no-cache --sourcemap=inline

example_coffee_files = src/examples/cui_examples.coffee

coffee_files = src/demo.coffee \
	src/CUIDemo.coffee \
	src/ControlsDemo.coffee \
	src/MemoryTester.coffee \
	src/Playground.coffee \
	src/Docs.coffee \
	src/ScrollIntoViewDemo/ScrollIntoViewDemo.coffee \
	src/BoundingBoxDemo/BoundingBoxDemo.coffee \
	../src/base/DragDropSelect/demo/DragDropSelectDemo.coffee \
	../src/base/Events/demo/EventsDemo.coffee \
	../src/base/Layout/demo/LayoutDemo.coffee \
	../src/base/Layer/demo/LayerDemo.coffee \
	../src/base/XHR/demo/XHRDemo.coffee \
	../src/elements/Button/demo/ButtonDemo.coffee \
	../src/elements/Label/demo/LabelDemo.coffee \
	../src/elements/Block/demo/BlockDemo.coffee \
	../src/elements/Menu/demo/MenuDemo.coffee \
	../src/elements/Input/demo/InputDemo.coffee \
	../src/elements/DateTime/demo/DateTimeDemo.coffee \
	../src/elements/MarkdownInput/demo/MarkdownInputDemo.coffee \
	../src/elements/FileUpload/demo/FileUploadDemo.coffee \
	../src/elements/Modal/demo/DialogDemo.coffee \
	../src/elements/Tooltip/demo/TooltipDemo.coffee \
	../src/elements/BorderLayout/demo/BorderLayoutDemo.coffee \
	../src/elements/Pane/demo/PaneDemo.coffee \
	../src/elements/Tabs/demo/TabsDemo.coffee \
	../src/elements/Panel/demo/PanelDemo.coffee \
	../src/elements/StickyHeader/demo/StickyHeaderDemo.coffee \
	../src/elements/Form/demo/FormDemo.coffee \
	../src/elements/Form/demo/FormLayoutDemo.coffee \
	../src/elements/ListView/demo/ListViewDemo.coffee \
	../src/elements/ListView/demo/ListViewTreeDemo.coffee \
	../src/elements/DigiDisplay/demo/DigiDisplayDemo.coffee


jpg_files = ../src/elements/Menu/demo/Schmetterling.jpg


files = $(addsuffix .js, $(coffee_files) )

example_files = $(addsuffix .js, $(example_coffee_files) )

highlight_files = \
	../thirdparty/highlight/highlight.pack.js \
	../thirdparty/highlight/styles/atom-one-dark.css

highlight:
	#
	# $@
	mkdir -p $(target)

	rm -rf $(target)/highlight
	mkdir -p $(target)/highlight

	#rsync -r ../thirdparty/highlight/styles/atom-one-dark.css $(target)/highlight
	#rsync -r ../thirdparty/highlight/highlight.pack.js $(target)/highlight
	cp $(highlight_files) $(target)/highlight

docs_icons:
	mkdir -p $(target)/css/icons
	cp src/icons/inherit.svg $(target)/css/icons/inherit.svg
	cp src/icons/remove-icon.svg $(target)/css/icons/remove-icon.svg
	cp src/icons/merge-icon.svg $(target)/css/icons/merge-icon.svg
	cp src/icons/arrow-right.svg $(target)/css/icons/arrow-right.svg

code: $(files) $(example_files) docs highlight docs_icons
	#
    # $@
	mkdir -p $(target)/examples
	# make javascript, coffee transpiling is made automatically
	@cat $(files) > $(target)/easydbui_demo.js
	@cat $(example_files) > $(target)/examples/cui_examples.js
	echo "Docs.path='/demo/docs';" >> $(target)/easydbui_demo.js
	cp -rv scratch $(target)
	cp ../src/elements/FileUpload/demo/FileUpload.php $(target)/FileUpload.php
	cp ../src/base/XHR/demo/XHRTest.php $(target)/XHRTest.php
	cp -r ../build/font-awesome $(target)
	cat demo.html > $(target)/index.html
	cat src/examples/index.html > $(target)/examples/index.html
	# Compile & Copy tobi.coffee.js
	cp src/tobi.coffee.js $(target)

docs:
	mkdir -p $(target)
	cp -r ../docs $(target)

html:
	#
	# $@
	mkdir -p $(target)
	# make html
	@cat ../src/base/*/demo/*html > $(target)/easydbui_demo.html
	@cat ../src/elements/*/demo/*html >> $(target)/easydbui_demo.html
	cat src/ScrollIntoViewDemo/ScrollIntoViewDemo.html >> $(target)/easydbui_demo.html

css_ng: jpg
	#
	# $@
	mkdir -p $(target)/css
	cp ../src/scss/icons/icons.svg $(target)/css/icons.svg
	$(call_scss) src/scss/themes/ng/main.scss $(target)/css/cui_demo_ng.css
	$(call_scss) src/scss/themes/ng_debug/main.scss $(target)/css/cui_demo_ng_debug.css

css_other:
	#
	# $@
	mkdir -p $(target)/css
	# make css TODO make demo css for each theme
	cp ../src/scss/icons/icons.svg $(target)/css/icons.svg
	$(call_scss) src/scss/themes/light/main.scss $(target)/css/cui_demo_light.css
	$(call_scss) src/scss/themes/dark/main.scss $(target)/css/cui_demo_dark.css


css: css_ng css_other

watch_ng:
	watch 'sass --scss --sourcemap=inline src/scss/themes/ng/main.scss:$(target)/css/cui_demo_ng.css' ../src/scss/themes/ng src/scss/themes/ng

watch_code:
	watch 'make code' ../src/elements ../src/base

jpg: $(jpg_files)
	#
	#
	mkdir -p $(target)/css/pics
	cp $(jpg_files) $(target)/css/pics

all: code html css files.txt
	#
	# ---- $@ ----
	mkdir -p $(target)
	cp files.txt $(target)/
	# make file list on Linux
	# find -O1 -not -name '*~' -not -name '.*' -printf '%P %d %y %s %A@\n' files.txt

clean:
	find . -name '*.coffee.js' | xargs rm -f
	rm -rf $(target)
	rm -f $(files_txt)

wipe: clean
	find . -name '*~' -or -name '#*#' | xargs rm -f

%.coffee.js: %.coffee
	coffee -b -p --compile $^ > $@ || ( rm -f $@ ; false )

.PHONY: docs
