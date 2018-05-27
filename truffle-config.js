'use strict';

module.exports = {
  networks: {
    local: {
      host: 'localhost',
      port: 9545,
      gas: 5000000,
      network_id: '*'
    },
    ropsten:  {
    	network_id: 3,
    	from: "0x897dafd1e0ffae725794343593e8cf6d8de1195b",
     	host: "localhost",
     	port:  8545,
     	gas: 3000000
      // gasPrice: 10000000000
		},
		rinkeby: {
      host: "127.0.0.1",
      port: 8545,
      network_id: 4
    },
  }
};