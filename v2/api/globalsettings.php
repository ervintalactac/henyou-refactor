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
            "showTestAds" => 'false',
            // esaflip
            'bannerAdUnitIdAndroid' => 					'ca-app-pub-5434308461438291/8909668645',
            'bannerAdUnitIdIOS' => 						'ca-app-pub-5434308461438291/6189234012',
            'nativeAdUnitIdAndroid' => 					'ca-app-pub-5434308461438291/8350738789',
            'nativeAdUnitIdIOS' => 						'ca-app-pub-5434308461438291/2867321707',
            'interstitialAdUnitIdAndroid' => 			'ca-app-pub-5434308461438291/2092096974',
            'interstitialAdUnitIdIOS' => 				'ca-app-pub-5434308461438291/9451620354',
            'rewardedAdUnitIdAndroid' => 				'ca-app-pub-5434308461438291/4213097892',
            'rewardedAdUnitIdIOS' => 					'ca-app-pub-5434308461438291/9307881590',
            'rewardedInterstitialAdUnitIdAndroid' => 	'ca-app-pub-5434308461438291/2491740545',
            'rewardedInterstitialAdUnitIdIOS' => 		'ca-app-pub-5434308461438291/7803228231',
            'appOpenAdUnitIdAndroid' => 				'ca-app-pub-5434308461438291/1587644021',
            'appOpenAdUnitIdIOS' => 					'ca-app-pub-5434308461438291/4783038608',
            // henyogamemaker
            // 'bannerAdUnitIdAndroid' => 				'ca-app-pub-9660306973957595/9151709168',
            // 'bannerAdUnitIdIOS' => 					'ca-app-pub-9660306973957595/6659361470',
            // 'nativeAdUnitIdAndroid' => 				'ca-app-pub-9660306973957595/4392290789',
            // 'nativeAdUnitIdIOS' => 					'ca-app-pub-9660306973957595/8602998536',
            // 'interstitialAdUnitIdAndroid' => 		'ca-app-pub-9660306973957595/6962575815',
            // 'interstitialAdUnitIdIOS' => 			'ca-app-pub-9660306973957595/1323274318',
            // 'rewardedAdUnitIdAndroid' => 			'ca-app-pub-9660306973957595/7649009516',
            // 'rewardedAdUnitIdIOS' => 				'ca-app-pub-9660306973957595/2504494041',
            // 'rewardedInterstitialAdUnitIdAndroid' => 'ca-app-pub-9660306973957595/8962091187',
            // 'rewardedInterstitialAdUnitIdIOS' => 	'ca-app-pub-9660306973957595/6443739056',
            // 'appOpenAdUnitIdAndroid' => 				'ca-app-pub-9660306973957595/9453045779',
            // 'appOpenAdUnitIdIOS' => 					'ca-app-pub-9660306973957595/4334496756',
            
            "displayRewardedAdAfterThisManyTries" => 7,
            "displayInstertitialAdAfterThisManyTries" => 18,
            "rewardedAdAmount" => 150,
            "dailyTokenReward" => 100,
            "voiceEntryFee" => 50,
            "hintFee" => 20,
            "maxGuessTriesForAward" => 3,
            "msPauseForVoiceEntry" => 1000,
            "promptForGamePageVoiceEntry" => 'false',
            "promptForHenyoPartyVoiceEntry" => 'true',
            "gameDuration" => 2,
            "rewardedAdNextAvailableInMs" => 180000,
            "lowTokenCountThreshold" => 500,
            "maxTriesForHintToAppear" => 3,
            "GoogleApiServerAsia" => 'asia-southeast1',
            "GoogleApiServerUS" => 'us-central1',
            "GoogleProjectID" => 'coral-sum-422915-m1',
            "promptCompareTwoWords" => "You're an english and tagalog dictionary and wikipedia expert and I’ll give you two words separated by colon(:) like 'subject1:subject2' 
and you'll tell me if subject2 directly describes, belongs, part of or equates to subject1 by answering yes. 
If subject2 is not typically subject1 but somewhat like it or relates to it then answer close.
If none of the above fits the criteria then answer no.
Response should only be one of the three, 'yes', 'close' or 'no'.
Words to be compared will be in english and/or tagalog. NO EXPLANATION NEEDED!" ,
            "promptGimme5Round1" =>  "You're an english/tagalog dictionary and wikipedia expert and I’ll give you a list of 5 items plus a word (subject2)
separated by colon(:) like '[item1,item2,item3,item4,item5]:subject2'. You'll tell me which item on the list closely matches,
similar variation, synonymous, partly mispelled to subject2 by returning the index number of the matching item in the list.
If none of the items in the list fits the criteria then reply 0.
Response can only be one of the six possible numbers, 1, 2, 3, 4, 5 or 0.
Words to be compared will be in english and/or tagalog. NO EXPLANATION NEEDED FROM RESPONSE!",
            "promptValidateUsername" => "You're a username validator and I'll give you a username that you need to validate
for profanity or anything inappropriate. Only check for literal profanity words. Reply 'true' if you detect profanity otherwise
'false'. Reply will only be one of these two possible answers.",
            "geminiApiKey" => "AIzaSyAoYR-pL5Ve2_j2aWHuarZ6--eurjoeRyw",
            "enableAutoComplete" => 'false',
        );
    
    echo $crypto->encryptArray2($tempArr);
    http_response_code(200);
?>