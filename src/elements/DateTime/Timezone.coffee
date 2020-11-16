#moment = require('moment')
require('moment-timezone')

class CUI.Timezone
	@timezones: []
	@init: ->
		citiesByOffset = {}
		for timezoneCityName in CUI.util.moment.tz.names()
			if timezoneCityName.match("GMT") # For some reason moment.js returns cities with names like: "GMT-10".
				continue
			zone = CUI.util.moment.tz.zone(timezoneCityName)
			if zone.population == 0
				continue

			m = CUI.util.moment.tz(timezoneCityName)
			zoneName = @getTimezoneName(m.zoneAbbr())
			offset = m.format("Z")

			group = offset + zoneName
			if not citiesByOffset[group]
				citiesByOffset[group] = []

			city = timezoneCityName.split("/").pop().replace(/_/g, " ")
			if zoneName
				displayName = "(GMT#{offset}) #{zoneName} - #{city}"
			else
				displayName = "(GMT#{offset}) #{city}"

			citiesByOffset[group].push
				population: zone.population
				name: timezoneCityName
				zoneName: zoneName
				offset: offset
				displayName: displayName

		for _, cities of citiesByOffset
			cities.sort((a, b) -> b.population - a.population)
			if cities.length > 2
				cities.splice(Math.round(cities.length / 2))
			@timezones.push(cities...)

		@timezones.sort((a, b) -> a.displayName.localeCompare(b.displayName))
		@timezones.sort((a, b) -> parseInt(a.offset) - parseInt(b.offset))
		return

	# Guess the current timezone by using the zone with the largest population.
	# https://stackoverflow.com/questions/27930037/guesstimate-time-zone-from-time-offset-with-javascript-and-moment-js
	@getTimezone: ->
		return CUI.util.moment.tz.guess()

	@getTimezoneName: (abbr) ->
		return @timezonesAbbrs[abbr]

	# Moment.js does not provide full name of timezones.
	@timezonesAbbrs:
		GMT: 'Greenwich Mean Time'
		CET: 'Central European Time'
		CEST: 'Central European Summer Time'
		EEST: 'Eastern European Summer Time'
		IDT: 'Israel Daylight Time'
		MSK: 'Moscow Time Zone'
		EAT: 'East Africa Time'
		SAST: 'South African Standard Time'
		EET: 'Eastern European Time'
		CAT: 'Central Africa Time'
		WAT: 'West Africa Time'
		WEST: 'Western European Summer Time'
		BST: 'British Summer Time'
		EST: 'Eastern Standard Time'
		EDT: 'Eastern Daylight Time'
		CST: 'Central Standard Time'
		CDT: 'Central Daylight Time'
		MST: 'Mountain Standard Time'
		MDT: 'Mountain Daylight Time'
		PST: 'Pacific Standard Time'
		PDT: 'Pacific Daylight Time'
		IST: 'Indian Standard Time'
		JST: 'Japan Standard Time'
		HDT: 'Hawaii-Aleutian Daylight Time'
		HST: 'Hawaii–Aleutian Time'
		SST: 'Samoa Standard Time'
		AKDT: 'Alaska Daylight Time'
		ACDT: 'Australian Central Daylight Savings Time'
		ACST: 'Australian Central Standard Time'
		ADT: 'Atlantic Daylight Time'
		AEDT: 'Australian Eastern Daylight Savings Time'
		AEST: 'Australian Eastern Standard Time'
		AST: 'Atlantic Standard Time'
		AWST: 'Australian Western Standard Time'
		ChST: 'Chamorro Standard Time'
		HKT: 'Hong Kong Time'
		KST: 'Korea Standard Time'
		NDT: 'Newfoundland Daylight Time'
		NZDT: 'New Zealand Daylight Time'
		PKT: 'Pakistan Standard Time'
		WIB: 'Western Indonesia Time'
		WIT: 'Eastern Indonesia Time'
		WITA: 'Indonesia Central Time Zone'

CUI.ready =>
	CUI.Timezone.init()
