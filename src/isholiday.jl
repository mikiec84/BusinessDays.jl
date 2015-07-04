
# Fallback implementation for isholiday()
function isholiday( hc :: HolidayCalendar, dt :: TimeType)
	error("isholiday for $(hc) not yet implemented.")
end

# BrazilBanking <: HolidayCalendar
# Brazilian Banking Holidays
function isholiday( :: BrazilBanking , dt :: TimeType)

	const yy = Dates.year(dt)
	const mm = Dates.month(dt)
	const dd = Dates.day(dt)

	# Bisection
	if mm >= 8
		# Fixed holidays
		if (
				# Independencia do Brasil
				((mm == 9) && (dd == 7))
				||
				# Nossa Senhora Aparecida
				((mm == 10) && (dd == 12))
				||
				# Finados
				((mm == 11) && (dd == 2))
				||
				# Proclamacao da Republica
				((mm == 11) && (dd == 15))
				||
				# Natal
				((mm == 12) && (dd == 25))
			)
			return true
		end	
	else
		# mm < 8
		# Fixed holidays
		if (
				# Confraternizacao Universal
				((mm == 1) && (dd == 1))
				||
				# Tiradentes
				((mm == 4) && (dd == 21))
				||
				# Dia do Trabalho	
				((mm == 5) && (dd == 1))
			)
			return true
		end

		# Easter occurs up to April, so Corpus Christi will be up to July in the worst case, which is before August (mm < 8). See test/easter-min-max.jl .
		# Holidays based on easter date
		const dt_rata :: Int64 = Dates.days(dt)
		const e_rata ::Int64 = easter_rata( Dates.Year(yy))

		if (
				# Segunda de Carnaval
				(  dt_rata == (  e_rata - 48  )   )
				||
				# Terca de Carnaval
				( dt_rata == (  e_rata - 47 )     )
				||
				# Sexta-feira Santa
				( dt_rata == ( e_rata - 2 )       )
				||
				# Corpus Christi
				( dt_rata == ( e_rata + 60)       )
			)
			return true
		end
	end

	return false
end

# weekday_target values:
# const Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday = 1,2,3,4,5,6,7
# See query.jl on Dates module
# See also dayofweek(dt) function.
# This should go to Base.Dates
function findweekday(weekday_target :: Int64, yy :: Int64, mm:: Int64, occurence :: Int64, ascending :: Bool )
	local dt :: Date = Date(yy, mm, 1)
	local dt_dayofweek :: Int64
	local offset :: Int64

	if occurence <= 0
		error("occurence must be >= 1. Provided $(occurence).")
	end

	if ascending
		dt_dayofweek = dayofweek(dt)
		offset = rem(weekday_target + 7 - dt_dayofweek, 7) # rem = MOD function
	else
		dt = lastdayofmonth(dt)
		dt_dayofweek = dayofweek(dt)
		offset = rem(dt_dayofweek + 7 - weekday_target, 7)
	end

	if occurence > 1
		offset += 7 * (occurence - 1)
	end

	if ascending
		return dt + Dates.Day(offset)
	else
		return dt - Dates.Day(offset)
	end
end

# In the United States, if a holiday falls on Saturday, it's observed on the preceding Friday.
# If it falls on Sunday, it's observed on the next Monday.
function adjustweekendholiday(dt :: TimeType)
	
	if dayofweek(dt) == Dates.Saturday
		return dt - Dates.Day(1)
	end

	if dayofweek(dt) == Dates.Sunday
		return dt + Dates.Day(1)
	end

	return dt
end

function isholiday( :: UnitedStates , dt :: TimeType)

	const dt_Date = convert(Dates.Date, dt)

	const yy = Dates.year(dt)
	##const mm = Dates.month(dt)
	##const dd = Dates.day(dt)

	const dt_rata = Dates.days(dt)

	if (
			# New Year's Day
			adjustweekendholiday(Date(yy, 1, 1)) == dt_Date
			||
			# Birthday of Martin Luther King, Jr.
			adjustweekendholiday(  findweekday(Dates.Monday, yy, 1, 3, true) ) == dt_Date
			||
			# Washington's Birthday
			adjustweekendholiday(  findweekday(Dates.Monday, yy, 2, 3, true) ) == dt_Date
			||
			# Memorial Day
			adjustweekendholiday(  findweekday(Dates.Monday, yy, 5, 1, false) ) == dt_Date
			||
			# Independence Day
			adjustweekendholiday(Date(yy, 7, 4)) == dt_Date
			||
			# Labor Day
			adjustweekendholiday(  findweekday(Dates.Monday, yy, 9, 1, true) ) == dt_Date
			||
			# Columbus Day
			adjustweekendholiday(  findweekday(Dates.Monday, yy, 10, 2, true) ) == dt_Date
			||
			# Veterans Day
			adjustweekendholiday(Date(yy, 11, 11)) == dt_Date
			||
			# Thanksgiving Day
			adjustweekendholiday(  findweekday(Dates.Thursday, yy, 11, 4, true) ) == dt_Date
			||
			# Christmas
			adjustweekendholiday(Date(yy, 12, 25)) == dt_Date
		)
		return true
	end
	
	return false

end