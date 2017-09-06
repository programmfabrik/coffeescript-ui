PATH := ./node_modules/.bin:$(PATH)

target = public
css_target = $(target)/css

call_scss = sass --scss --no-cache --sourcemap=inline
cui_js = $(target)/cui.js

coffee_files = \
	src/base/CUI.coffee \
	src/base/Common.coffee \
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
	src/base/Events/TouchEvent.coffee \
	src/base/Events/CUIEvent.coffee \
	src/base/Events/Listener.coffee \
	src/base/Events/WheelEvent.coffee \
	src/base/Events/Events.coffee \
	src/base/DragDropSelect/DragoverScrollEvent.coffee \
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
	src/elements/ListView/ListViewTreeHeaderNode.coffee \
	src/elements/ListView/ListViewColumn.coffee \
	src/elements/ListView/ListViewColumnEmpty.coffee \
	src/elements/ListView/ListViewHeaderColumn.coffee \
	src/elements/ListView/tools/ListViewColumnRowMoveHandle.coffee \
	src/elements/ListView/tools/ListViewColumnRowMoveHandlePlaceholder.coffee \
	src/elements/ListView/tools/ListViewDraggable.coffee \
	src/elements/ListView/tools/ListViewRowMove.coffee \
	src/elements/ListView/tools/ListViewColResize.coffee \
	src/elements/ListView/tools/ListViewTreeRowMove.coffee \
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
	src/elements/ObjectDumper/ObjectDumperNode.coffee \
	src/elements/Output/Output.coffee \
	src/elements/Output/OutputContent.coffee \
	src/elements/MultiOutput/MultiOutput.coffee \
	src/elements/FormButton/FormButton.coffee \
	src/elements/Form/SimpleForm.coffee \
	src/elements/Form/Form.coffee \
	src/elements/FormPopover/FormPopover.coffee \
	src/elements/FormModal/FormModal.coffee \
	src/elements/DataTable/DataTable.coffee \
	src/elements/DataTable/DataTableNode.coffee \
	src/elements/DataForm/DataForm.coffee \
	src/elements/Select/Select.coffee \
	src/elements/StickyHeader/StickyHeader.coffee \
	src/elements/StickyHeader/StickyHeaderControl.coffee \
	src/elements/DigiDisplay/DigiDisplay.coffee \
	src/elements/Table/Table.coffee \
	src/elements/DocumentBrowser/DocumentBrowser.coffee \
	src/elements/DocumentBrowser/Node.coffee \
	src/elements/DocumentBrowser/NodeMatch.coffee \
	src/elements/DocumentBrowser/SearchMatch.coffee \
	src/elements/DocumentBrowser/SearchQuery.coffee \
	src/elements/Slider/Slider.coffee \
	src/base/CSVData.coffee\
	src/base/windowCompat.coffee

files = $(addsuffix .js, $(coffee_files))

test_files = src/tests/Test.coffee.js \
	src/tests/Test_MoveInArray.coffee.js \
	src/tests/Test_Promise.coffee.js

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
	src/elements/Slider/Slider.html \
	src/elements/Button/Buttonbar.html \
	src/elements/BorderLayout/BorderLayout.html \
	src/elements/HorizontalLayout/HorizontalLayout.html \
	src/elements/VerticalLayout/VerticalLayout.html \
	src/elements/DateTime/DateTime.html \
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

all: code css font_awesome $(thirdparty_files)
	#
	# $@
	mkdir -p $(target)/js
	cp $(thirdparty_files) $(target)/js

font_awesome:
	#
	# $@
	mkdir -p $(target)

	rm -rf $(target)/font-awesome
	mkdir -p $(target)/font-awesome/css
	mkdir -p $(target)/font-awesome/fonts

	rsync -r thirdparty/font-awesome-4.5.0/css $(target)/font-awesome/
	rsync -r thirdparty/font-awesome-4.5.0/fonts $(target)/font-awesome/


code: $(cui_js) html

css:
	#
	# $@
	mkdir -p $(css_target)
	$(call_scss) src/scss/themes/ng/main.scss $(css_target)/cui_ng.css
	# $(call_scss) src/scss/themes/ng_debug/main.scss $(css_target)/cui_ng_debug.css
	cp src/scss/icons/icons.svg $(target)/css/icons.svg

html: $(html_files)
	#
	# $@
	mkdir -p $(target)
	@cat $(html_files) > $(target)/cui.html

docs: $(files)
	#
	# $@

	mkdir -p $(target)
	rm -rf $(target)/docs
	codo $(files:.coffee.js=.coffee)

$(cui_js): $(files) $(test_files)
	#
	# $@
	mkdir -p $(target)/js
# cat $(files) | perl -00 -pne 's/(?s)(assert\(.*?\);)/\/* $$1 *\//m' > $@
	@cat $(files) $(test_files) > $@

clean:
	rm -rf $(target)
	find src -name '*.coffee.js' | xargs rm -f
	rm -f $(files_txt)

wipe: clean
	find . -name '*~' -or -name '#*#' | xargs rm -f
	find . -name '.sass-cache' | xargs rm -rf

%.coffee.js: %.coffee
	coffee -b -p --compile $^ > $@ || ( rm -f $@ ; false )

.PHONY: all css clean wipe font_awesome
