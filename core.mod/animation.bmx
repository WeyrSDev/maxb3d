
Strict

Import "surface.bmx"

Const ANIMATION_STOP     = 0
Const ANIMATION_LOOP     = 1
Const ANIMATION_PINGPONG = 2
Const ANIMATION_SINGLE   = 3 

Type TAnimKey
	Field _frame
	Field _object:Object
End Type

Type TAnimSeq
	Field _start,_end,_name$
	
	Function Create:TAnimSeq(first,last,name$="")
		Local seq:TAnimSeq=New TAnimSeq
		seq._start=first
		seq._end=last
		seq._name=name
		Return seq
	End Function
	
	Method GetName$()
		Return _name
	End Method
	Method SetName(name$)
		_name=name
	End Method
	
	Method GetLength()
		Return _end-_start
	End Method
End Type

Type TAnimator
	Field _frame#,_lastframe#,_speed#=1.0,_mode
	Field _seq:TAnimSeq[],_current:TAnimSeq=New TAnimSeq

	Method GetSurface:TSurface(surface:TSurface) Abstract
	Method GetMergeData() Abstract
	Method Update() Abstract
	Method GetFrameCount() Abstract
	Method SetKey(frame,key:Object) Abstract
	
	Method InterpolateSurfaces:TSurface(surface0:TSurface,surface1:TSurface,diff#,output:TSurface)
		For Local v=0 To output._vertexcnt-1
			Local x1#,y1#,z1#,x2#,y2#,z2#
			surface0.GetCoords v,x1,y1,z1
			surface1.GetCoords v,x2,y2,z2
			output.SetCoords v,x1+(x2-x1)*diff,y1+(y2-y1)*diff,z1+(z2-z1)*diff			
		Next
		Return output
	End Method
End Type