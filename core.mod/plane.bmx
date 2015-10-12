
Strict

Import "entity.bmx"

Type TInfinitePlane Extends TEntity 
	Method Lists[]()
		Return [WORLDLIST_PLANE, WORLDLIST_RENDER]
	End Method
	
	Method Copy:TInfinitePlane(parent:TEntity=Null)
		Return TInfinitePlane(Super.Copy_(parent))
	End Method
	
	Method GetCullRadius#()
		If _cullradius<0 Return Abs(_cullradius)
		Local sx#,sy#,sz#
		GetScale sx,sy,sz,True
		Local radius#=Max(sx,Max(sy,sz))/2.0
		Local radius_sqr#=radius*radius
		Return Sqr(radius_sqr+radius_sqr+radius_sqr) 
	End Method
End Type
