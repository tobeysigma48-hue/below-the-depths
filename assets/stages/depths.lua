local fall = {5}
local exclusion = '5'
local fallPos = {}
local ballScales = {}
local dead = false
local first = true
local alphaLoop = true
local followchars = true
local zoomLock = true
local gravity = 9.8
local xx2 = 1030
local speed = 0
local yy2 = 580
local ofs = 45
local zoom = 0

local bgs = {'depths', 'floor', 'ceiling'}
local xpos = {-50, -50, -70}
local ypos = {-80, 0, -50}

--orignal camZoom = 0.63

function onCreate()
	setPropertyFromClass('GameOverSubstate', 'characterName', 'dead')

	for i = 1,#bgs do
		makeLuaSprite(bgs[i], 'bg/sink'..bgs[i], xpos[i], ypos[i])
		scaleObject(bgs[i], 1.11, 1.1)
		addLuaSprite(bgs[i])
		if i == 1 then
			for a = 1,10 do
				local scale = getRandomFloat(0.1, 1)
				ballScales[a] = scale
				makeLuaSprite('ball'..a, 'bg/ball', -80 + 200*a, -380)
				scaleObject('ball'..a, scale, scale)
				addLuaSprite('ball'..a)
			end
		end
	end
	--setScrollFactor('depths', 0.2, 0.2)
	setScrollFactor('ceiling', 0.9, 0.9)

	speed = 240 / getPropertyFromClass('ClientPrefs', 'framerate')
	for i = 1,10 do fallPos[i] = 0 end
end

function onCreatePost()
	addCharacterToList('sinkless', 'boyfriend')

	setProperty('healthLoss', 0)

    zoom = getProperty('camGame.zoom') + 0.36

	makeAnimatedLuaSprite('waves', 'bg/waves', 0, 0)
	addAnimationByPrefix('waves', 'idle', 'idle', 13, true)
	setObjectCamera('waves', 'camHud')
	setProperty('waves.alpha', 0.06 )
	scaleObject('waves', 1280/512, 820/512)
	addLuaSprite('waves', true)
	setBlendMode('waves', 'subtract')

	--[[ Might Use
	makeAnimatedLuaSprite('waves', 'bg/waves', 0, 0)
	addAnimationByPrefix('waves', 'idle', 'idle', 13, true)
	setObjectCamera('waves', 'camHud')
	setProperty('waves.alpha', 0.08)
	scaleObject('waves', 1280/512, 820/512)
	addLuaSprite('waves', true)
	setBlendMode('waves', 'screen')
	]]

	makeLuaSprite('vignette', 'bg/vignette', 0, 0)
	setObjectCamera('vignette', 'camHud')
	addLuaSprite('vignette', true)

	--addLuaSprite('r', true)
end

function onSongStart()
	--setProperty('health', 0.00001)
end

function opponentNoteHit(id, direction, noteType, isSustainNote)
	if first and dead == false then
		setProperty('dad.alpha', 0.4)
		doTweenAlpha('boo1', 'dad', 0, 0.6, 'linear')
		first = false
	end
end

function noteMiss(id, direction, noteType, isSustainNote)
	if getProperty('health') >= 0.20 then setProperty('health', getProperty('health') - 0.15) elseif getProperty('health') < 0.20 and dead == false then setProperty('health', 0.0001); die() end
end

function die()
	makeLuaSprite('r', 'bg/r', 0, 200)
	setProperty('r.alpha', 0.5)
	setObjectCamera('r', 'camHud')
	addLuaSprite('r', true)

	triggerEvent('Change Character', 0, 'sinkless')

	doTweenAlpha('r1', 'r', 1, 1, 'linear')

	setProperty('boyfriend.stunned', true)

	for i = 0, getProperty('notes.length')-1 do
		if getPropertyFromGroup('notes', i, 'mustPress') == false then
			setPropertyFromGroup('notes', i, 'ignoreNote', true)
		end
	end
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'mustPress') == false then
			setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true)
		end
	end

	dead = true
end

function onUpdate(elapsed)
	if followchars == true then
		  if getProperty('boyfriend.animation.curAnim.name') == 'singLEFT' then
			triggerEvent('Camera Follow Pos',xx2-ofs,yy2)
		  end
		  if getProperty('boyfriend.animation.curAnim.name') == 'singRIGHT' then
			triggerEvent('Camera Follow Pos',xx2+ofs,yy2)
		  end
		  if getProperty('boyfriend.animation.curAnim.name') == 'singUP' then
			triggerEvent('Camera Follow Pos',xx2,yy2-ofs)
		  end
		  if getProperty('boyfriend.animation.curAnim.name') == 'singDOWN' then
			triggerEvent('Camera Follow Pos',xx2,yy2+0)
		  end
		  if getProperty('boyfriend.animation.curAnim.name') == 'idle-alt' then
			triggerEvent('Camera Follow Pos',xx2,yy2)
		  end
		  if getProperty('boyfriend.animation.curAnim.name') == 'idle' then
			triggerEvent('Camera Follow Pos',xx2,yy2)
		  end
	else
		triggerEvent('Camera Follow Pos','','')
	end

	if zoomLock then setProperty('camGame.zoom', zoom) end

	for i = 1,#fall do
		moveBall(fall[i])
	end
end

function moveBall(number)
	fallPos[number] = fallPos[number] + 0.003 * speed * ballScales[number]
	local ypos = getHeight(-380, fallPos[number])
	local xpos = math.sin(getSongPosition()/1000 + number * 0.45) * 50 * ballScales[number] + -80 + 200 * number

	if ypos >= 1700 then
		fallPos[number] = 0
	end
	setProperty('ball'..number..'.y', ypos)
	setProperty('ball'..number..'.x', xpos)
end

function onStartCountdown()
	setProperty('dad.alpha', 0)
	setProperty('iconP2.alpha', 0)
	return Function_Continue
end

function onCountdownTick(counter)
	if counter == 1 then doTweenAlpha('b', 'waves', 0.06, 0.6, 'linear') end
end

function onStepHit()
	if curStep == 512 then alphaLoop = false end
	if curStep == 517 then doTweenAlpha('first', 'waves', 0.35, 0.8, 'linear') end
	--if curStep == 528 then doTweenZoom('second', 'camGame', zoom - (zoom-0.63)/3, 0.8, 'circInOut') end
end

function onTweenCompleted(tag)
	if tag == 'boo1' then doTweenAlpha('boo2', 'dad', 0.45, 0.6, 'linear') end
	if tag == 'boo2' then doTweenAlpha('boo1', 'dad', 0.1, 0.6, 'linear') end
	if tag == 'a' and alphaLoop then doTweenAlpha('b', 'waves', 0.06, 0.8, 'linear') end
	if tag == 'b' and alphaLoop then doTweenAlpha('a', 'waves', 0.12, 0.8, 'linear') end
	if tag == 'first' then alphaLoop = true; doTweenAlpha('b', 'waves', 0.06, 0.8, 'linear') end
	if tag == 'second' then zoom = zoom - 0.36/8; zoomLock = true end
	if tag == 'r1' then doTweenAlpha('r2', 'r', 0.5, 1, 'linear') end
	if tag == 'r2' then doTweenAlpha('r1', 'r', 1, 1, 'linear') end
end

function onBeatHit()
	if dead == false and curBeat % 4 == 0 and curStep > 526 and curStep < 641 then zoomLock = false; doTweenZoom('second', 'camGame', zoom - (zoom-0.63)/8, 0.8, 'linear') end
--[[
	if curBeat % 36 == 0 then
		local number = getRandomInt(1,10)
		fall[number] = true
	end
	]]
	if curBeat % 16 == 0 and #fall < 10 then
		local rng = getRandomInt(1,10, exclusion)
		table.insert(fall, #fall+1, rng)
		exclusion = exclusion..','..rng
	end
end

function getHeight(baseH, tiempo)
    local height = 0

    height = baseH + ((gravity)*tiempo*tiempo)/2
    return height
end