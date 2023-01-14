module.exports = {
  apps : [{
    name: 'Geth',
    script: 'geth',
    args: [ 
      '--ws', 
        '--ws.origins', "*", 
        '--ws.addr', '0.0.0.0',
      '--http', 
        '--http.vhosts', '*', 
        '--http.corsdomain', '*', 
        '--http.addr', '0.0.0.0', 
        '--http.api', 'web3,eth,personal,net',
      '--allow-insecure-unlock', 
      '--datadir', 'data/',
    ],
    instances: 1,
    autorestart: true,
    watch: false,
    exec_mode: 'fork',
    max_memory_restart: '1G'
  },
  {
    name: 'Geth (Account unlocker)',
    script: 'geth',
    args: [
      '--datadir', 'data/',
      '--exec', 'loadScript("./unlock.js")',
      'attach'
    ],
    instances: 1,
    watch: false,
    kill_timeout: 500,
    autorestart: true,
    exec_mode: 'fork',
    max_memory_restart: '50M'
  },
	{
    name: 'Http',
    script: 'node',
    args: [ './server.js' ],
    instances: 1,
    autorestart: true,
    watch: false,
    exec_mode: 'fork',
    max_memory_restart: '100M'
  }]
}
