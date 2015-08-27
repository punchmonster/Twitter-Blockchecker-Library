local blockcheck = {
  _VERSION     = 'blockcheck library v0.9b',
  _DESCRIPTION = 'checking various Twitter blocklists for Lapis framework in Lua (5.1-3, LuaJIT)',
  _URL         = '',
  _LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2015 Jamie Roling

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

----------------------------------------------------------------
-- load modules
local lapis      = require('lapis')
local db         = require('lapis.db')
local http       = require('lapis.nginx.http')
local config     = require("lapis.config").get()

--[[
FUNCTION: theblockbot()
DESCRIPTION:
  Will search Atheism+'s blockbot for the string passed as the name argument'
]]
function blockcheck.theblockbot(name)

  -- store result of check
  local result = "@" .. name .. ' is not on The Block Bots blocklist.'

  -- retrieve cache from database
  cache = db.select('* from cache order by time DESC limit 1')

  -- if the cache is older than config.update_freq, update the cache
  if ngx.time() > ( cache[1]['time'] + config.update_freq ) or cache[1]['time'] == nil  then

    -- scrape the blocklist html
    local body, status_code, headers = http.simple('http://www.theblockbot.com/sign_up/connect.php')

    -- filters the unneeded html
    local body_parsed = string.match(body, 'level_1_blocks.*</div>')
    -- push new cache to database
    db.update('cache', {
      time = ngx.time(),
      data = body_parsed
    }, {
      time = cache[1]['time']
    })
  end

  -- find user in blockbot or not
  if string.find(cache[1]['data'], '>' .. name .. '<') ~=nil then
    result = "<strong>@" .. name .. ' is on The Block Bot blocklist.</strong> '
  end

  return result
end

--[[
FUNCTION: blocktogether()
DESCRIPTION:
  Will search the blocktogether blocklists for the string passed as the name argument
RETURN TYPE:
  returns a table 
]]
function blockcheck.blocktogether(name)

  local result = {}

  -- iterate through URLs
  for i=1,#config.blockURL,1 do

    -- scrape the search url of the blocklist
    local body, status_code, headers = http.simple( config.blockURL[i]['url'] .. '?screen_name=' .. name )

    -- check if the person is blocked and if yes, set status to true
    if string.match(body, 'blocks @') ~= nil then
      result[i] = { name = config.blockURL[i]['name'], status = true }
    else
      result[i] = { name = config.blockURL[i]['name'], status = false }
    end
  end

  return result
end

return blockcheck
