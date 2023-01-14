function unlockAllAccounts() {

  const accountsToUnlock = [ ... eth.accounts ]

  accountsToUnlock.shift(); // remove first account from temp list

  console.log( "\n================ UNLOCKING ================\n" )

  for ( let account of accountsToUnlock ) {
    let strOut = `Unlocking account ${ account } ... `
    const result = personal.unlockAccount( account, "1234", 0 ); 
    strOut += result ? "OK" : "ERR";
    console.log( strOut )
  }

  console.log( "\n================ ========= ================\n" )

}

function main() {
  unlockAllAccounts();
  while ( 1 ) {
    console.log( "Unlocker heartbeat ..." )
    admin.sleep( 60*60 );
  }
}

main();
