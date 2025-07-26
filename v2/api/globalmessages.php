<?php
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    
    include_once '../config/database.php';
    include_once '../class/crypto.php';

    $auth = $_SERVER['HTTP_AUTH2'];
    $crypto = new Crypto();
    if(!$crypto->verifyAuth2($auth)){
        return;
    }
    
    $tempArr = array(
            "howToPlayMessage" => "Game Instructions:\n\nHenyo U?! (Are you a genius?!)\n\n\$instructions\n\nErvin Talactac\n(Proudly Filipino Made; Magaling Ang Atin!)\n\nSend your inquiries or feedback to ervin@henyogames.com",
            "howToPlayMessagePH" => "Ang larong ito ay hango sa isang sikat na Filipino TV game show na tinatawag na Gimme 5 (dating Pinoy Henyo) ng EAT Bulaga (TM) *no affiliation* na ngayon ay hindi lang isa kundi dalawa o maraming pwedeng maglaro.

Solo Player mode
Pipili and app ng kahit ano mang salita na nabibilang sa isa sa 5 pangunahing kategorya, Tao, Lugar, Bagay, Hayop o Pagkain. I-type mo ang mga salitang hula (o ngayon ay opsyonal na sabihin ang iyong mga entry) at tutugon ang app ng \"Oo, Pwede o Hindi\" batay sa salitang iyong inilagay. Tukuyin mo ang salita sa pamamagitan ng iyong mga sinubukang hula kaya tandaan ang mga salitang nakakakuha ng Oo o Pwede. Meron kang 2 minuto para hulaan ang salita at sa huling 10 segundo, bibigyan ka ng app ng shuffled na bersyon ng salita para mas madaling mahulaan ang salita. Mananalo ka ng mga token base sa kung gaano kabilis at kahirap ang salitang huhulaan.

Two Player mode
Dalawang tao na may kanilang mga sariling smartphone at naka-install ang app na ito ay kinakailangan upang magamit ang tampok na ito. Pinipili ng isa na maging manghuhula at ang isa ay tagabigay ng clue tulad ng game show. Ita-type o ngayon ay masasabi na ni Guesser (opsyonal) ang iyong mga entry sa hula, pagkatapos ay maaaring tumugon ang nagbibigay ng clue ng \"Oo, Pwede o Hindi\" batay sa iyong hulang salita. Mayroon ka ring 2 minuto upang hulaan ang salita. Makakakuha ka rin ng mga token base sa kung gaano kabilis at kahirap ang salitang huhulaan.

Party mode
Pwede nang gamitin and app na ito para makipaglaro sa mga pamilya at kaibigan kung saan hawak ng manghuhula ang kanilang smartphone (nakaharap ang screen sa audience) at hulaan ang ipinapakitang salita habang ang iba ay nagbibigay din ng mga sagot na \"Oo, Pwede o Hindi.\" Subukan ang feature na Henyo Assist kung saan ang app ay makikilaro at magbibigay din ng mga pahiwatig na \"Oo, Pwede o Hindi\" sa manghuhula kasama ang ibang taong nagbibigay ng clue. Kaliangan din makuha sa 2 minuto and salitang hinuhulaan.

Panghuli, huwag mag-alala kung maubusan ka ng mga token. Maaari kang magpaLOAD kahit anumang oras sa pamamagitan ng pag-click sa +Tokens (matatagpuan sa kanang tuktok) ng pangunahing screen at sa pamamagitan ng panonood ng ilang segundo ng ad ng sponsor.

Iba pang mga tampok na kasama sa bersyon na ito
- Lingguhang paligsahan kung saan iginagawad ang mga token sa mananalo ng 1st, 2nd at 3rd place.
- Idinagdag ang pag-backup at pag-restore ng game user's play data.
- Pinahusay na pagganap at katatagan ng app.

Abangan ang mga ito sa susunod na bersiyon
- Henyo Wordle (Tagalog version)
- Henyo Boggle (Tagalog version)

Salamat sa paglalaro!",
            "howToPlayMessageEN" => "This game is inspired by a popular Filipino TV game show called Gimme 5 (formerly Pinoy Henyo) by EAT Bulaga (TM) *no affiliation* now in not just one but also two or many player mode.

Solo Player mode
A random word is selected that falls into one of the 5 main categories, Person, Place, Thing, Animal or Food. You type in the guess words (or now optionally speak your entries) and the app will respond \"Yes, Close or No\" based on the word you entered. You narrow down on the word by your attempted guesses so remember the words that gets a Yes or Close. You'll have 2 minutes to guess the word and on the last 10 seconds, the app will give you the shuffled version of the word to guess as a clue. Tokens awarded for how fast and difficult the guess word was.

Two Player mode
Two persons with their individual devices and this app installed is required to use this feature. One chooses to be the guesser and the other the clue giver just like the game show. Guesser will type or now be able to speak (optional) your guess entries, then the clue giver can respond \"Yes, Close or No\" based on your guess word. You also have 2 minutes to guess the word. Tokens awarded for how fast and difficult the guess word was.

Party mode
This feature let's you play with families and friends where the guesser hold their mobile phone (screen facing the audience) and guess the word displayed while the rest gives the guesser clues by also giving \"Yes, Close or No\" answers. Try the Henyo Assist feature where the game app will also provide \"Yes, Close or No\" clues to the guesser along with the clue givers. You'll have 2 minutes to guess the word.

Lastly, don't worry if you run out tokens. You can always replenish them by clicking on +Tokens (located on the top right) of the main screen and by watching a few seconds of sponsor's ad.

Other features included in this version
- Weekly tournament where tokens are awarded to the 1st, 2nd and 3rd place winners.
- Game backup and restore added.
- Improved app performance and stability.

Upcoming features
- Henyo Wordle (Tagalog version)
- Henyo Boggle (Tagalog version)

Thanks for playing!",
            "scoreBreakDownMessage" => "How points are rewarded:\nDifficulty\t\t\t\t\t\t\t\t\tE\t\t\t\tM\t\t\t\tH\n91-120secs\t\t\t\t12\t\t16\t\t\t20\n61-90secs\t\t\t\t\t\t\t9\t\t\t12\t\t\t15\n31-60secs\t\t\t\t\t\t\t6\t\t\t\t8\t\t\t\t10\n0.1-30secs\t\t\t\t\t\t3\t\t\t\t4\t\t\t\t\t5",
            "difficultyEasyLabelPH" => "Normal words to be guessed are selected",
            "difficultyEasyLabelEN" => "Normal words to be guessed are selected",
            "difficultyMediumLabelPH" => "Normal and Hard words are selected",
            "difficultyMediumLabelEN" => "Normal and Hard words are selected",
            "difficultyHardLabelPH" => "All words are selected",
            "difficultyHardLabelEN" => "All words are selected",
            "backupRestoreMessagePH" => "(Optional) Enter your email address to back up your records. Your email will only be used to restore your game records in case you lost or obtained a new phone. This data will be stored encrypted on our end. It will never be shared to third party companies.\n\nAnother alternative to restore your account is to email me a screenshot of your home screen. You'll then get a return email containing a code you can use to restore your game account records.",
            "backupRestoreMessageEN" => "(Optional) Enter your email address to back up your records. Your email will only be used to restore your game records in case you lost or obtained a new phone. This data will be stored encrypted on our end. It will never be shared to third party companies.\n\nAnother alternative to restore your account is to email me a screenshot of your home screen. You'll then get a return email containing a code you can use to restore your game account records.",
            "partyModeMessagePH" => "Instructions:\nHold the phone above your head if you're the guesser after starting the game. Have the other people/person in front of you give you the clue by saying Yes, Close or No based out of the word to guess.\n\nEnable the microphone to detect your answers and automatically give you audible clues.",
            "partyModeMessageEN" => "Instructions:\nHold the phone above your head if you're the guesser after starting the game. Have the other people/person in front of you give you the clue by saying Yes, Close or No based out of the word to guess.\n\nEnable the microphone to detect your answers and automatically give you audible clues.",
            "weeklyWinnerFirstPlacePH" => "Congrats on winning 1st place with last week's tournament! You've earned \$reward token reward!!",
            "weeklyWinnerFirstPlaceEN" => "Congrats on winning 1st place with last week's tournament! You've earned \$reward token reward!!",
            "weeklyWinnerSecondPlacePH" => "You won 2nd place with last week's tournament! You've earned \$reward token reward!!",
            "weeklyWinnerSecondPlaceEN" => "You won 2nd place with last week's tournament! You've earned \$reward token reward!!",
            "weeklyWinnerThirdPlacePH" => "You've placed 3rd with last week's tournament! You've earned \$reward token reward!!",
            "weeklyWinnerThirdPlaceEN" => "You've placed 3rd with last week's tournament! You've earned \$reward token reward!!",
            "dailyTokenRewardMessagePH" => "You just earned \$dailyTokenReward tokens for playing regularly!",
            "dailyTokenRewardMessageEN" => "You just earned \$dailyTokenReward tokens for playing regularly!",
            "microphoneDeniedTitlePH" => "Unable to use Voice Entry feature!",
            "microphoneDeniedTitleEN" => "Unable to use Voice Entry feature!",
            "microphonePermanentlyDeniedMessagePH" => "The game needs access to the microphone to enable answers by voice. Please enable this from the Phone Settings.\nApple: Settings > Henyo U?!\nAndroid: Settings > Apps & Notifications > Henyo U?!",
            "microphonePermanentlyDeniedMessageEN" => "The game needs access to the microphone to enable answers by voice. Please enable this from the Phone Settings.\nApple: Settings > Henyo U?!\nAndroid: Settings > Apps & Notifications > Henyo U?!",
            "microphoneDeniedMessagePH" => "The game needs access to the microphone to enable answers by voice",
            "microphoneDeniedMessageEN" => "The game needs access to the microphone to enable answers by voice",
            "useHintMessagePH" => "This will shuffle guess word and will cost you \$hintFee tokens. Reward will also be cut in half on correct guess.",
            "useHintMessageEN" => "This will shuffle guess word and will cost you \$hintFee tokens. Reward will also be cut in half on correct guess.",
			"infoGamePageTitlePH" => "Paano 'to laruin?",
			"infoGamePageTitleEN" => "How To Play?",
			"infoGamePageMessagePH" => "Pipili and app ng kahit ano mang salita na nabibilang sa isa sa 5 pangunahing kategorya, Tao, Lugar, Bagay, Hayop o Pagkain. I-type mo ang mga salitang hula (o ngayon ay opsyonal na sabihin ang iyong mga entry) at tutugon ang app ng \"Oo, Pwede o Hindi\" batay sa salitang iyong inilagay. Tukuyin mo ang salita sa pamamagitan ng iyong mga sinubukang hula kaya tandaan ang mga salitang nakakakuha ng Oo o Pwede. Meron kang 2 minuto para hulaan ang salita at sa huling 10 segundo, bibigyan ka ng app ng shuffled na bersyon ng salita para mas madaling mahulaan ang salita. Mananalo ka ng mga token base sa kung gaano kabilis at kahirap ang salitang huhulaan.",
			"infoGamePageMessageEN" => "A random word is selected that falls into one of the 5 main categories, Person, Place, Thing, Animal or Food. You type in the guess words (or now optionally speak your entries) and the app will respond \"Yes, Close or No\" based on the word you entered. You narrow down on the word by your attempted guesses so remember the words that gets a Yes or Close. You'll have 2 minutes to guess the word and on the last 10 seconds, the app will give you the shuffled version of the word to guess as a clue. Tokens awarded for how fast and difficult the guess word was.",
			"infoMultiPlayerPageTitlePH" => "Paano 'to laruin?",
			"infoMultiPlayerPageTitleEN" => "How To Play?",
			"infoMultiPlayerPageMessagePH" => "Dalawang tao na may kanilang mga sariling smartphone at naka-install ang app na ito ay kinakailangan upang magamit ang tampok na ito. Pinipili ng isa na maging manghuhula at ang isa ay tagabigay ng clue tulad ng game show. Ita-type o ngayon ay masasabi na ni Guesser (opsyonal) ang iyong mga entry sa hula, pagkatapos ay maaaring tumugon ang nagbibigay ng clue ng \"Oo, Pwede o Hindi\" batay sa iyong hulang salita. Mayroon ka ring 2 minuto upang hulaan ang salita. Makakakuha ka rin ng mga token base sa kung gaano kabilis at kahirap ang salitang huhulaan.",
			"infoMultiPlayerPageMessageEN" => "Two persons with their individual devices and this app installed is required to use this feature. One chooses to be the guesser and the other the clue giver just like the game show. Guesser will type or now be able to speak (optional) your guess entries, then the clue giver can respond \"Yes, Close or No\" based on your guess word. You also have 2 minutes to guess the word. Tokens awarded for how fast and difficult the guess word was.",
			"infoMultiPlayerGuesserPageTitlePH" => "Paano 'to laruin?",
			"infoMultiPlayerGuesserPageTitleEN" => "How To Play?",
			"infoMultiPlayerGuesserPageMessagePH" => "Huhulaan mo ang iba't ibang salita sa screen na ito. I-type o sabihin ang iyong mga sagot at bibigyan ka ng iyon kalaro ng mga sagot na \"Oo, Pwede o Hindi\" base sa gaano kalapit yung salita na binigay mo kumpara sa salitang hinuhuluan. Lalabas ang hint button pagkatapos ng 10 pagsubok. Ang mapapalanunang token ay naaayon batay sa bilis at kahirapan ng mga salitang hinuhulaan. I-tap ang \"Start Button\" kapag handa ka na at ang parehong button ay magiging \"Submit\" button upang ipadala ang iyong hula sa iyong kalaro.",
			"infoMultiPlayerGuesserPageMessageEN" => "You will be guessing the random word on this screen. Type or speak your answers and the other player will be giving you clues of \"Yes, Close or No\". Hint will be available after 10 tries. Tokens will be rewarded accordingly based on speed and difficulty of the guess word. Hit the \"Start Button\" when you're ready and the same button will become \"Submit\" button to send your guess to the other player.",
			"infoMultiPlayerClueGiverTitlePH" => "Paano 'to laruin?",
			"infoMultiPlayerClueGiverTitleEN" => "How To Play?",
			"infoMultiPlayerClueGiverMessagePH" => "Ikaw ang tagabigay ng clue sa screen na ito. Kapag sinimulan na ng manghuhula ang laro, lalabas ang salitang huhulaan sa itaas at magsisimula ang 2 minutong timer. Hintayin ang tugon ng manghuhula pagkatapos ay maaari kang sumagot ng \"Oo, Pwede o Hindi\" batay sa salitang isinumite ng manghuhula sa pamamagitan ng pagpindot sa kaukulang mga pindutan sa ibaba ng screen. Ang mapapalanunang token ay naaayon batay sa bilis at kahirapan ng mga salitang hinuhulaan.",
			"infoMultiPlayerClueGiverMessgaeEN" => "You are the clue giver on this screen. Once the guesser starts the game, the guess word will appear on the top and the 2 minute timer will start. Wait for the guesser's response then you can answer \"Yes, Close or No\" based on the word the guesser submitted by tappping on the corresponding buttons below the screen. Tokens will be rewarded accordingly based on speed and difficulty of the guess word.",
			"infoPartyModeTitlePH" => "Paano 'to laruin?",
			"infoPartyModeTitleEN" => "How To Play?",
			"infoPartyModeMessagePH" => "Pwede nang gamitin and app na ito para makipaglaro sa mga kapamilya at kaibigan kung saan hawak ng manghuhula ang kanilang smartphone (nakaharap ang screen sa audience) at hulaan ang ipinapakitang salita habang ang iba ay nagbibigay din ng mga sagot na \"Oo, Pwede o Hindi.\" Subukan ang feature na Henyo Assist kung saan ang app ay makikilaro at magbibigay din ng mga pahiwatig na \"Oo, Pwede o Hindi\" sa manghuhula kasama ang ibang taong nagbibigay ng clue. Kaliangan din makuha sa 2 minuto and salitang hinuhulaan.",
			"infoPartyModeMessageEN" => "This feature let's you play with families and friends where the guesser hold their mobile phone (screen facing the audience) and guess the word displayed while the rest gives the guesser clues by also giving \"Yes, Close or No\" answers. Try the Henyo Assist feature where the game app will also provide \"Yes, Close or No\" clues to the guesser along with the clue givers. You'll have 2 minutes to guess the word.",
			"infoLeaderBoardTitlePH" => "About this page",
			"infoLeaderBoardTitleEN" => "About this page",
			"infoLeaderBoardMessagePH" => "Ang pahinang ito ay para makita kung sino ang nagunguna sa mundo sa pagitan ng kabuuang puntos at bilang ng sunod-sunod na panalo. I-tap ang tab na \"Weekly Rankings\" upang makita ang katayuan ng lingguhang paligsahan.",
			"infoLeaderBoardMessageEN" => "This page displays Global total score and streak standings. Tap on the \"Weekly Winners\" tab to view the standings of weekly tournament.",
			"infoSettingsPageTitlePH" => "About this page",
			"infoSettingsPageTitleEN" => "About this page",
			"infoSettingsPageMessagePH" => "Change name\nBinibigyan ka ng opsyong lumipat sa ibang username. Ang mga custom na username ay isasaalang-alang sa hinaharap.\n\nWhat's New\nTingnan kung ano ang bago sa bersyong ito ng app.\n\nBackup/Restore\nNagbibigay-daan sa iyong i-backup ang data ng iyong laro sa pamamagitan ng pagpasok ng iyong email (hindi kailanman ibabahagi at maiimbak na naka-encrypt). Maaari kang makatanggap ng code kapag nakumpleto mo na ang isang backup upang ibalik ang iyong data ng laro sa ibang device.\n\nChange Color Theme\nMaaari mong i-customize ang kulay ng tema ng app ayon sa gusto mo.",
			"infoSettingsPageMessageEN" => "Change name\nGives you an option to switch to a different username. Custom usernames will be considered in the future.\n\nWhat's New\nSee what's new in this version of the app.\n\nBackup/Restore\nEnables you to backup your game data by entering your email (will never be shared and stored encrypted). You can receive a code once you have completed a backup to restore your game data on a different device.\n\nChange Color Theme\nYou can customize the color thme of the app to your liking.",
			"infoBackupRestoreTitlePH" => "About this page",
			"infoBackupRestoreTitleEN" => "About this page",
			"infoBackupRestoreMessagePH" => "(Opsyonal) Ilagay ang iyong email address upang i-back up ang iyong impormasyon. Gagamitin lang ang iyong email para i-restore ang iyong mga record ng laro kung sakaling mawala o makakuha ka ng bagong telepono. Ang data na ito ay maiimbak na naka-encrypt sa aming database. Hinding-hindi ito ibabahagi sa mga kumpanya.",
			"infoBackupRestoreMessageEN" => "(Optional) Enter your email address to back up your records. Your email will only be used to restore your game records in case you lost or obtained a new phone. This data will be stored encrypted on our end. It will never be shared to third party companies.",
			"infoGimme5Round1TitlePH" => "Panno 'to laruin?",
            "infoGimme5Round1TitleEN" => "How To Play?",
            "infoGimme5Round1MessagePH" => "Instructions: After selecting amount of tokens as wager, you just need to get 3 out of 5 correct answers on every round to double your wager. If you get perfect score by getting all 5 correct answers on every round then you win four times your wager. You'll lose your wager if you don't get to answer at least 3 correct ones on this and succeeding rounds.",
            "infoGimme5Round1MessageEN" => "Instructions: After selecting amount of tokens as wager, you just need to get 3 out of 5 correct answers on every round to double your wager. If you get perfect score by getting all 5 correct answers on every round then you win four times your wager. You'll lose your wager if you don't get to answer at least 3 correct ones on this and succeeding rounds.",
            "infoGimme5Round2TitlePH" => "Panno 'to laruin?",
            "infoGimme5Round2TitleEN" => "How To Play?",
            "infoGimme5Round2MessagePH" => "Instructions: On this round you can pick a category from the remaining categories from the first round. You'll guess the word from the category you chose and the app will respond 'yes', 'close' or 'no'. You'll have an option to pass if you can't guess the current word. You need to get at least 3 correct words to advance to the final round. You'll lose your wager if you don't get to answer at least 3 correct ones.",
            "infoGimme5Round2MessageEN" => "Instructions: On this round you can pick a category from the remaining categories from the first round. You'll guess the word from the category you chose and the app will respond 'yes', 'close' or 'no'. You'll have an option to pass if you can't guess the current word. You need to get at least 3 correct words to advance to the final round. You'll lose your wager if you don't get to answer at least 3 correct ones.",
            "infoGimme5Round3TitlePH" => "Panno 'to laruin?",
            "infoGimme5Round3TitleEN" => "How To Play?",
            "infoGimme5Round3MessagePH" => "Instructions: On this round, words to be guessed will be randomly picked from all 5 categories. You'll try guessing the word and the app will respond 'yes', 'close' or 'no' based on your guess. You'll have an option to pass if you can't guess the current word. You need to get at least 3 correct answers to win the wager. You'll lose your wager if you don't get to answer at least 3 correct ones.",
            "infoGimme5Round3MessageEN" => "Instructions: On this round, words to be guessed will be randomly picked from all 5 categories. You'll try guessing the word and the app will respond 'yes', 'close' or 'no' based on your guess. You'll have an option to pass if you can't guess the current word. You need to get at least 3 correct answers to win the wager. You'll lose your wager if you don't get to answer at least 3 correct ones.",
            "infoGimme5TitleName" => "Gimme 5",
            "infoMainMenuGimme5Title" => "Henyo Gimme5",
            "infoMainMenuSoloTitle" => "Henyo Solo",
            "infoMainMenuMultiPlayer5Title" => "Henyo 2Player",
            "infoMainMenuPartyTitle" => "Henyo Party",
        );
    
    echo $crypto->encryptArray2($tempArr);
    http_response_code(200);
?>