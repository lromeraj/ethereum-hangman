// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// - La oración a descubrir puede estar en español o en inglés (no se aplica ningún mecanismo para comprobar si realemnte es un texto con sentido)
// 
// - Descubrimos letras en función de lo que se contribuya, si la letra solicitada no existe se rechaza la transacción, 
//   en caso de que se haya pagado por más letras de las que hay (o faltan) no se realizará ninguna devolución.
//
// - Si los participantes no son capaces de adivinar la oración por completo (se acaban las vidas)
//   el juego hará un reparto proporcional en función del número de letras que se hayan adivinado, 
//   una parte será transferida al propietario y el resto se repartirá entre los participantes.
//  
// - Si los participantes son capaces de adivinar la oración por completo, el lote será repartido entre todos los participantes.
//
// - El propietario deberá pagar (al crear el contrato) en función del número de letras que contenga su texto.
//
// - El caracter espacio también se cuenta, en general cualquier caracter ASCII puede ser utilizado.

contract Hanged {

    uint8 public lives = 6;
    uint256 public constant letterPrice = 0.1 ether;
    
    bytes private secret;
    bytes private discovered;

    uint256 private lettersFound = 0;

    address public owner;
    // address[] public participants;

    struct Participant {
        uint refund;
        uint index;
    }
    
    address[] public participants;
    mapping(address => Participant) private participantsMap;

    constructor( 
        string memory __secret 
    ) 
        payable 
    {

        secret = bytes( __secret );

        require ( msg.value == secret.length * letterPrice, 
            "You have to pay 0.1 ether per letter" );
        
        for ( uint256 i=0; i < secret.length; i++ ) {
            discovered.push( "_" );
        }

        owner = msg.sender;
        
    }

    function isParticipant( address participant )
        private view
        returns( bool isIndeed )
    {
        if ( participants.length == 0 ) { 
            return false ;
        }
        return participants[ participantsMap[ participant ].index ] == participant;
    }

    
    function showText() 
        public view 
        returns( string memory ) 
    {
        return string( discovered );
    }

    function tryLetter( 
        string memory letter, 
        uint256 amount 
    ) 
        payable public 
    {
      
        require( 
            msg.value == amount * letterPrice, 
            "You have to pay 0.1 ether per letter" );
        
        if ( !isParticipant( msg.sender ) ) {
            participants.push( msg.sender );
            participantsMap[ msg.sender ].index = participants.length - 1;
        }
        
        uint256 __amount = amount;

        for (uint256 i=0; i < secret.length; i++ ) {

            bytes1 byteLetter = bytes( letter )[ 0 ];

            if ( secret[i] == byteLetter ) {
                
                if ( __amount > 0 ) {
                    __amount--;
                    lettersFound++;
                    discovered[ i ] = byteLetter;
                } else {
                    break;
                }

            }

        }
        
        // no letter was found
        if ( amount == __amount ) {
            lives--;
        }
        
        // remember participant refunds
        participantsMap[ msg.sender ].refund += __amount * letterPrice;

        if ( lives == 0 || secret.length == lettersFound ) {
            endGame();
        }

    }

    function endGame() private {

        uint256 jackpot = address( this ).balance;

        for ( uint256 i=0; i < participants.length; i++ ) { // return refund to participants
            address participant = participants[ i ];
            payable( participant ).transfer( participantsMap[ participant ].refund );
        }

        jackpot = address( this ).balance;

        if ( lives > 0 ) { // participants have won
            
            // money is shared between participants
            for ( uint256 i=0; i < participants.length; i++ ) {
                payable( participants[i] ).transfer( jackpot / participants.length );
            }

        } else { // owner has won

            // as the owner can use any ASCII combination (in some situations) it will be very
            // difficult for participants to find out the secret
            // so even thoug the owner has won we don't give the whole jackpot to the owner
            
            uint256 ownerInversion = secret.length * letterPrice;
            uint256 sharedJackpot = jackpot - ownerInversion;

            uint256 forParticipants = sharedJackpot * lettersFound / secret.length;
            uint256 forOwner = ownerInversion + ( sharedJackpot - forParticipants );

            for ( uint256 i=0; i < participants.length; i++ ) {
                payable( participants[i] ).transfer( forParticipants / participants.length );
            }
            
            payable( owner ).transfer( forOwner );
        }

    }

}