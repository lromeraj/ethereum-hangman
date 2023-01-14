const accountsToUnlock = [ ... eth.accounts ]

accountsToUnlock.shift(); // remove first account

console.log( "\n================ UNLOCK SCRIPT ================\n" )

for ( let account of accountsToUnlock ) {
  let strOut = `Unlocking account ${ account } ... `
  const result = personal.unlockAccount( account, "1234", 0 ); 
  strOut += result ? "OK" : "ERR";
  console.log( strOut )
}

console.log( "\n================ ============== ================\n" )