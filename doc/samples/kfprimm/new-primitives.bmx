
Strict

Import MaxB3D.Drivers
Import MaxB3D.Loaders

Graphics 800,600

Local light:TLight = CreateLight()

Local camera:TCamera = CreateCamera()
SetEntityPosition camera,0,0,-3

Global primitives:TMesh[3]

primitives[0] = CreateBunny()
SetEntityName primitives[0], "Stanford Bunny"
SetEntityScale primitives[0], 2,2,2

primitives[1] = CreateMonkeyHead()
SetEntityName primitives[1], "Suzanne (Blender Monkey)"

primitives[2] = CreateTeapot()
SetEntityName primitives[2], "Utah Teapot"

Local current

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	For Local i = 0 to 9
		If KeyHit(KEY_0 + i)
			current = i
			Exit
		EndIf
	Next
	
	If KeyHit(KEY_UP) Or KeyHit(KEY_LEFT) current :- 1
	If KeyHit(KEY_DOWN) Or KeyHit(KEY_RIGHT) current :+ 1
	
	If current > primitives.length -1 current = 0
	If current < 0 current = primitives.length - 1 
	
	For Local i = 0 To primitives.length-1 
		SetEntityVisible primitives[i], current = i
	Next
	
	TurnEntity primitives[current],0,1,0
	
	SetWireFrame KeyDown(KEY_W)
	
	RenderWorld
	DoMax2D
	DrawText "Press 1, 2, or 3 to select a particular meshes.",0,0
	DrawText "Press Up/Left or Down/Right to cycle through meshes.",0,15
	DrawText "Current mesh: "+GetEntityName(primitives[current]),0,30
	
	Flip
Wend

