<?php

/**
 * @brief yaokun's script base class
 *
 * 1. log
 * 2. wordlist
 * 3. file
 * 4. call
 * 5. db
 */

// init const
define('MEMORY_MAX_GB', 8);
define('SEP', "\n");
ini_set("memory_limit",MEMORY_MAX_GB * 1024 ."M");
set_time_limit(0);

date_default_timezone_set('Asia/Shanghai');

// init const check
if (!defined('MODULE_NAME')) {
    echo "missed MODULE_NAME, plese check!\n";
    exit(-1);
}

class MyLog {
    const TYPE_BINGO    = 0;
    const TYPE_CMD      = 1;
    const TYPE_ALL      = 2;

    const TYPE_BINGO_NOTICE     = 0;
    const TYPE_BINGO_WARNING    = 1;

    private $_type = null; //log type

    /**
     * @brief 
     *
     * @param $type
     *
     * @return 
     */
    public function __construct($type = self::TYPE_CMD, $script_name = MODULE_NAME) {
        $this->_type = $type;
        if (self::TYPE_BINGO === $this->_type || self::TYPE_ALL === $this->_type) {
            //init log path
            $arrLogInput = array(
                'UI'    => array(
                    'file'  => dirname(__FILE__).'/../../../log/app/'. MODULE_NAME .'/script_' .$script_name. '.log',
                    'level' => 0x7,
                ), 
            );
            Bingo_Log::init($arrLogInput, 'UI');
            echo "init bingo log path is [{$arrLogInput['UI']['file']}]\n";
        }
    }

    /**
     * @brief 
     *
     * @param $content
     *
     * @return 
     */
    private function _write_cmd($content) {
        var_dump($content);
    }

    /**
     * @brief 
     *
     * @param $content
     * @param $type
     *
     * @return 
     */
    private function _write_bingo($content, $type = self::TYPE_BINGO_NOTICE) {
        if (self::TYPE_BINGO_WARNING === $type) {
            Bingo_Log::warning($content);
        } else if (self::TYPE_BINGO_NOTICE === $type) {
            Bingo_Log::notice($content);
        } else {

        }
    }

    /**
     * @brief 
     *
     * @param $content
     *
     * @return 
     */
    public function notice($content) {
        if(is_array($content)) {
            $content = serialize($content);
        } else {
            $content = trim($content);
        }
        if ($this->_type === self::TYPE_BINGO) {
            $this->_write_bingo($content);
        } else if ($this->_type === self::TYPE_CMD) {
            $this->_write_cmd($content);
        } else if ($this->_type === self::TYPE_ALL) {
            $this->_write_bingo($content);
            $this->_write_cmd($content);
        }
    }

    /**
     * @brief
     *
     * @param $content
     *
     * @return 
     */
    public function warning($content) {
        if(is_array($content)) {
            $content = serialize($content);       
        } else {
            $content = trim($content);
        }
        if ($this->_type === self::TYPE_BINGO) {
            $this->_write_bingo($content, self::TYPE_BINGO_WARNING);
        } else if ($this->_type === self::TYPE_CMD) {
            $this->_write_cmd($content);
        } else if ($this->_type === self::TYPE_ALL) {
            $this->_write_bingo($content, self::TYPE_BINGO_WARNING);
            $this->_write_cmd($content);
        }
    }
}

class MyCall {
    const MAX_RETRY_TIME    = 40;
    const DEFAULT_RETRY_TIME= 0;
    const WIDE_STRATEGY     = 0;
    const TIGHT_STRATEGY    = 1;
    const SLEEP_RETRY       = 100; //ms

    private static $_log    = null;

    /**
     * @brief 
     *
     * @return 
     */
    private static function _init() {
        if (is_null(self::$_log)) {
            self::$_log = new MyLog();
            if (is_null(self::$_log)) {
                return false;
            }
        }
        return true;
    }

    /**
     * @brief 
     *
     * @param $module
     * @param $method
     * @param $arrInput
     * @param $ie
     * @param $retry
     * @param $strategy
     * @param $log
     *
     * @return 
     */
    public static function call($module, $method, $arrInput, $ie = 'utf-8', $retry = self::DEFAULT_RETRY_TIME, $strategy = self::WIDE_STRATEGY, $log = null) {
        if (self::MAX_RETRY_TIME < $retry || 0 > $retry) {
            $retry = self::MAX_RETRY_TIME;
        }
        if (is_null($log)) {
            if (!self::_init() ) {
                if (self::TIGHT_STRATEGY === $strategy) {
                    throw new Exception('init failed!');
                } else {
                    return false;
                }
            }
        } else {
            self::$_log = $log;
        }
        $i = 0;
        $arrOutput = array();
        while(true) {
            if ($retry < $i) {
                if (self::WIDE_STRATEGY === $strategy) {
                    return false;

                } else if (self::TIGHT_STRATEGY === $strategy) {
                    throw new Exception(sprintf("call service $module/$method failed, input[%s], output[%s]", serialize($arrInput), serialize($arrOutput)));

                } else {
                    return false;

                }
            }
            $arrOutput = Tieba_Service::call($module, $method, $arrInput, null, null, 'post', 'php', $ie);
            if (false === $arrOutput || 0 !== (int)$arrOutput['errno']) {
                $tmp_errmsg = sprintf("call service %s/%s failed, retry_time[%d], output[%s]!", $module, $method, $i, serialize($arrOutput));
                self::$_log->warning($tmp_errmsg);
                usleep(self::SLEEP_RETRY*$i);
                $i++;
                continue;
            } else {
                break;
            }
        }
        return $arrOutput;
    }
}

class MyDb {
    const MAX_RETRY = 5;
    private $_db = null;
    private $_ral_service_name = null;

    /**
     * @brief 
     *
     * @return 
     */
    private function _isReady() {
        if (false === $this->_db || is_null($this->_db)) {
            return false;
        } else {
            return true;
        }
    }

    /**
     * @brief 
     *
     * @return 
     */
    private function _getDb() {
        $this->_db = new Bd_DB();
        $this->_db->ralConnect($this->_ral_service_name);
        if (!$this->_db->isConnected) {
            throw new Exception(sprintf('fail to connect db, ral[%s]', $this->_ral_service_name));
        }
    }

    /**
     * @brief 
     *
     * @param $ral_service_name
     *
     * @return 
     */
    public function __construct($ral_service_name) {
        $this->_ral_service_name = $ral_service_name;
    }

    /**
     * @brief 
     *
     * @param $sql
     * @param $renew_ervery_time
     *
     * @return 
     */
    public function query($sql, $renew_ervery_time = false) {
        if (!$this->_isReady || $renew_ervery_time) {
            $this->_getDb();
        }
        $i = 0;
        while (true) {
            $res = $this->_db->query($sql);
            if (false === $res) {
                if (self::MAX_RETRY <= $i) {
                    return false;
                }
                $this->_getDb();
                $i++;
            } else {
                break;
            }
        }
        return $res;
    }
}

class MyWordList {
    const COMMON_PREFIX = "tb_wordlist_redis_";

    /**
     * @brief 
     *
     * @param $wordlist
     *
     * @return 
     */
    private static function _getKey($wordlist) {
        return self::COMMON_PREFIX.$wordlist;
    }

    /**
     * @brief 
     *
     * @param $wordlist
     *
     * @return 
     */
    public static function getAll($wordlist) {
        $objWordList = Wordserver_Wordlist::factory();
        $arrInput    = array (
            'table' => self::_getKey($wordlist),
            'start' => 0,
            'stop'  => -1,
        );
        $arrRet      = $objWordList->getTableContents($arrInput);
        if (null === $arrRet) {
            throw new Exception("get wordlist failed, wordlist[$wordlist]");
        }
        return $arrRet['ret'];
    }
}

class MyFile {
    const TYPE_READ     = 0;
    const TYPE_WRITE    = 1;
    private $_handler   = null;
    private $_filename  = '';

    /**
     * @brief 
     *
     * @param $filename
     * @param $type
     *
     * @return 
     */
    public function __construct($filename,  $type = self::TYPE_READ) {
        if (true === IS_DEBUG) {
            echo "open file, \033[32m$filename\033[0m, type : $type.\n";
        }
        if (0 >= strlen($filename)) {
            throw new Exception('invalid filename');
        }
        $this->_filename = $filename;
        if (self::TYPE_READ === $type) {
            if (!file_exists($filename)) {
                throw new Exception("file [$filename] not exist");
            }
            $this->_handler = fopen($filename, 'r');
        } else if (self::TYPE_WRITE === $type) {
            $this->_handler = fopen($filename, 'w');
        } else {
            throw new Exception("invalid open type[".$type."]");
        }
        if (!$this->_handler) {
            throw new Exception("open file failed : ".$filename);
        }
        return true;
    }

    /**
     * @brief 
     *
     * @param $arrData
     *
     * @return 
     */
    public function read2array(&$arrData) {
        while(!$this->isEnd()) {
            $data = $this->read();
            if (0 >= strlen($data)) {

            } else {
                $arrData [] = $data;
            }
        }
    }

    /**
     * @brief 
     *
     * @param $line_number
     *
     * @return 
     */
    public function move2line($line_number = 0) {
        for($i=0; $i<$line_number; $i++) {
            if (feof($this->_handler)) {
                throw new Exception("do not has that line, line_number[$i]");
            }
            fgets($this->_handler);
        }
        return true;
    }

    /**
     * @brief 
     *
     * @return 
     */
    public function getLineCount() {
        $output = array();
        exec("cat {$this->_filename} | wc -l", $output);
        $line_count = (int)trim($output[0]);
        return $line_count;
    }

    /**
     * @brief 
     *
     * @param $content
     *
     * @return 
     */
    public function write($content) {
        fputs($this->_handler, $content."\n");
        return true;
    }

    /**
     * @brief 
     *
     * @return 
     */
    public function read() {
        return trim(fgets($this->_handler));
    }

    /**
     * @brief 
     *
     * @return 
     */
    public function isEnd() {
        return feof($this->_handler);
    }

    public function __destruct() {
        fclose($this->_handler);
    }

    /**
     * @brief 
     *
     * @return 
     */
    public function getFileName() {
        return $this->_filename;
    }
}

class MyDom {
    /**
     * @brief 
     *
     * @return 
     */
    public static function createXml() {
        $xml = new DOMDocument("1.0", 'utf-8');
        return $xml;
    }

    /**
     * @brief 
     *
     * @param $xml
     * @param $data
     *
     * @return 
     */
    public static function createElement(&$xml, $data) {
        $node = $xml->createElement($data);
        return $node;
    }

    /**
     * @brief 
     *
     * @param $xml
     * @param $data
     *
     * @return 
     */
    public static function createCDATA(&$xml, $data) {
        $node = $xml->createCDATASection($data);
        return $node;
    }

    /**
     * @brief 
     *
     * @param $xml
     * @param $data
     *
     * @return 
     */
    public static function createTextNode(&$xml, $data) {
        $node = $xml->createTextNode($data);
        return $node;
    }

    /**
     * @brief 
     *
     * @param $father_node
     * @param $son_node
     *
     * @return 
     */
    public static function appendChild(&$father_node, &$son_node) {
        $father_node->appendChild($son_node);
    }

    /**
     * @brief 
     *
     * @param $xml
     * @param $filename
     *
     * @return 
     */
    public static function saveXml(&$xml, $filename = 'default-xml.xml') {
        $file = fopen($filename, 'w+');
        $content = $xml->saveXml();
        fputs($file, $content);
        fclose($file);
    }
}

class MyTool {
    /**
     * @brief 
     *
     * @param $content
     * @param $tag
     *
     * @return 
     */
    public static function contentreplaceTag(&$content, $tag = "a") {
        $pattern = "/<($tag)"."[^>]+>([^>]+$tag>|.* >)/u";
        if ($tag === 'img') {
            $pattern = "/<img[^>]+\s*>/u";
        }
        $content = preg_replace($pattern, '', $content);
        return $content;
    }

    /**
     * @brief 
     *
     * @param $content
     * @param $name
     *
     * @return 
     */
    public static function contentGetFromBracket(&$content, $name) {
        $pattern = "/{\"".$name."\":\"(.*?)\"}/u";
        $arrResult = array();
        preg_match_all($pattern, $content, $arrResult);
        return $arrResult[1][0];
    }

    /**
     * @brief 
     *
     * @param $count
     * @param $min
     * @param $max
     *
     * @return 
     */
    public static function getRandArray($count, $min = 0, $max = 0) {
        $arrData = array();
        if (0 === (int)$count) {
            throw new Exception("invalid count[$count]");
        }
        for($i=$min; $i<=$max; $i++) {
            $arrData [] = $i;
        }
        return array_rand($arrData, $count);
    }
}

class MyConf {
    const CONF_PREFIX = "@";
    const CONF_COMMENT = "#";

    private $_conf = array();

    public function __construct($conf_file) {
        $conf_handler = new MyFile($conf_file, MyFile::TYPE_READ);
        $tmp = array();
        $conf_handler->read2array($tmp);
        unset($conf_handler);

        $key = null;
        foreach($tmp as $data) {
            if(self::CONF_PREFIX === $data[0]) {
                $key = substr($data, 1, strlen($data)-1);
            }
            else if (self::CONF_COMMENT === $data[0]) {
            } else {
                if (is_null($key)) {
                } else {
                    $this->_conf[$key] = $data;
                    $key = null;
                }
            }
        }
    }

    public function getConf($key = '') {
        if ('' === $key) {
            return $this->_conf;
        } else {
            return $this->_conf[$key];
        }
    }
}

class MyCurl {
    private $_instance = null;
    public function __construct() {
        $this->_instance = curl_init();
    }

    public function post($url, $post) {
        curl_setopt($this->_instance, CURLOPT_URL, $url); 
        curl_setopt($this->_instance, CURLOPT_RETURNTRANSFER, TRUE); 
        curl_setopt($this->_instance, CURLOPT_POST, 1); 
        if (!empty($post)) {
            curl_setopt($this->_instance, CURLOPT_HTTPHEADER, array('Content-Type: text/plain'));
            /*
            curl_setopt($this->_instance, CURLOPT_HTTPHEADER, array(
                'X-AjaxPro-Method:ShowList',
                'Content-Type: application/json; charset=utf-8',
                'Content-Length: ' . strlen($post),
            ));
             */
            curl_setopt($this->_instance, CURLOPT_POSTFIELDS, $post);
        }
        for($i=0; $i<20; $i++) {
            $res = curl_exec($this->_instance); 
            if($res) {
                continue;
            }
        }
        return $res;

    }
}

class MyNlpc {
    const APP_KEY = "nlpc_201510121428030";
    const NLPC_WORDSEG_LANG_ID = 0; // 0, 默认为中文
    const NLPC_WORDSEG_LANG_PARA = 0; // 0为默认值，意味着打开分词处理中CRF开关并进行多切分

    const NLPC_WORDEMB_MODEL_ID_CW = 0; //0:cw, 1:cbow, 2:nnlm, 3:skipgram, 4:plsa. 1 and 2 is only for Chinese
    const NLPC_WORDEMB_MODEL_TID_SIM = 1; // 1: sim, 2: vec
    const NLPC_WORDEMB_MODEL_TID_VEC = 2; // 1: sim, 2: vec

    private static $_nlpc_service_map = array(
        'wordseg' => array(
            'url' => "http://bj01.nlpc.baidu.com/nlpc_wordseg_3016",
        ),
        'wordemb' => array(
            'url' => "http://bj01.nlpc.baidu.com/nlpc_wordemb_100",
        ),
    );

    public static function call($service, $input, $call_type = self::CALL_TYPE_CURL) {
        return call_user_func("self::_".$service, $input);
    }

    private static function buildUrl($service) {
        return self::$_nlpc_service_map[$service]['url']."?username=yaokun&app=".self::APP_KEY;
    }

    private static function _transfer2GbjJson($arrInput) {
        $strPostRaw = json_encode($arrInput, JSON_UNESCAPED_UNICODE);
        $strPostRaw = iconv("UTF-8", "GB2312//IGNORE", $strPostRaw);
        return $strPostRaw;
    }

    public static function wordseg($input) {
        if(CALL_NLP_TYPE === 1) {
            $arrInput = array(
                'query' => $this->_tmp_line,
            );
            $arrOutput = Tieba_Service::call('tpoint', 'wordseg', $arrInput);
            var_dump($arrOutput);
        } else {
            $instance = new MyCurl();
            $url = self::buildUrl(__FUNCTION__);
            $query = $input['query'];
            $arrWordsegOpt = array(
                'lang_id' => self::NLPC_WORDSEG_LANG_ID,
                'lang_para' => self::NLPC_WORDSEG_LANG_PARA,
                'query' => $query,
            );
            $post = self::_transfer2GbjJson($arrWordsegOpt);
            $res = $instance->post($url, $post);
            $res = iconv("GB2312", 'UTF-8', $res);
            $arrRes = json_decode($res, true);
            return $arrRes;
        }
    }

    public static function wordemb($input) {
        if(CALL_NLP_TYPE === 1) {
            $arrInput = array(
                'query' => $this->_tmp_line,
            );
            $arrOutput = Tieba_Service::call('tpoint', 'wordseg', $arrInput);
            var_dump($arrOutput);
        } else {
            $instance = new MyCurl();
            $url = self::buildUrl(__FUNCTION__);
            $query1 = $input['query1'];
            $query2 = $input['query2'];
            $arrNlpinput = array(
                'mid' => self::NLPC_WORDEMB_MODEL_ID_CW,
                'tid' => self::NLPC_WORDEMB_MODEL_TID_SIM,
                'query1' => $query1,
                'query2' => $query2,
            );
            $post = self::_transfer2GbjJson($arrNlpinput);
            $res = $instance->post($url, $post);
            $res = iconv("GB2312", 'UTF-8', $res);
            $arrRes = json_decode($res, true);
            return $arrRes;
        }
    }

}

?>
