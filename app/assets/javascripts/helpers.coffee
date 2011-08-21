#todo zhugrov a - should also be refactored

window.relative_time = (date, date0 = new Date()) ->
	date = new Date(date)
	date1 = new Date(date0)
	date1.setHours(0)
	date1.setMinutes(0)
	date1.setSeconds(0)
	date1.setMilliseconds(0)
	ds = parseInt((date0.getTime() - date.getTime()) / 1000)
	ps = ds - parseInt((date0.getTime() - date1.getTime()) / 1000)
	if ds < 60
		return 'меньше минуты назад'
	else if ds < 120
		return 'около минуты назад'
	else if ds < (60*60)
		m = parseInt(ds/60)
		return m + if m < 5 then ' минуты назад' else ' минут назад'
	else if ds < (120*60)
		return 'около часа назад';
	else if ds < (24*60*60)
		return "около #{parseInt(ds/3600)} часов назад"
	else if ps < (24*60*60)
		return 'вчера'
	else if ps < (48*60*60)
		return 'позавчера'
	else
		d = parseInt(ps/86400)+1
		return d + if d < 5 then ' дня назад' else ' дней назад'