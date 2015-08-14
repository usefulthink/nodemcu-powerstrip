config = require("config")

local function wifi_start(accessPoints)
    for essid, info in pairs(accessPoints) do
        if config.SSID and config.SSID[essid] then
            wifi.sta.config(essid, config.SSID[essid]);
            wifi.sta.connect();
            config.SSID = nil;

            tmr.alarm(1, 500, 1, function()
                if wifi.sta.getip() then
                    tmr.stop(2);
                    tmr.stop(1);
                    print("Connected to network: " .. essid .. ", IP address: " .. wifi.sta.getip());

                    collectgarbage();
                    require("application").start();
                end
            end);

            break
        end
        collectgarbage();
    end
end

print("connecting...");
collectgarbage();
wifi.setmode(wifi.STATION);
wifi.sta.getap(wifi_start);