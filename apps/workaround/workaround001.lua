-- 修正点阵配列错误
return function(hex)
	return bit.band(bit.bor(bit.rshift(hex,1),bit.lshift(hex,7)),0xFF)
end
