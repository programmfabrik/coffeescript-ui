###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class DateTimeDemo extends Demo
	display: ->
		data =
			date_and_time_short: "2014-11-14T15:57:00+01:00"
			date_only: "2010-05-29T13:14:24Z"
			euros: 123456

		form = new Form
			data: data
			onDataChanged: ->
				#  CUI.debug dump(data)

			fields: [
				form: label: "Date + Time + Seconds [default]"
				name: "date_time_secs"
				type: DateTime
				input_types: null # use all
				onDataChanged: (data, df) =>
					@log(df.getName()+": value: "+data[df.getName()])
			,
				type: DateTime
				form: label: "Date + Time + Seconds (Short) [de-DE]"
				name: "date_and_time_short"
				display_type: "short"
				locale: "de-DE"
				onDataChanged: (data, df) =>
					@log(df.getName()+": value: "+data[df.getName()])
			,
				type: DateTime
				form: label: "Date + Time + [de-DE]"
				name: "date_and_time"
				locale: "de-DE"
				onDataChanged: (data, df) =>
					@log(df.getName()+": value: "+data[df.getName()])
			,
				type: DateTime
				form: label: "Date [de-DE]"
				name: "date_month_year"
				locale: "de-DE"
				display_type: "short"
				input_types: ["date", "year_month", "year"]
			,
				form: label: "Date (year allowed) [de-DE]"
				name: "date_only"
				type: DateTime
				locale: "de-DE"
				input_types: [ "date", "year_month", "year" ]
				onDataChanged: (data, df) =>
					@log(df.getName()+": value: "+data[df.getName()])
			,
				form: label: "Date + Time + Seconds [en-US]"
				name: "date_time_secs"
				type: DateTime
				input_types: null # use all
				locale: "en-US"
				onDataChanged: (data, df) =>
					@log(df.getName()+": value: "+data[df.getName()])
			]

		form.start()

Demo.register(new DateTimeDemo())
