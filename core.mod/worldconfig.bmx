
Strict

Import BRL.LinkedList

Global WorldConfig:TWorldConfig

Const WORLDLIST_ENTITY	= 0
Const WORLDLIST_CAMERA	= 1
Const WORLDLIST_LIGHT	= 2
Const WORLDLIST_PIVOT	= 3
Const WORLDLIST_MESH	= 4
Const WORLDLIST_PLANE	= 5
Const WORLDLIST_TEXTURE	= 6
Const WORLDLIST_BRUSH	= 7
Const WORLDLIST_RENDER	= 8
Const WORLDLIST_ARRAYSIZE = 9

Type TWorldConfig
	Field Width,Height
	Field AmbientRed,AmbientGreen,AmbientBlue
	Field Wireframe
	
	Field List:TList[WORLDLIST_ARRAYSIZE]
	
	Method New()
		For Local i=0 To WORLDLIST_ARRAYSIZE-1
			List[i]=CreateList()
		Next
	End Method
	
	Method AddObject:TLink(obj:Object,index)	
		Return List[index].AddLast(obj)
	End Method
End Type
