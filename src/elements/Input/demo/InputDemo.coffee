class InputDemo extends Demo
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

		multi_input_control = new MultiInputControl
			user_control: true
			preferred_key: "de-DE"
			keys: [
				name: "de-DE"
				tag: "DE"
				enabled: true
			,
				name: "en-US"
				tag: "EN"
			,
				name: "fr-FR"
				tag: "FR"
			]


		form = new Form
			data: data
			onDataChanged: ->
				#  CUI.debug dump(data)

			fields: [
				form: label: "Input"
				name: "plain_input"
				type: Input
			,
				form: label: "Input (Readonly, select all)"
				name: "select_input"
				readonly: true
				type: Input
			,
				form: label: "Input (Readonly, selectable)"
				name: "select_input"
				readonly_select_all: false
				readonly: true
				type: Input
			,
				form: label: "Overwrite Mode"
				name: "plain_input_over"
				type: Input
				overwrite: true
			,
				form:
					label: "Content Size Mode"
				name: "content_size_mode"
				type: Input
				content_size: true
			,
				form: label: "Cursor Blocks (Numbers)"
				name: "plain_input_over"
				type: Input
				getCursorBlocks: (v) ->
					blocks = []
					for i in [0...v.length]
						if not v.substr(i, 1).match(/[0-9]/)
							continue
						blocks.push new InputBlock
							start: i
							string: v.substr(i, 1)
					blocks.push new InputBlock
						start: v.length
						string: ""
					blocks
			,
				form: label: "Cursor Blocks (Slim)"
				type: Input
				getCursorBlocks: (v) ->
					blocks = []
					for i in [0..v.length]
						blocks.push new InputBlock
							start: i
							string: ""
					blocks
			,
				form: label: "Checked, Numbers + Spaces"
				type: Input
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
				type: Input

				getValueForDisplay: (df, value) =>
					for k, v of InputDemo.numbers
						re = new RegExp(""+v, "g")
						value = value.replace(re, k)
					value

				getValueForInput: (df, value) =>
					df.correctValueForInput(value)

				correctValueForInput: (df, value) =>
					for k, v of InputDemo.numbers
						re = new RegExp(""+k, "g")
						value = value.replace(re, v+" ")
					value = value.replace(/\s{2,}/g, " ")
					if value.trim() == ""
						value = ""
					value

				getCursorBlocks: (v) =>
					blocks = []
					re = new RegExp("("+Object.values(InputDemo.numbers).join("|")+")","g")
					blocks = []
					while (match = re.exec(v)) != null
						match_str = match[0]
						match_start = match.index
						blocks.push new DigitInputBlock
							start: match_start
							string: match_str
					blocks.push new InputBlock
						start: v.length
						string: ""
					blocks
			,
				form:
					label: "Needs Integer between 100 and 1000"
				type: Input
				emptyHint:
					text: "Needs Integer between 100 and 1000"
				required: true
				invalidHint:
					text: "Enter something valid!"
				validHint:
					text: "Thank you"
				checkInput: (value) ->
					CUI.debug "check input", value
					if not (100 <= getInt(value) <= 1000)
						false
					else
						true

			,
				form: label: "NumberInput(0)"
				type: NumberInput
				name: "number"
				placeholder: "Decimal 0"
				decimals: 0
			,
				form: label: "NumberInput(2,int)"
				type: NumberInput
				name: "number_int"
				placeholder: "Decimal 2, Store Integer"
				decimals: 2
				store_as_integer: true
			,
				form: label: "Currency €"
				type: NumberInput
				decimalpoint: ","
				store_as_integer: true
				symbol: "€"
				separator: "."
				name: "euros"
				decimals: 2
			,
				form: label: "Currency $, no cents"
				type: NumberInput
				name: "dollars"
				decimalpoint: "."
				symbol: "$"
				symbol_before: true
				separator: ","
				decimals: 0
			,
				form: label: "Email"
				type: EmailInput
				invalidHint:
					text: "Valid Email required"
				placeholder: "Email"
				name: "email"
			,
				form: label: "Regexp"
				type: Input
				regexp: "^[a-z0-9]*$"
				regexp_flags: "i"
				placeholder: "/^[a-z0-9]+$/i"
				name: "regexp"
			,
				form: label: "Input with Multi Input Control"
				name: "select_multi_input_with_multi_input_control"
				type: MultiInput
				spellcheck: true
				control: multi_input_control
			,
				form: label: "Textarea with Multi Input Control"
				name: "select_multi_input_with_multi_input_control"
				type: MultiInput
				spellcheck: true
				textarea: true
				control: multi_input_control
			,
				form: label: "Textarea Content Size"
				name: "select_multi_input"
				type: Input
				spellcheck: true
				textarea: true
				content_size: true
			,
				form: label: "Plain Multiline Input (spellcheck)"
				name: "plain_textarea"
				spellcheck: true
				type: Input
				textarea: true
			,
				form: label: "Plain Multiline Input (overwrite)"
				name: "plain_textarea_over"
				overwrite: true
				type: Input
				textarea: true
			,
				form: label: "Content Size Multiline Input"
				name: "content_size_textarea"
				type: Input
				textarea: true
				content_size: true
			]


		formInTab = new Form
			data: data

			fields: [

				form: label: "Content Size Multiline Input"
				name: "content_size_textarea"
				type: Input
				textarea: true
				content_size: true

			]



		examples_div = $div('Examples')
		examples_div.append(form.start().DOM)

		tabs = new Tabs
			footer_right: "Right"
			footer_left: "Left"
			tabs: [
				text: "testTab1"
				content: formInTab.start().DOM
			,
				text: "testTab2"
				content: $text("nothing here")
			]

		examples_div.append(tabs.DOM)

		examples_div



InputDemo.numbers =
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


class DigitInputBlock extends InputBlock

	incrementBlock: (block, blocks) ->
		idx = @getIdx(block)
		if idx == null
			return
		idx = (idx+1)%10
		block.setString(InputDemo.numbers[idx])

	decrementBlock: (block, blocks) ->
		idx = @getIdx(block)
		if idx == null
			return
		idx = (idx+10-1)%10
		block.setString(InputDemo.numbers[idx])


	getIdx: (block) ->
		for n, idx in Object.values(InputDemo.numbers)
			if block.string == n
				return idx
		return null




Demo.register(new InputDemo())