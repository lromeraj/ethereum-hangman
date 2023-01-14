const BN = web3.BigNumber;
const { toWei, fromWei } = web3;

const DEFAULT_ACCOUNT_PASSWORD = "1234";
const DEFAULT_ACCOUNT_BALANCE = toWei( new BN( 100 ), 'ether' ); // ether

function createAccounts() {
  if ( eth.accounts.length === 1 ) {
    for ( let i=0; i < 10; i++ ) {
      personal.newAccount( DEFAULT_ACCOUNT_PASSWORD );
    }
  }
} 

function getCurrentAccounts() {
  const currentAccounts = [ ... eth.accounts ]
  currentAccounts.shift();
  return currentAccounts;
}

function unlockAccounts() {

  const accounts = getCurrentAccounts();

  console.log( "\n================ UNLOCKING ================\n" )

  for ( let account of accounts ) {
    let strOut = `Unlocking account ${ account } ... `
    const result = personal.unlockAccount( account, DEFAULT_ACCOUNT_PASSWORD, 0 ); 
    strOut += result ? "OK" : "ERR";
    console.log( strOut )
  }

  console.log( "\n================ ========= ================\n" )

}


function seedAccounts() {

  const accounts = getCurrentAccounts();
  
  for ( let account of accounts ) {
    
    const balanceDiff = DEFAULT_ACCOUNT_BALANCE.minus( eth.getBalance( account ) );
    
    if ( balanceDiff.gt( 0 ) ) {
      
      console.log(`Sending ${ fromWei(balanceDiff) } ether to ${account} ...`);

      eth.sendTransaction({
        from: eth.accounts[ 0 ],
        to: account,
        value: balanceDiff
      })

    }
  }

}

function main() {
  
  createAccounts();
  unlockAccounts();
  seedAccounts();
  
  while ( 1 ) { // this will allow us to keep accounts unlocked
      console.log( "Unlocker heartbeat ..." )
    admin.sleep( 60*60 );
  }

}

main();
