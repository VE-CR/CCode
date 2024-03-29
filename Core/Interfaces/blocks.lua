local listeners = {}
local INPUT = require 'Core.Modules.interface-input'
local LIST = require 'Core.Modules.interface-list'
local INFO = require 'Data.info'

listeners.but_add = function(target)
    BLOCKS.group.isVisible = false
    NEW_BLOCK = require 'Interfaces.new-block'
    NEW_BLOCK.create()
end

listeners.but_play = function(target)
    BLOCKS.group.isVisible = false
    START = require 'Core.Simulation.start'
    START.new()
end

listeners.but_list = function(target)
    if #BLOCKS.group.blocks ~= 0 then
        local list = {STR['button.remove'], STR['button.copy'], STR['button.comment']}

        BLOCKS.group[8]:setIsLocked(true, 'vertical')
        if BLOCKS.group.isVisible then
            LIST.new(list, MAX_X, target.y - target.height / 2, 'down', function(e)
                BLOCKS.group[8]:setIsLocked(false, 'vertical')

                if e.index ~= 0 then
                    ALERT = false
                    INDEX_LIST = e.index

                    BLOCKS.group[3].isVisible = true
                    BLOCKS.group[4].isVisible = false
                    BLOCKS.group[5].isVisible = false
                    BLOCKS.group[6].isVisible = false
                    BLOCKS.group[7].isVisible = true

                    for i = 1, #BLOCKS.group.blocks do
                        BLOCKS.group.blocks[i].x = BLOCKS.group.blocks[i].x + 20
                        BLOCKS.group.blocks[i].checkbox:setState({isOn = false})
                        BLOCKS.group.blocks[i].checkbox.isVisible = true
                        BLOCKS.group.blocks[i].rects.isVisible = false
                    end

                    MORE_LIST = e.text ~= STR['button.copy']
                    BLOCKS.group[3].text = '(' .. e.text .. ')'
                end
            end, nil, nil, 1)
        else
            BLOCKS.group[8]:setIsLocked(false, 'vertical')
        end
    end
end

listeners.but_okay = function(target)
    local data = GET_GAME_CODE(CURRENT_LINK)

    ALERT = true
    LAST_CHECKBOX = 0
    BLOCKS.group[3].text = ''
    BLOCKS.group[3].isVisible = false
    BLOCKS.group[4].isVisible = true
    BLOCKS.group[5].isVisible = true
    BLOCKS.group[6].isVisible = true
    BLOCKS.group[7].isVisible = false

    for i = 1, #BLOCKS.group.blocks do
        BLOCKS.group.blocks[i].x = BLOCKS.group.blocks[i].x - 20
        BLOCKS.group.blocks[i].checkbox.isVisible = false
        BLOCKS.group.blocks[i].rects.isVisible = true
    end

    if INDEX_LIST == 1 then
        for i = #BLOCKS.group.blocks, 1, -1 do
            if BLOCKS.group.blocks[i].checkbox.isOn then
                BLOCKS.group.scrollHeight = BLOCKS.group.scrollHeight - BLOCKS.group.blocks[i].block.height + 4
                if BLOCKS.group.blocks[i].data.event then BLOCKS.group.scrollHeight = BLOCKS.group.scrollHeight - 24 end
                BLOCKS.group.blocks[i]:removeSelf()
                table.remove(BLOCKS.group.blocks, i)
                table.remove(data.scripts[CURRENT_SCRIPT].params, i)
            end
        end

        for i = 1, #BLOCKS.group.blocks do
            local y = i == 1 and 50 or BLOCKS.group.blocks[i - 1].y + BLOCKS.group.blocks[i - 1].block.height / 2 + BLOCKS.group.blocks[i].height / 2 - 4
            if BLOCKS.group.blocks[i].data.event then y = y + 24 end BLOCKS.group.blocks[i].y = y BLOCKS.group[8]:setScrollHeight(BLOCKS.group.scrollHeight)
        end
    elseif INDEX_LIST == 2 then
        for i = 1, #BLOCKS.group.blocks do
            if BLOCKS.group.blocks[i].checkbox.isOn then
                BLOCKS.group.blocks[i].checkbox:setState({isOn = false})

                local scrollY = select(2, BLOCKS.group[8]:getContentPosition())
                local diffY = BLOCKS.group[8].y - BLOCKS.group[8].height / 2
                local targetY = math.abs(scrollY) + diffY + CENTER_Y - 150
                local blockIndex = i
                local blockData = COPY_TABLE(BLOCKS.group.blocks[i].data)

                if blockData.event then
                    table.insert(data.scripts[CURRENT_SCRIPT].params, blockIndex, blockData)
                    BLOCKS.new(blockData.name, blockIndex, blockData.event, blockData.params, blockData.comment, blockData.nested)

                    for j = blockIndex + 2, #BLOCKS.group.blocks do
                        if BLOCKS.group.blocks[j + blockIndex - i].data.event then break end
                        blockIndex, blockData = blockIndex + 1, COPY_TABLE(BLOCKS.group.blocks[j + blockIndex - i].data)
                        table.insert(data.scripts[CURRENT_SCRIPT].params, blockIndex, blockData)
                        BLOCKS.new(blockData.name, blockIndex, blockData.event, blockData.params, blockData.comment, blockData.nested)
                    end

                    SET_GAME_CODE(CURRENT_LINK, data)
                    display.getCurrentStage():setFocus(BLOCKS.group.blocks[i])
                    BLOCKS.group.blocks[i].click = true
                    BLOCKS.group.blocks[i].move = true
                    newMoveLogicBlock({target = BLOCKS.group.blocks[i]}, BLOCKS.group, BLOCKS.group[8])
                else
                    table.insert(data.scripts[CURRENT_SCRIPT].params, blockIndex, blockData)
                    BLOCKS.new(blockData.name, blockIndex, blockData.event, blockData.params, blockData.comment)

                    SET_GAME_CODE(CURRENT_LINK, data)
                    display.getCurrentStage():setFocus(BLOCKS.group.blocks[blockIndex])
                    BLOCKS.group.blocks[blockIndex].click = true
                    BLOCKS.group.blocks[blockIndex].move = true
                    newMoveLogicBlock({target = BLOCKS.group.blocks[blockIndex]}, BLOCKS.group, BLOCKS.group[8])
                end

                break
            end
        end

        for i = 1, #BLOCKS.group.blocks do
            if BLOCKS.group.blocks[i].checkbox.isOn then
                BLOCKS.group.blocks[i].checkbox:setState({isOn = false})
            end
        end
    elseif INDEX_LIST == 3 then
        for i = #BLOCKS.group.blocks, 1, -1 do
            if BLOCKS.group.blocks[i].checkbox.isOn then
                BLOCKS.group.blocks[i].checkbox:setState({isOn = false})

                if BLOCKS.group.blocks[i].data.comment then
                    data.scripts[CURRENT_SCRIPT].params[i].comment = false
                    BLOCKS.group.blocks[i].block:setFillColor(INFO.getBlockColor(BLOCKS.group.blocks[i].data.name, false))
                    BLOCKS.group.blocks[i].data.comment = false
                else
                    data.scripts[CURRENT_SCRIPT].params[i].comment = true
                    BLOCKS.group.blocks[i].block:setFillColor(INFO.getBlockColor(BLOCKS.group.blocks[i].data.name, true))
                    BLOCKS.group.blocks[i].data.comment = true
                end

                if BLOCKS.group.blocks[i].data.event then
                    for j = i + 1, #BLOCKS.group.blocks do
                        if BLOCKS.group.blocks[j].data.event then break end
                        data.scripts[CURRENT_SCRIPT].params[j].comment = BLOCKS.group.blocks[i].data.comment
                        BLOCKS.group.blocks[j].block:setFillColor(INFO.getBlockColor(BLOCKS.group.blocks[j].data.name, BLOCKS.group.blocks[i].data.comment))
                        BLOCKS.group.blocks[j].data.comment = BLOCKS.group.blocks[i].data.comment
                    end
                end
            end
        end
    elseif INDEX_LIST == 4 then
        for i = 1, #BLOCKS.group.blocks do
            if BLOCKS.group.blocks[i].checkbox.isOn then
                BLOCKS.group.blocks[i].checkbox:setState({isOn = false})

                if #BLOCKS.group.blocks[i].data.nested > 0 then
                    for j = 1, #BLOCKS.group.blocks[i].data.nested do
                        local blockIndex, blockData = i + j, COPY_TABLE(BLOCKS.group.blocks[i].data.nested[j])
                        table.insert(data.scripts[CURRENT_SCRIPT].params, blockIndex, blockData)
                        BLOCKS.new(blockData.name, blockIndex, blockData.event, blockData.params, blockData.comment)
                    end

                    data.scripts[CURRENT_SCRIPT].params[i].nested, BLOCKS.group.blocks[i].data.nested = {}, {}
                else
                    for j = i + 1, #BLOCKS.group.blocks do
                        if BLOCKS.group.blocks[i + 1].data.event then break end
                        table.insert(BLOCKS.group.blocks[i].data.nested, BLOCKS.group.blocks[i + 1].data)
                        BLOCKS.group.scrollHeight = BLOCKS.group.scrollHeight - BLOCKS.group.blocks[i + 1].block.height + 4
                        if BLOCKS.group.blocks[i + 1].data.event then BLOCKS.group.scrollHeight = BLOCKS.group.scrollHeight - 24 end
                        BLOCKS.group.blocks[i + 1]:removeSelf() table.remove(BLOCKS.group.blocks, i + 1)
                        table.remove(data.scripts[CURRENT_SCRIPT].params, i + 1)
                    end

                    for i = 1, #BLOCKS.group.blocks do
                        local y = i == 1 and 50 or BLOCKS.group.blocks[i - 1].y + BLOCKS.group.blocks[i - 1].block.height / 2 + BLOCKS.group.blocks[i].height / 2 - 4
                        if BLOCKS.group.blocks[i].data.event then y = y + 24 end BLOCKS.group.blocks[i].y = y BLOCKS.group[8]:setScrollHeight(BLOCKS.group.scrollHeight)
                    end

                    data.scripts[CURRENT_SCRIPT].params[i].nested = BLOCKS.group.blocks[i].data.nested
                end

                break
            end
        end
    end

    for i = 1, #BLOCKS.group.blocks do BLOCKS.group.blocks[i].checkbox:setState({isOn = false}) end
    if INDEX_LIST ~= 2 then SET_GAME_CODE(CURRENT_LINK, data) end
end

return function(e)
    if BLOCKS.group.isVisible and (ALERT or e.target.button == 'but_okay') then
        if e.phase == 'began' then
            display.getCurrentStage():setFocus(e.target)
            e.target.click = true
            if e.target.button == 'but_list'
            then e.target.width, e.target.height = 103 / 1.2, 84 / 1.2
            else e.target.alpha = 0.6 end
        elseif e.phase == 'moved' and (math.abs(e.x - e.xStart) > 30 or math.abs(e.y - e.yStart) > 30) then
            e.target.click = false
            if e.target.button == 'but_list'
            then e.target.width, e.target.height = 103, 84
            else e.target.alpha = 0.9 end
        elseif e.phase == 'ended' or e.phase == 'cancelled' then
            display.getCurrentStage():setFocus(nil)
            if e.target.click then
                e.target.click = false
                if e.target.button == 'but_list'
                then e.target.width, e.target.height = 103, 84
                else e.target.alpha = 0.9 end
                listeners[e.target.button](e.target)
            end
        end
        return true
    end
end
