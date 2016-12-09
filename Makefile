target = build
css_target = $(target)/css

call_scss = sass --scss --no-cache --sourcemap=inline
easydbui_js = $(target)/easydbui.js

coffee_files = src/base/Common.coffee \
	src/base/CUI.coffee \
	src/base/jQueryCompat.coffee \
	src/base/Deferred/Deferred.coffee \
	src/base/Deferred/Promise.coffee \
	src/base/Deferred/when.coffee \
	src/base/Deferred/decide.coffee \
	src/base/Dummy.coffee \
	src/base/Element.coffee \
	src/base/XHR/XHR.coffee \
	src/base/DragDropSelect/DragDropSelect.coffee \
	src/base/DragDropSelect/Draggable.coffee \
	src/base/DragDropSelect/Droppable.coffee \
	src/base/DragDropSelect/Lasso.coffee \
	src/base/DragDropSelect/Sortable.coffee \
	src/base/DragDropSelect/Movable.coffee \
	src/base/DragDropSelect/Resizable.coffee \
	src/base/DragDropSelect/Dragscroll.coffee \
	src/base/Events/Event.coffee \
	src/base/Events/MouseEvent.coffee \
	src/base/Events/KeyboardEvent.coffee \
	src/base/Events/CUIEvent.coffee \
	src/base/Events/Listener.coffee \
	src/base/Events/WheelEvent.coffee \
	src/base/Events/Events.coffee \
	src/base/DOM/DOM.coffee \
	src/base/CSSLoader/CSSLoader.coffee \
	src/base/Template/Template.coffee \
	src/base/FlexHandle/FlexHandle.coffee \
	src/base/Layout/Layout.coffee \
	src/base/Layer/Layer.coffee \
	src/base/DataField/DataField.coffee \
	src/base/DataField/CheckValueError.coffee \
	src/base/DataField/DataFieldInput.coffee \
	src/elements/Button/Button.coffee \
	src/base/Icon/Icon.coffee \
	src/elements/Button/ButtonHref.coffee \
	src/elements/Button/Buttonbar.coffee \
	src/elements/Label/Label.coffee \
	src/elements/Label/MultilineLabel.coffee \
	src/elements/Label/EmptyLabel.coffee \
	src/elements/ProgressMeter/ProgressMeter.coffee \
	src/elements/Block/Block.coffee \
	src/elements/WaitBlock/WaitBlock.coffee \
	src/elements/BorderLayout/BorderLayout.coffee \
	src/elements/Console/Console.coffee \
	src/elements/HorizontalLayout/HorizontalLayout.coffee \
	src/elements/VerticalLayout/VerticalLayout.coffee \
	src/elements/VerticalList/VerticalList.coffee \
	src/elements/HorizontalList/HorizontalList.coffee \
	src/elements/Toolbar/Toolbar.coffee \
	src/elements/Pane/Pane.coffee \
	src/elements/Pane/LayerPane.coffee \
	src/elements/Pane/SimplePane.coffee \
	src/elements/Pane/PaneToolbar.coffee \
	src/elements/Pane/PaneHeader.coffee \
	src/elements/Pane/PaneFooter.coffee \
	src/elements/Tabs/Tab.coffee \
	src/elements/Tabs/Tabs.coffee \
	src/elements/Modal/Modal.coffee \
	src/elements/ConfirmationDialog/ConfirmationDialog.coffee \
	src/elements/ConfirmationChoice/ConfirmationChoice.coffee \
	src/elements/ConfirmationChoice/Alert.coffee \
	src/elements/ConfirmationChoice/Toaster.coffee \
	src/elements/ConfirmationChoice/Spinner.coffee \
	src/elements/ConfirmationChoice/Confirm.coffee \
	src/elements/ConfirmationChoice/Prompt.coffee \
	src/elements/Popover/Popover.coffee \
	src/elements/Tooltip/Tooltip.coffee \
	src/elements/ListView/ListView.coffee \
	src/elements/ListView/ListViewTree.coffee \
	src/elements/ListView/ListViewRow.coffee \
	src/elements/ListView/ListViewHeaderRow.coffee \
	src/elements/ListView/ListViewTreeNode.coffee \
	src/elements/ListView/ListViewColumn.coffee \
	src/elements/ListView/ListViewColumnEmpty.coffee \
	src/elements/ListView/ListViewHeaderColumn.coffee \
	src/elements/ListView/tools/ListViewColumnRowMoveHandle.coffee \
	src/elements/ListView/tools/ListViewColumnRowMoveHandlePlaceholder.coffee \
	src/elements/ListView/tools/ListViewTool.coffee \
	src/elements/ListView/tools/ListViewHoverTool.coffee \
	src/elements/ListView/tools/ListViewRowMoveTool.coffee \
	src/elements/ListView/tools/ListViewColResizeTool.coffee \
	src/elements/ListView/tools/ListViewTreeRowMoveTool.coffee \
	src/elements/ItemList/ItemList.coffee \
	src/elements/Menu/Menu.coffee \
	src/elements/Panel/Panel.coffee \
	src/elements/Input/Input.coffee \
	src/elements/MarkdownInput/MarkdownInput.coffee \
	src/elements/FileUpload/FileUploadFile.coffee \
	src/elements/FileUpload/FileUploadButton.coffee \
	src/elements/FileUpload/FileUpload.coffee \
	src/elements/FileUpload/FileReader.coffee \
	src/elements/FileUpload/FileReaderFile.coffee \
	src/elements/Input/InputBlock.coffee \
	src/elements/Input/NumberInputBlock.coffee \
	src/elements/Input/NumberInput.coffee \
	src/elements/Input/EmailInput.coffee \
	src/elements/DateTime/DateTime.coffee \
	src/elements/DateTime/DateTimeFormats.coffee \
	src/elements/DateTime/DateTimeInputBlock.coffee \
	src/elements/Password/Password.coffee \
	src/elements/MultiInput/MultiInputControl.coffee \
	src/elements/MultiInput/MultiInput.coffee \
	src/elements/MultiInput/MultiInputInput.coffee \
	src/elements/Checkbox/Checkbox.coffee \
	src/elements/Options/Options.coffee \
	src/elements/ObjectDumper/ObjectDumper.coffee \
	src/elements/Output/Output.coffee \
	src/elements/Output/OutputContent.coffee \
	src/elements/MultiOutput/MultiOutput.coffee \
	src/elements/FormButton/FormButton.coffee \
	src/elements/Form/Form.coffee \
	src/elements/FormPopover/FormPopover.coffee \
	src/elements/FormModal/FormModal.coffee \
	src/elements/DataTable/DataTable.coffee \
	src/elements/DataTable/DataTableNode.coffee \
	src/elements/Select/Select.coffee \
	src/elements/StickyHeader/StickyHeader.coffee \
	src/elements/StickyHeader/StickyHeaderControl.coffee \
	src/elements/DigiDisplay/DigiDisplay.coffee \
	src/elements/Table/Table.coffee \
	src/elements/DocumentBrowser/DocumentBrowser.coffee \
	src/elements/DocumentBrowser/Node.coffee \
	src/elements/DocumentBrowser/NodeMatch.coffee \
	src/elements/DocumentBrowser/SearchMatch.coffee \
	src/elements/DocumentBrowser/SearchQuery.coffee

files = $(addsuffix .js, $(coffee_files))

test_files = src/tests/Test.coffee.js \
	src/tests/Test_MoveInArray.coffee.js \
	src/tests/Test_Promise.coffee.js

# thirdparty/*/jquery-2.1.0.js \

thirdparty_files = thirdparty/moment/*js \
	thirdparty/moment/*json \
	thirdparty/marked/lib/marked.js

html_files = \
	src/base/Base.html \
	src/base/Layer/Layer.html \
	src/base/DataField/DataField.html \
	src/elements/Button/Button.html \
	src/elements/Button/Button_ng.html \
	src/elements/FileUpload/FileUploadButton.html \
	src/elements/Button/ButtonHref.html \
	src/elements/Button/ButtonHref_ng.html \
	src/elements/Options/Options.html \
	src/elements/Button/Buttonbar.html \
	src/elements/BorderLayout/BorderLayout.html \
	src/elements/HorizontalLayout/HorizontalLayout.html \
	src/elements/VerticalLayout/VerticalLayout.html \
	src/elements/DateTime/DateTime.html \
	src/elements/ListView/tools/ListViewTool.html \
	src/elements/Tabs/Tabs.html \
	src/elements/Label/Label.html \
	src/elements/MultiInput/MultiInputInput.html \
	src/elements/ProgressMeter/ProgressMeter.html \
	src/elements/Block/Block.html \
	src/elements/WaitBlock/WaitBlock.html \
	src/elements/ItemList/ItemList.html \
	src/elements/Panel/Panel.html \
	src/elements/Pane/Pane.html \
	src/elements/StickyHeader/StickyHeader.html \
	src/elements/Tabs/Tab.html

all: code demo css
	#
	# $@
	mkdir -p $(target)

font_awesome:
	#
	# $@
	mkdir -p $(target)

	rm -rf $(target)/font-awesome
	mkdir -p $(target)/font-awesome/css
	mkdir -p $(target)/font-awesome/fonts

	rsync -r thirdparty/font-awesome-4.5.0/css $(target)/font-awesome/
	rsync -r thirdparty/font-awesome-4.5.0/fonts $(target)/font-awesome/
	cp $(thirdparty_files) $(target)

highlight_files = \
	thirdparty/highlight/highlight.pack.js \
	thirdparty/highlight/styles/atom-one-dark.css

highlight:
	#
	# $@
	mkdir -p $(target)

	rm -rf $(target)/highlight
	mkdir -p $(target)/highlight

	rsync -r thirdparty/highlight/styles/atom-one-dark.css $(target)/highlight
	rsync -r thirdparty/highlight/highlight.pack.js $(target)/highlight
	cp $(highlight_files) $(target)/highlight

demo: font_awesome
	$(MAKE) --directory demo all

code: $(easydbui_js) $(thirdparty_files) html font_awesome highlight
	cp src/scss/icons/icons.svg $(target)/icons.svg
	cp src/scss/icons/inherit.svg $(target)/inherit.svg
	cp src/scss/icons/remove-icon.svg $(target)/remove-icon.svg
	cp src/scss/icons/merge-icon.svg $(target)/merge-icon.svg
	cp src/scss/icons/arrow-right.svg $(target)/arrow-right.svg
	$(MAKE) --directory demo code

css_ng:
	#
	# $@
	mkdir -p $(css_target)
	$(call_scss) src/scss/themes/ng/main.scss $(css_target)/cui_ng.css
	$(call_scss) src/scss/themes/ng_debug/main.scss $(css_target)/cui_ng_debug.css
	$(MAKE) --directory demo css_ng

css_other:
	#
	# $@
	mkdir -p $(css_target)
	$(call_scss) src/scss/themes/light/main.scss $(css_target)/cui_light.css
	$(call_scss) src/scss/themes/dark/main.scss $(css_target)/cui_dark.css
	$(MAKE) --directory demo css_other

css: css_ng css_other

html: $(html_files)
	#
	# $@
	mkdir -p $(target)
	@cat $(html_files) > $(target)/easydbui.html

docs: $(files)
	#
	# $@

	mkdir -p $(target)
	rm -rf $(target)/docs
	codo $(files:.coffee.js=.coffee)

$(easydbui_js): $(files) $(test_files)
	#
	# $@
	mkdir -p $(target)
# cat $(files) | perl -00 -pne 's/(?s)(assert\(.*?\);)/\/* $$1 *\//m' > $@
	@cat $(files) $(test_files) > $@

clean:
	$(MAKE) --directory demo clean
	rm -rf $(target)
	find src -name '*.coffee.js' | xargs rm -f
	rm -f $(files_txt)

wipe: clean
	$(MAKE) --directory demo wipe
	find . -name '*~' -or -name '#*#' | xargs rm -f
	find . -name '.sass-cache' | xargs rm -rf

%.coffee.js: %.coffee
	coffee -b -p --compile $^ > $@ || ( rm -f $@ ; false )

.PHONY: all demo css css_ng css_other clean clean-build wipe font_awesome
