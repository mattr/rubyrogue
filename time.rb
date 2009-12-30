    # 24 hours a day
    # day is the day of year; 0 is the first day in new year
    # year is 360 days long; each season is 90 days long
    # -cos(x) function is used to determine inclination of the sun
    # Thus on day 0 sine is the lowest, which means the sun is at lower peak (longest night at northern hemisphere, longest day at southern hemisphere)
    # Spring begins at 45 days, summer begins at 135 days, fall begins at 225 days and winter begins at 315 days
    # Seasons are separated into three months, so there are twelve months in total
    
module Time
  DAYS_PER_YEAR = 360
  HOURS_PER_DAY = 24
  MINUTES_PER_HOUR = 60
  SECONDS_PER_MINUTE = 60
  DAYS_PER_WEEK = 10
  # four seasons, ninety days a season, Spring begins on 45th day and ends on 134th day etc., Winter should wrap automatically
  SEASONS = {:Spring => 45...135, :Summer => 135...225, :Fall => 225...315, :Winter => 315...405}
  WEEKDAYS = [:Oneday, :Twoday, :Threeday, :Fourday, :Fiveday, :Sixday, :Sevenday, :Eightday, :Nineday, :Tenday]
  #placeholder month names, 12 months a year, 360/12 = 30 days a month, 3 weeks a month
  MONTHS = [:First, :Second, :Third, :Fourth, :Fifth, :Sixth, :Seventh, :Eighth, :Ninth, :Tenth, :Eleventh, :Twelfth]
  
end