local application = {};

function application.start()
    collectgarbage();

    local restServer = require("rest-server");
    restServer.init(config);
end

return application
