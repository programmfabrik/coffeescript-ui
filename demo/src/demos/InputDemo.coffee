###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class Demo.InputDemo extends Demo
	display: ->
		data =
			plain_input: "12.02.2010"
			select_input: "Select Me"
			number: null
			number_int: undefined
			plain_input_over: "123---3423-121--22"
			plain_textarea: "wqsio qsq woisjqwo sjqwois jwqios jwqiosj wqoisjqw oisjwq sjwqois jqwisowqj soiwjqsoiwqj siojqw soiwjqsoi wqjsioq wjsioqw jsoiwqjs oqiwsj qwoisjq woisjqw oisjwqis jqw soijqwsio wqsioqwjs ioqwjs oiwqjsioqw sjoiwq jsoqiws"
			plain_textarea_over: "wqsio qsq woisjqwo sjqwois jwqios jwqiosj wqoisjqw oisjwq sjwqois jqwisowqj soiwjqsoiwqj siojqw soiwjqsoi wqjsioq wjsioqw jsoiwqjs oqiwsj qwoisjq woisjqw oisjwqis jqw soijqwsio wqsioqwjs ioqwjs oiwqjsioqw sjoiwq jsoqiws"
			dollars: 12345589
			content_size_textarea: "wqsio qsq woisjqwo sjqwois jwqios jwqiosj wqoisjqw oisjwq sjwqois jqwisowqj soiwjqsoiwqj siojqw soiwjqsoi wqjsioq wjsioqw jsoiwqjs oqiwsj qwoisjq woisjqw oisjwqis jqw soijqwsio wqsioqwjs ioqwjs oiwqjsioqw sjoiwq jsoqiws"
			euros: 123456
			multiOutput: {
				"de-DE": "DE DE DE DE",
				"en-US": "US US US US"
			}

		multi_input_control = new CUI.MultiInputControl
			user_control: true
			preferred_key: "de-DE"
			keys: [
				name: "de-DE"
				tag: "DE"
				enabled: true
				tooltip: text: "de-DE"
			,
				name: "en-US"
				tag: "EN"
				tooltip: text: "en-US"
			,
				name: "fr-FR"
				tag: "FR"
				tooltip: text: "fr-FR"
			]


		form = new CUI.Form
			data: data
			onDataChanged: ->
				#  console.debug CUI.util.dump(data)

			fields: [
				form: label: "Input"
				name: "plain_input"
				type: CUI.Input
			,
				form: label: "Input (Readonly, select all)"
				name: "select_input"
				readonly: true
				type: CUI.Input
			,
				form: label: "Input (Readonly, selectable)"
				name: "select_input"
				readonly_select_all: false
				readonly: true
				type: CUI.Input
			,
				form: label: "Overwrite Mode"
				name: "plain_input_over"
				type: CUI.Input
				overwrite: true
			,
				form:
					label: "Content Size Mode"
				name: "content_size_mode"
				type: CUI.Input
				content_size: true
			,
				form: label: "Cursor Blocks (Numbers)"
				name: "plain_input_over"
				type: CUI.Input
				getCursorBlocks: (v) ->
					blocks = []
					for i in [0...v.length]
						if not v.substr(i, 1).match(/[0-9]/)
							continue
						blocks.push new CUI.InputBlock
							start: i
							string: v.substr(i, 1)
					blocks.push new CUI.InputBlock
						start: v.length
						string: ""
					blocks
			,
				form: label: "Cursor Blocks (Slim)"
				type: CUI.Input
				getCursorBlocks: (v) ->
					blocks = []
					for i in [0..v.length]
						blocks.push new CUI.InputBlock
							start: i
							string: ""
					blocks
			,
				form: label: "Checked, Numbers + Spaces"
				type: CUI.Input
				correctValueForInput: (df, value) =>
					# replace spaces this with a wide space
					value.replace(/\s+/g, "\u2007")

				checkInput: (value) ->
					if value.match(/^[\s0-9]*$/)
						return true
					else
						return false
			,
				form: label: "Two for 2"
				type: CUI.Input

				getValueForDisplay: (df, value) =>
					for k, v of Demo.InputDemo.numbers
						re = new RegExp(""+v, "g")
						value = value.replace(re, k)
					value

				getValueForInput: (df, value) =>
					df.correctValueForInput(value)

				correctValueForInput: (df, value) =>
					for k, v of Demo.InputDemo.numbers
						re = new RegExp(""+k, "g")
						value = value.replace(re, v+" ")
					value = value.replace(/\s{2,}/g, " ")
					if value.trim() == ""
						value = ""
					value

				getCursorBlocks: (v) =>
					blocks = []
					re = new RegExp("("+Object.values(Demo.InputDemo.numbers).join("|")+")","g")
					blocks = []
					while (match = re.exec(v)) != null
						match_str = match[0]
						match_start = match.index
						blocks.push new DigitInputBlock
							start: match_start
							string: match_str
					blocks.push new CUI.InputBlock
						start: v.length
						string: ""
					blocks
			,
				form:
					label: "Needs Integer between 100 and 1000"
				type: CUI.Input
				emptyHint:
					text: "Needs Integer between 100 and 1000"
				required: true
				invalidHint:
					text: "Enter something valid!"
				validHint:
					text: "Thank you"
				checkInput: (value) ->
					console.debug "check input", value
					if not (100 <= CUI.util.getInt(value) <= 1000)
						false
					else
						true

			,
				form: label: "NumberInput(0)"
				type: CUI.NumberInput
				name: "number"
				placeholder: "Decimal 0"
				decimals: 0
			,
				form: label: "NumberInput(2,int)"
				type: CUI.NumberInput
				name: "number_int"
				placeholder: "Decimal 2, Store Integer"
				decimals: 2
				store_as_integer: true
			,
				form: label: "Currency €"
				type: CUI.NumberInput
				decimalpoint: ","
				store_as_integer: true
				symbol: "€"
				separator: "."
				name: "euros"
				decimals: 2
			,
				form: label: "Currency $, no cents"
				type: CUI.NumberInput
				name: "dollars"
				decimalpoint: "."
				symbol: "$"
				symbol_before: true
				separator: ","
				decimals: 0
			,
				form: label: "Email"
				type: CUI.EmailInput
				invalidHint:
					text: "Valid Email required"
				placeholder: "Email"
				name: "email"
			,
				form: label: "Regexp"
				type: CUI.Input
				regexp: "^[a-z0-9]*$"
				regexp_flags: "i"
				placeholder: "/^[a-z0-9]+$/i"
				name: "regexp"
			,
				form: label: "Regexp (prevent invalid)"
				type: CUI.Input
				prevent_invalid_input: true
				regexp: "^[a-z0-9]*$"
				regexp_flags: "i"
				placeholder: "/^[a-z0-9]+$/i"
				name: "regexp"
			,
				form: label: "Input with Multi Input Control"
				name: "select_multi_input_with_multi_input_control"
				type: CUI.MultiInput
				spellcheck: true
				control: multi_input_control
			,
				form: label: "Textarea with Multi Input Control"
				name: "select_multi_input_with_multi_input_control"
				type: CUI.MultiInput
				spellcheck: true
				textarea: true
				control: multi_input_control
			,
				form: label: "Textarea Content Size"
				name: "select_multi_input"
				type: CUI.Input
				spellcheck: true
				textarea: true
				content_size: true
			,
				form: label: "Textarea Content Size (rows=4)"
				name: "select_multi_input_2"
				type: CUI.Input
				rows: 4
				spellcheck: true
				textarea: true
				content_size: true
			,
				form: label: "Plain Multiline Input (spellcheck)"
				name: "plain_textarea"
				spellcheck: true
				type: CUI.Input
				textarea: true
			,
				form: label: "Plain Multiline Input (overwrite)"
				name: "plain_textarea_over"
				overwrite: true
				type: CUI.Input
				textarea: true
			,
				form: label: "Content Size Multiline Input"
				name: "content_size_textarea"
				type: CUI.Input
				textarea: true
				content_size: true
			,
				form: label: "Multioutput with showOnlyPreferredKey: true"
				name: "multiOutput"
				type: CUI.MultiOutput
				control: multi_input_control
			,
				form: label: "Multioutput"
				name: "multiOutput"
				showOnlyPreferredKey: false
				type: CUI.MultiOutput
				control: multi_input_control
			]


		formInTab = new CUI.Form
			data: data

			fields: [

				form: label: "Content Size Multiline Input"
				name: "content_size_textarea"
				type: CUI.Input
				textarea: true
				content_size: true

			]



		examples_div = CUI.dom.div('Examples')
		CUI.dom.append(examples_div, form.start().DOM)

		tabs = new CUI.Tabs
			footer_right: "Right"
			footer_left: "Left"
			tabs: [
				text: "testTab1"
				content: formInTab.start().DOM
			,
				text: "testTab2"
				content: CUI.dom.text("nothing here")
			]

		CUI.dom.append(examples_div, tabs.DOM)

		examples_div



Demo.InputDemo.numbers =
	0: "zero"
	1: "one"
	2: "two"
	3: "three"
	4: "four"
	5: "five"
	6: "six"
	7: "seven"
	8: "eight"
	9: "nine"


class Demo.DigitInputBlock extends CUI.InputBlock

	incrementBlock: (block, blocks) ->
		idx = @getIdx(block)
		if idx == null
			return
		idx = (idx+1)%10
		block.setString(Demo.InputDemo.numbers[idx])

	decrementBlock: (block, blocks) ->
		idx = @getIdx(block)
		if idx == null
			return
		idx = (idx+10-1)%10
		block.setString(Demo.InputDemo.numbers[idx])


	getIdx: (block) ->
		for n, idx in Object.values(Demo.InputDemo.numbers)
			if block.string == n
				return idx
		return null




Demo.register(new Demo.InputDemo())
