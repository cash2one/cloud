local cjson = require "cjson"
local client = require "resty.kafka.client"
local producer = require "resty.kafka.producer"

local args = ngx.req.get_uri_args()
-- ngx.say(args.kafka_msg)
if not args.kafka_msg then
    ngx.say("<b>empty message</b>")
    return
end

-- broker list
local broker_list = {
    { host = "10.208.71.23", port = 9093 },
    { host = "10.208.71.24", port = 9094 },
}

local topic = "hellokafka";
local cli = client:new(broker_list)
local brokers, partitions = cli:fetch_metadata(topic)

-- ngx.say("[fetch_metadata]");
if not brokers then
    -- todo add log
    ngx.say("fetch_metadata failed, err: ", partitions)
end
-- ngx.say("brokers: ", cjson.encode(brokers), ";\npartitions: ", cjson.encode(partitions), ";")
-- ngx.say("[send message]");

local key = nil -- partition key
local message = args.kafka_msg
local bp = producer:new(broker_list, { producer_type = "async" })
local ok, err = bp:send(topic, key, message)
if not ok then
    -- todo add log
    ngx.say("send err:", err)
    return
end
-- ngx.say("Message : [<b>", message, "</b>]<br>")
-- ngx.say("----[sending success]----")
