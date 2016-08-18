target = ../build/demo
call_scss = sass --scss --no-cache --sourcemap=inline

coffee_files = src/demo.coffee \
	src/CUIDemo.coffee \
	src/ControlsDemo.coffee \
	src/MemoryTester.coffee \
	src/BoundingBoxDemo/BoundingBoxDemo.coffee \
	../src/base/DragDropSelect/demo/DragDropSelectDemo.coffee \
	../src/base/Events/demo/EventsDemo.coffee \
	../src/base/Layout/demo/LayoutDemo.coffee \
	../src/base/Layer/demo/LayerDemo.coffee \
	../src/base/XHR/demo/XHRDemo.coffee \
	../src/elements/Button/demo/ButtonDemo.coffee \
	../src/elements/Label/demo/LabelDemo.coffee \
	../src/elements/Block/demo/BlockDemo.coffee \
	../src/elements/ProgressMeter/demo/ProgressMeterDemo.coffee \
    ../src/elements/Button/demo/ButtonbarDemo.coffee \
	../src/elements/Menu/demo/MenuDemo.coffee \
	../src/elements/Input/demo/InputDemo.coffee \
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


code: $(files)
	#
    # $@
	mkdir -p $(target)
	# make javascript, coffee transpiling is made automatically
	@cat $(files) > $(target)/easydbui_demo.js
	cp -rv scratch $(target)
	cp ../src/elements/FileUpload/demo/FileUpload.php $(target)/FileUpload.php
	cp ../src/base/XHR/demo/XHRTest.php $(target)/XHRTest.php
	cat demo.html > $(target)/index.html

html:
	#
	# $@
	mkdir -p $(target)
	# make html
	@cat ../src/base/*/demo/*html > $(target)/easydbui_demo.html
	@cat ../src/elements/*/demo/*html >> $(target)/easydbui_demo.html

css_ng: jpg
	#
	# $@
	mkdir -p $(target)/css
	$(call_scss) src/scss/themes/ng/main.scss $(target)/css/cui_demo_ng.css

css_other:
	#
	# $@
	mkdir -p $(target)/css
	# make css TODO make demo css for each theme
	$(call_scss) src/scss/themes/light/main.scss $(target)/css/cui_demo_light.css
	$(call_scss) src/scss/themes/dark/main.scss $(target)/css/cui_demo_dark.css


css: css_ng css_other

jpg: $(jpg_files)
	#
	#
	mkdir -p $(target)/css/pics
	cp $(jpg_files) $(target)/css/pics

all: code html css
	#
	# ---- $@ ----
	mkdir -p $(target)
	# make file list
	find -O1 -not -name '*~' -not -name '.*' -printf '%P %d %y %s %A@\n' > $(target)/files.txt

clean:
	find . -name '*.coffee.js' | xargs rm -f
	rm -rf $(target)
	rm -f $(files_txt)

wipe: clean
	find . -name '*~' -or -name '#*#' | xargs rm -f

%.coffee.js: %.coffee
	coffee -b -p --compile $^ > $@ || ( rm -f $@ ; false )
