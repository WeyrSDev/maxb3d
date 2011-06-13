
Strict

Import "bone.bmx"

Type TBoneAnimator Extends TAnimator
	Field _root:TBone
	Field _bone:TBone[]
	Field _key:TAnimKey[][]
	
	Method AddBone(bone:TBone,keys:TAnimKey[])
		_bone:+[bone];_key:+[keys]		
		If _root=Null _root=bone
	End Method
	
	Method GetSurface:TSurface(surface:TSurface)
	End Method
	Method GetMergeData()
	End Method
	Method Update()
		For Local i=0 To _bone.length-1
			Local frame0,frame1
			For Local j=0 To _key[i].length-1
				If _key[i][j]._frame-_frame=0
					frame0=j
					frame1=j
					Exit
				EndIf
				If _key[i][j]._frame<_frame frame0=j
				If _key[i][j]._frame>_frame
					frame1=j
					Exit
				EndIf
			Next
			
			Local key0:TAnimKey=_key[i][frame0]
			Local key1:TAnimKey=_key[i][frame1]
						
			Local matrix:TMatrix
			If key0=key1
				matrix=TMatrix(key0._object)
			Else
				Local t#=key0._frame+(key1._frame-key0._frame)*(_frame-key0._frame)
				matrix=TMatrix(key1._object).Interpolate(TMatrix(key0._object),t)
			EndIf

			_bone[i].Transform matrix
		Next
	End Method
	Method GetFrameCount()
	End Method
	
	Method SetKey(frame,key:Object)
		_root.SetAnimKey frame,key
	End Method
End Type
