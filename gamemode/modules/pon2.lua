--[[ 
DEVELOPMENTAL VERSION;
VERSION 2.0.0
Copyright thelastpenguin™ 
	You may use this for any purpose as long as:
	-	You don't remove this copyright notice.
	-	You don't claim this to be your own.
	-	You properly credit the author, thelastpenguin™, if you publish your work based on (and/or using) this.
	
	If you modify the code for any purpose, the above still applies to the modified code.
	
	The author is not held responsible for any damages incured from the use of pon1, you use it at your own risk.
DATA TYPES SUPPORTED:
 - tables  - 		k,v - pointers
 - strings - 		k,v - pointers
 - numbers -		k,v
 - booleans- 		k,v
 - Vectors - 		k,v
 - Angles  -		k,v
 - Entities- 		k,v
 - Players - 		k,v
 
CHANGE LOG
V 2.0.0 - made pon v2, more compact than pon1 and has better performance for large strings
	- note that some performance is lost on integer datatypes.
]]

pon2 = {}

local string_char = string.char
local string_byte = string.byte
local string_sub = string.sub
local tonumber = tonumber
local tostring = tostring
local string_format = string.format
local string_len = string.len
local type = type
local pairs = pairs
local table_concat = table.concat

local Entity = Entity
local Vector = Vector
local Angle = Angle
local EntIndex = FindMetaTable('Entity').EntIndex



local key_types = {
	['ptr'] 		= 0,
	['incr'] 		= 1,
	['string'] 	= 2,
	['number'] 	= 3,
	['table'] 	= 4,
	
	['Entity'] 	= 5,
	['Player'] 	= 5,
	['Vehicle'] = 5,
	['Weapon'] 	= 5,
	['NPC'] 		= 5,
	['NextBot'] = 5,

	['Vector'] 	= 6,
	['Angle'] 	= 7
}

local val_types = {
	['ptr'] 		= 0,
	['string'] 	= 1,
	['number'] 	= 2,
	['float'] 	= 3,
	['table'] 	= 4,

	['Entity'] 	= 5,
	['Player'] 	= 5,
	['Vehicle'] = 5,
	['Weapon'] 	= 5,
	['NPC'] 		= 5,
	['NextBot'] = 5,

	['Vector'] = 6,
	['Angle'] = 7
}

local seperator = string_char(32) -- TODO: simply replace this into the code everywhere it's used

local type_pair_to_id = {}
local id_to_key_type = {}
local id_to_val_type = {}
for ktype, kid in pairs(key_types)do
	local tbl = {} type_pair_to_id[ktype] = tbl
	for vtype, vid in pairs(val_types)do
		local pair_id = string_char(kid*8+vid+33)
		tbl[vtype] = pair_id
		id_to_key_type[pair_id] = ktype
		id_to_val_type[pair_id] = vtype
	end
end

local type_pair_to_id_incr = type_pair_to_id['incr']

local num_to_char = {}
local char_to_num = {}
local char = string.char
for i = 0, 94 do
	num_to_char[i] = string_char(32+i)
	char_to_num[string_char(32+i)] = i
end

local encoders = {}
local decoders = {}

-- local variables + closures are faster
local output = {}
local cache = {}
local output_len = 1
local cache_size = 0

-- local variables + closures for decoding
local index = 1
local str = nil
local strlen = 0

encoders['table'] = function(val)
	cache[val] = cache_size
	cache_size = cache_size + 1

	local arrayKey = 1
	local tk, tv
	for k,v in pairs(val)do
		if cache[v] then
			tv = 'ptr'
		else
			tv = type(v)
		end

		if k == arrayKey then
			output[output_len] = type_pair_to_id_incr[tv]
			output_len = output_len + 1

			arrayKey = arrayKey + 1

			encoders[tv](v)
		else
			if cache[k] then
				tk = 'ptr'
			else
				tk = type(k)
			end

			output[output_len] = type_pair_to_id[tk][tv]
			output_len = output_len + 1

			encoders[tk](k)
			encoders[tv](v)
		end
	end

	output[output_len] = seperator
	output_len = output_len + 1
end

decoders['table'] = function()
	local obj = {}

	cache[cache_size] = obj
	cache_size = cache_size + 1

	local arrayKey = 1

	while(index < strlen)do
		local typeChar = string_sub(str, index, index)
		index = index + 1

		if typeChar == seperator then
			break
		end

		local ktype = id_to_key_type[typeChar]
		local vtype = id_to_val_type[typeChar]

		local key
		if ktype == 'incr' then
			key = arrayKey
			arrayKey = arrayKey + 1
		else
			key = decoders[ktype]()
		end

		local value = decoders[vtype]()

		obj[key] = value
	end

	return obj
end

encoders['ptr'] = function(val)
	local val = cache[val]
	while(val >= 47)do
		output[output_len] = num_to_char[47+val%47]
		output_len = output_len + 1
		val = val/47
		val = val - val%1
	end
	output[output_len] = num_to_char[val%47]
	output_len = output_len + 1
end

decoders['ptr'] = function()
	local num = 0
	local val
	local multiplier = 1
	while(true)do
		val = char_to_num[string_sub(str, index, index)]
		index = index + 1
		if val < 47 then
			num = num + val*multiplier
			break
		else
			num = num + (val-47)*multiplier
		end
		multiplier = multiplier * 47
	end
	return cache[num]
end

encoders['number'] = function(val)
	local decimal = val % 1
	if val < 0 then
		if decimal == 0 then
			local strval = string_format('%x', -val)
			local strlen = string_len(strval)
			output[output_len] = num_to_char[40+strlen]..strval
			output_len = output_len + 1
		else
			local strval = (tostring(-val))
			local strlen = string_len(strval)
			output[output_len] =  num_to_char[60+strlen]..strval
			output_len = output_len + 1
		end
	else
		if decimal == 0 then
			local strval = string_format('%x', val)
			local strlen = string_len(strval)
			output[output_len] =  num_to_char[strlen]..strval
			output_len = output_len + 1
		else
			local strval = (tostring(val))
			local strlen = string_len(strval)
			output[output_len] =  num_to_char[60+strlen]..strval
			output_len = output_len + 1
		end
	end
end

decoders['number'] = function()
	local len = char_to_num[string_sub(str, index, index)]
	index = index + 1

	local numType = len/20
	numType = numType - numType % 1
	len = len % 20

	local num
	if numType % 2 == 0 then
		num = tonumber(string_sub(str, index, index+len-1), 16)
		index = index + len
	else
		num = tonumber(string_sub(str, index, index+len-1))
		index = index + len
	end

	if numType < 2 then
		return num
	else
		return -num
	end
end

encoders['string'] = function(val)
	-- cache the string
	cache[val] = cache_size
	cache_size = cache_size + 1

	-- encode it...
	local strlen = string_len(val)

	while(strlen >= 47)do
		output[output_len] = num_to_char[47+strlen%47]
		output_len = output_len + 1
		strlen = strlen/47
		strlen = strlen - strlen % 1
	end
	output[output_len] = num_to_char[strlen%47]
	output_len = output_len + 1

	output[output_len] = val
	output_len = output_len + 1
end

decoders['string'] = function()
	local num = 0
	local val
	local multiplier = 1
	while(true)do
		val = char_to_num[string_sub(str, index, index)]
		index = index + 1
		if val < 47 then
			num = num + val*multiplier
			break
		else
			num = num + (val-47)*multiplier
		end
		multiplier = multiplier * 47
	end

	local str = string_sub(str, index, index+num-1)
	cache[cache_size] = str
	cache_size = cache_size + 1
	index = index+num
	return str
end

encoders['Entity'] = function(val)
	local val = EntIndex(val)
	while(val >= 47)do
		output[output_len] = num_to_char[47+val%47]
		output_len = output_len + 1
		val = val/47
		val = val - val%1
	end
	output[output_len] = num_to_char[val%47]
	output_len = output_len + 1
end
encoders['Player'] 	= encoders['Entity']
encoders['Vehicle'] = encoders['Entity']
encoders['Weapon'] 	= encoders['Entity']
encoders['NPC'] 		= encoders['Entity']
encoders['NextBot'] = encoders['Entity']

decoders['Entity'] = function()
	local num = 0
	local val
	local multiplier = 1
	while(true)do
		val = char_to_num[string_sub(str, index, index)]
		index = index + 1
		if val < 47 then
			num = num + val*multiplier
			break
		else
			num = num + (val-47)*multiplier
		end
		multiplier = multiplier * 47
	end
	return Entity(num)
end

decoders['Player'] 	= decoders['Entity']
decoders['Vehicle'] = decoders['Entity']
decoders['Weapon'] 	= decoders['Entity']
decoders['NPC'] 		= decoders['Entity']
decoders['NextBot'] = decoders['Entity']


local writeNumber = encoders['number']
local readNumber = decoders['number']

encoders['Vector'] = function(val)
	writeNumber(val.x)
	writeNumber(val.y)
	writeNumber(val.z)
end

decoders['Vector'] = function(val)
	return Vector(readNumber(), readNumber(), readNumber())
end

encoders['Angle'] = function(val)
	writeNumber(val.p)
	writeNumber(val.y)
	writeNumber(val.r)
end
decoders['Angle'] = function(val)
	return Angle(readNumber(), readNumber(), readNumber())
end


pon2.encode = function(val)
	cache_size = 0
	output_len = 1
	encoders['table'](val, output, cache)
	local result = table_concat(output)

	for i = 1, output_len do
		output[i] = nil
	end
	for k,v in pairs(cache)do
		cache[k] = nil
	end

	return result
end

pon2.decode = function(val)
	cache_size = 0
	index = 1
	str = val
	strlen = string_len(val)
	obj = decoders['table']()

	for i = 0, cache_size do
		cache[i] = nil
	end

	return obj, index
end

-- compatability layor
/*
do
	require 'pon'
	local pon = pon
	local pcall = pcall
	pon2.decode_l = function(val)
		local succ, res = pcall(pon2.decode, val)
		if succ then return res end
		local succ, res = pcall(pon.decode, val)
		if succ then return res end
		return nil
	end
end
*/