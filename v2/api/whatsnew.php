<?php
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    
    include_once '../class/crypto.php';

    $auth = $_SERVER['HTTP_AUTH2'];
    $crypto = new Crypto();
    if(!$crypto->verifyAuth2($auth)){
        return;
    }

    $tempArr = array(
        "title" => "What's New?",
        "message" => "June 12 2024 update:
version 2024.6.6+20 released
- 2 player mode added
- voice entry now available (speak your answers)
- party mode (play with someone or the whole gang)
- gain extra tokens by watching promo ads
- weekly tournament with prices for 1st, 2nd & 3rd place winners
- major improvement and bug fixes
- backup & restore of game data now available

* Upcoming features
- Henyo Wordle (Tagalog version)
- Henyo Boggle (Tagalog version)

        
Sept 28 2023 update:
- updated words list
        
Sept 25 2023 update:
version 2023.9.0 released
- Daily token rewards 100
- Check for zeroed tokens
- After ten tries enable hint
- Filter out zero score/streak from leader board
- Display date timestamp of words list on settings page
- Cache not used words list
- updated words list
        
Sept 20 2023 update:
- updated words list        

Sept 12 2023 update:
- improved words list        

Aug 2023 updates:
Major updates to the app with improved user interface. New features are as follows:
- Auto generated unique username to track your game progress
- Score and streak tracking
- Earn tokens when you correctly guess words
- Hint feature added where tokens will come in handy if you need help with a word
- Leader board added to see who’s competitive out there

Future planned features:
- Voice entry of words to lessen typing
- Add more guess words to the list
- Multiplayer feature

Thanks for playing!",
        "timestamp" => '1718226102' 
        // timestamp need to be a static value
        // replace with current timestamp when updating message
    );
    echo $crypto->encryptArray2($tempArr);
    http_response_code(200);
    
?>