default['couchpotatoserver'] = {
	'repo' => 'https://github.com/RuudBurger/CouchPotatoServer.git',
	'prerequisites' => {
		'linux' => [
			'git-core',
			'python'
		]
	},
	'init' => {
		'ubuntu' => 'init/ubuntu'
	},
	'defaults' => {
		'ubuntu' => 'init/ubuntu.default'
	},
	'config' => {
		'path' => '/opt/couchpotato',
		'branch' => 'master',
		# Service account
		'user' => 'servicecouchpotatoserver',
		# Service account
		'password' => 'pass',
		'datadir' => '/var/couchpotato/',
		'options' => ''
	}	
}