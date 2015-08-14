local cjson = require('cjson')
local urest = require("src/urest");

urest.post("/foo/bar/baz", function(request, params, body)
    return {
        something = "post result",
        body = body
    }
end)

urest.get("/foo/bar", function()
    return { "result", "should", "be an array" }
end)

urest.post("/withId/(%d+).foo", function(request, params, body)
    return { route = "withId", id = params[1] }
end)

print("----GET TEST");
print(urest.handle("GET /foo/bar HTTP/1.0\r\n"))

print("----GET TEST (404)");
print(urest.handle("GET /xx/xx HTTP/1.0\r\n"))

print("\n\n----POST TEST");
print(urest.handle(
    "POST /foo/bar/baz HTTP/1.0\r\n" ..
            "X-Foo: Bar\r\n" ..
            "\r\n" ..
            "This is the request-body.\n" ..
            "Another line.\nEND"))

print("\n\n----POST TEST");
print(urest.handle(
    "POST /withId/132481.foo HTTP/1.0\r\n" ..
            "\r\n" ..
            "This is the request-body.\n" ..
            "Another line.\nEND"))