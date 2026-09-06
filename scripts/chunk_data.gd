extends RefCounted
class_name WorldChunkData

## Dictionnary where the first key is the index, and the second key is the block in the palette
var blocks: Dictionary[int, int]
var palette: Dictionary[int, String]
var block_entities
var entities
