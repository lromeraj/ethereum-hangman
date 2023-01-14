// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract Hangman {

    // Structs
    struct Participant {
        uint refund;
        uint index;
    }

    // Events
    event CharsAdded(
        string discoveredChars,
        string incorrrecTchars,
        uint livesLeft
    );

    event GameEnded( );
    
    // constants
    uint256 public constant charPrice = 0.1 ether; // price per character

    uint8   private     lives = 6; // maximum lives
    uint    private     maxParticipants; // maximum number of participants

    bytes   private     secret; // secret determined by the owner
    bytes   private     discoveredChars; // current text discovered
    bytes   private     incorrectChars; // characters used that do not exist in the secret 

    uint    public      charsFound = 0; // total number of chars found

    address public      owner; // contract owner

    address[] public participants; // keep track of participants

    // keep track of extra information about participants
    mapping(address => Participant) private participantsMap;

    function validateAsciiChar(
        bytes1 c 
    )
        private pure
        returns( bool )
    {
        return (c >= 0x30 && c <= 0x39) 
            || (c >= 0x41 && c <= 0x5A)
            || (c >= 0x61 && c <= 0x7A)
            || (c == 0x20);
    }

    constructor( 
        string memory __secret 
    ) 
        payable
    {

        secret = bytes( __secret );

        require ( 
            secret.length <= 36,
            "Secret too long, maximum is 36 characters" );

        require ( msg.value == secret.length * charPrice, 
            "You have to pay 0.1 ether per letter" );
        
        for ( uint256 i=0; i < secret.length; i++ ) {
            require( 
                validateAsciiChar( secret[ i ] ),
                "Secret contains invalid characters" );
            discoveredChars.push( "_" );
        }

        owner = msg.sender;
        maxParticipants = secret.length / 6;
        maxParticipants = maxParticipants > 0 ? maxParticipants : 1;
    }

    function isParticipant( 
        address participant 
    )
        private view
        returns( bool )
    {
        if ( participants.length == 0 ) { 
            return false;
        }
        return participants[ participantsMap[ participant ].index ] == participant;
    }

    function getDiscoveredChars()
        public view 
        returns( string memory ) 
    {
        return string( discoveredChars );
    }
    
    function getMaximumParticipants() 
        public view 
        returns( uint ) 
    {
        return maxParticipants;
    }

    function getLivesLeft() 
        public view 
        returns( uint ) 
    {
        return lives;
    }

    function getIncorrectChars() 
        public view 
        returns( string memory ) 
    {
        return string( incorrectChars );
    }

    function tryChar( 
        string memory char, 
        uint amount 
    ) 
        payable public
    {
        
        require ( 
            !gameEnded(), 
            "Game is over!" );

        require( 
            msg.sender != owner,
            "Owner can not participate" );

        require( 
            amount > 0,
            "Amount should be greater than 0" );

        require( 
            msg.value == amount * charPrice, 
            "You have to pay 0.1 ether per letter" );

        if ( !isParticipant( msg.sender ) ) {
            
            require(
                participants.length < maxParticipants,
                "Game is full" );

            participants.push( msg.sender );
            participantsMap[ msg.sender ].index = participants.length - 1;
        }
        
        uint256 __amount = amount;
        bytes1 byteChar = bytes( char )[ 0 ];

        for (uint256 i=0; i < secret.length; i++ ) {

            if ( secret[i] == byteChar && discoveredChars[i] != byteChar ) {        
                if ( __amount > 0 ) {
                    __amount--;
                    charsFound++;
                    discoveredChars[ i ] = byteChar;
                } else {
                    break;
                }
            }

        }
        
        // no letter was found
        if ( amount == __amount ) {
            lives--;
            incorrectChars.push( byteChar );
        }
        
        // remember participant refunds
        participantsMap[ msg.sender ].refund += __amount * charPrice;

        emit CharsAdded( getDiscoveredChars(), getIncorrectChars(), getLivesLeft() );

        if ( gameEnded() ) {
            endGame();
        }

    }

    function gameEnded()
        public view
        returns ( bool )
    {
        return lives == 0 || secret.length == charsFound;
    }

    function endGame() 
        private 
    {

        
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
            
            uint256 ownerInversion = secret.length * charPrice;
            uint256 sharedJackpot = jackpot - ownerInversion;

            uint256 forParticipants = sharedJackpot * charsFound / secret.length;
            uint256 forOwner = ownerInversion + ( sharedJackpot - forParticipants );

            for ( uint256 i=0; i < participants.length; i++ ) {
                payable( participants[i] ).transfer( forParticipants / participants.length );
            }
            
            payable( owner ).transfer( forOwner );
        }

        emit GameEnded();

    }

}