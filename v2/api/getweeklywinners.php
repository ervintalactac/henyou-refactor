<?php
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Methods: POST");
    header("Access-Control-Max-Age: 3600");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

    include_once '../config/database.php';
    include_once '../class/weeklywinners.php';
    include_once '../class/crypto.php';
    include_once '../class/weeklyrecords.php';

    $auth = $_SERVER['HTTP_AUTH2'];
    $crypto = new Crypto();
    if(!$crypto->verifyAuth2($auth)){
        return;
    }
    
    $database = new Database();
    $db = $database->getConnection();
    $item = new WeeklyWinners($db);
    $weekNum = $item->getCurrentWeekNumber();
    // $item->weekNumber = $weekNum;
    if(!$item->isWeekNumberExists($weekNum - 1)){
        // echo $weekNum;
        $recs = new WeeklyRecords($db);
        $stmt = $recs->getTopThreeWeeklyRecords($weekNum - 1);
        $itemCount = $stmt->rowCount();
        //echo json_encode($itemCount);

        if($itemCount > 0){
            $recordArr = array();
            $recordArr["body"] = array();
            $recordArr["itemCount"] = $itemCount;
    
            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)){
                extract($row);
                $e = array(
                    "id" => $id,
                    "name" => $name,
                    "score" => $score,
                    "streak" => $streak,
                    "weekNumber" => $weekNumber,
                    "awardPaid" => $awardPaid,
                    "awardAmount" => $awardAmount
                );
                array_push($recordArr["body"], $e);
            }

            $item->firstPlace = sprintf('{"%s":{"status":"unclaimed","amount":"1000"}}', $recordArr["body"][0]["name"]);
            $item->secondPlace = sprintf('{"%s":{"status":"unclaimed","amount":"500"}}', $recordArr["body"][1]["name"]);
            $item->thirdPlace = sprintf('{"%s":{"status":"unclaimed","amount":"200"}}', $recordArr["body"][2]["name"]);
            // echo json_encode($array);
            
            // createWeeklyWinner calculates it's own previous week number 
            $item->createWeeklyWinner();
            
            $weeklyWinners = array(
                    "id" => $this->id,
                    "weekNumber" => $this->weekNumber,
                    "firstPlace" => $firstPlace,
                    "secondPlace" => $secondPlace,
                    "thirdPlace" => $thirdPlace
                );
            
            echo $crypto->encryptArray2($weeklyWinners);
            http_response_code(200);
            return;
        }
    }
    
    $returnAll = false;
    $item->weekNumber = isset($_GET['weekNumber']) ? $_GET['weekNumber'] : $returnAll = true;
    
    $stmt = $item->getWeeklyWinners();
    $itemCount = $stmt->rowCount();
    //echo json_encode($itemCount);

    if($itemCount > 0){
        // $recordArr = array();
        // $recordArr["body"] = array();
        // $recordArr["itemCount"] = $itemCount;

        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        extract($row);

        $recordArr = array(
            "id" => $id,
            "weekNumber" => $weekNumber,
            "firstPlace" => $firstPlace,
            "secondPlace" => $secondPlace,
            "thirdPlace" => $thirdPlace
        );
        
        echo $crypto->encryptArray2($recordArr);
        http_response_code(200);
    }else{
        http_response_code(404);
        echo json_encode(
            array("message" => "No record found.")
        );
    }
?>