'use strict';
'require baseclass';
'require rpc';

var callGetUnixtime = rpc.declare({
	object: 'luci',
	method: 'getUnixtime',
	expect: { result: 0 }
});

var callSystemBoard = rpc.declare({
	object: 'system',
	method: 'board'
});

var callSystemInfo = rpc.declare({
	object: 'system',
	method: 'info'
});

var callCPUBench = rpc.declare({
	object: 'luci',
	method: 'getCPUBench'
});

var callCPUInfo = rpc.declare({
	object: 'luci',
	method: 'getCPUInfo'
});

var callCPUUsage = rpc.declare({
	object: 'luci',
	method: 'getCPUUsage'
});

return baseclass.extend({
	title: _('System'),
	disableCache: true,

	load: function() {
		return Promise.all([
			L.resolveDefault(callSystemBoard(), {}),
			L.resolveDefault(callSystemInfo(), {}),
			L.resolveDefault(callCPUBench(), {}),
			L.resolveDefault(callCPUInfo(), {}),
			L.resolveDefault(callCPUUsage(), {}),
			L.resolveDefault(callGetUnixtime(), 0)
		]);
	},

	render: function(data) {
		var boardinfo   = data[0],
		    systeminfo  = data[1],
		    cpubench    = data[2],
		    cpuinfo     = data[3],
		    cpuusage    = data[4],
		    unixtime    = data[5];

		var datestr = null;

		if (unixtime) {
			var date = new Date(unixtime * 1000);

			datestr = new Intl.DateTimeFormat(undefined, {
				dateStyle: 'medium',
				timeStyle: 'long'
			}).format(date);
		}

		var fields = [
			_('Hostname'),         boardinfo.hostname,
			_('Model'),            boardinfo.model + cpubench.cpubench,
			_('Architecture'),     cpuinfo.cpuinfo || boardinfo.system,
			_('Target Platform'),  (L.isObject(boardinfo.release) ? boardinfo.release.target : ''),
			_('Firmware Version'), E('span', { 'class': '39wrt-overview-links' }, [
				L.isObject(boardinfo.release)
					? '%s%s'.format(
						boardinfo.release.description || '',
						boardinfo.release.revision ? boardinfo.release.revision : ''
					)
					: '',
				' / ',
				E('a', {
					'href': 'https://qm.qq.com/q/ZpmZV0JCwK',
					'target': '_blank',
					'rel': 'noreferrer noopener'
				}, [ '加入QQ群' ]),
				' / ',
				E('a', {
					'href': 'http://survey.39network.cc:1991/s/MOdTeR',
					'target': '_blank',
					'rel': 'noreferrer noopener'
				}, [ 'BUG反馈' ])
			]),
			_('Kernel Version'),   boardinfo.kernel,
			_('Local Time'),       datestr,
			_('Uptime'),           systeminfo.uptime ? '%t'.format(systeminfo.uptime) : null,
			_('Load Average'),     Array.isArray(systeminfo.load) ? '%.2f, %.2f, %.2f'.format(
				systeminfo.load[0] / 65535.0,
				systeminfo.load[1] / 65535.0,
				systeminfo.load[2] / 65535.0
			) : null,
			_('CPU usage (%)'),    cpuusage.cpuusage
		];

		var table = E('table', { 'class': 'table' });

		for (var i = 0; i < fields.length; i += 2) {
			table.appendChild(E('tr', { 'class': 'tr' }, [
				E('td', { 'class': 'td left', 'width': '33%' }, [ fields[i] ]),
				E('td', { 'class': 'td left' }, [ (fields[i + 1] != null) ? fields[i + 1] : '?' ])
			]));
		}

		return table;
	}
});
