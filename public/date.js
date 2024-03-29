Date.prototype.setISO8601 = function(dString){
	var regexp = /(\d\d\d\d)(-)?(\d\d)(-)?(\d\d)(T)?(\d\d)(:)?(\d\d)(:)?(\d\d)(\.\d+)?(Z|([+-])(\d\d)(:)?(\d\d))/;

	if (dString.toString().match(new RegExp(regexp))) {
		var d = dString.match(new RegExp(regexp));
		var offset = 0;

		this.setUTCDate(1);
		this.setUTCFullYear(parseInt(d[1],10));
		this.setUTCMonth(parseInt(d[3],10) - 1);
		this.setUTCDate(parseInt(d[5],10));
		this.setUTCHours(parseInt(d[7],10));
		this.setUTCMinutes(parseInt(d[9],10));
		this.setUTCSeconds(parseInt(d[11],10));
		if (d[12])
		this.setUTCMilliseconds(parseFloat(d[12]) * 1000);
		else
		this.setUTCMilliseconds(0);
		if (d[13] != 'Z') {
			offset = (d[15] * 60) + parseInt(d[17],10);
			offset *= ((d[14] == '-') ? -1 : 1);
			this.setTime(this.getTime() - offset * 60 * 1000);
		}
	}
	else {
		this.setTime(Date.parse(dString));
	}
	return this;
};

Date.prototype.isToday = function() {
	today = new Date ();
	return (this.getDate() == today.getDate() && this.getFullYear() == today.getFullYear() && this.getMonth() == today.getMonth());
}

Date.prototype.isTomorrow = function() {
	tomorrow = new Date ();
	tomorrow.setDate(tomorrow.getDate() + 1);
	return (this.getDate() == today.getDate() && this.getFullYear() == today.getFullYear() && this.getMonth() == today.getMonth());
}

Date.prototype.isLater = function() {
	later = new Date ();
	later.setDate(tomorrow.getDate() + 2);
	return (this.getDate() >= today.getDate() && this.getFullYear() >= today.getFullYear() && this.getMonth() >= today.getMonth());
}