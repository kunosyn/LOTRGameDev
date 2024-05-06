local Skills = { }

Skills['0:4'] = function(actionName: string, inputState: Enum.UserInputState, input: InputObject)
    if inputState ~= Enum.UserInputState.Begin then return end
    
    print('triggered')
end

return Skills