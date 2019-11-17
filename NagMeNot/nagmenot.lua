--[[
        Copyright © 2019, Rubenator
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

            * Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
            * Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in the
              documentation and/or other materials provided with the distribution.
            * Neither the name of NagMeNot nor the
              names of its contributors may be used to endorse or promote products
              derived from this software without specific prior written permission.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
        ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
        WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        DISCLAIMED. IN NO EVENT SHALL Rubenator BE LIABLE FOR ANY
        DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
_addon.author = 'Rubenator'
_addon.command = 'nagmenot'
_addon.name = 'NagMeNot'
_addon.version = '1.0.1'

local MOG_EXIT_MENU_ID = 30004
local RESPOND_YES = 0
local RESPOND_NO = 1

local packets = require("packets")

function respond(menu_id, option, target)
  option = option or RESPOND_NO
  target = target or windower.ffxi.get_player()
  local menu_response_packet = packets.new('outgoing', 0x05B --[[Menu Response]], {
      ['Target'] = target.id,
      ['Option Index'] = option,
      ['Target Index'] = target.index,
      ['Automated Message'] = false,
      ['Zone'] = windower.ffxi.get_info().zone,
      ['Menu ID'] = menu_id,
    })
    packets.inject(menu_response_packet)
end

windower.register_event('incoming chunk', function(id,original,modified,injected,blocked)
  if id == 0x00A then --[[Zone Packet]]
    local packet = packets.parse('incoming', original)
    if packet['Menu ID'] == MOG_EXIT_MENU_ID then
      coroutine.schedule(functions.prepare(respond, MOG_EXIT_MENU_ID), 0.2)
      packet['Menu Zone'] = 0
      packet['Menu ID'] = 0
      return packets.build(packet)
    end
  end
end)
