'use strict';
'require baseclass';
'require view.status.bandwidth as bandwidth';

return baseclass.extend({
	title: _('Bandwidth'),
	disableCache: true,
	rendered: false,

	load: function() {
		if (this.rendered)
			return Promise.resolve(null);

		return bandwidth.load();
	},

	render: function(data) {
		if (this.rendered || data == null)
			return null;

		this.rendered = true;

		var content = bandwidth.render(data);
		var heading = content.querySelector && content.querySelector('h2');
		var description = content.querySelector && content.querySelector('.cbi-map-descr');

		if (heading)
			heading.remove();

		if (description)
			description.remove();

		return content;
	}
});
