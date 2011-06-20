
Strict

Import "entity.bmx"
Import "worldconfig.bmx"

Const CAMMODE_NONE	= 0
Const CAMMODE_PERSP	= 1
Const CAMMODE_ORTHO	= 2

Const CLSMODE_COLOR	= 1
Const CLSMODE_DEPTH	= 2

Const FOGMODE_NONE		= 0
Const FOGMODE_LINEAR	= 1

Type TCamera Extends TEntity
	Field _projmode
	Field _fogmode,_fogr#,_fogg#,_fogb#,_fognear#,_fogfar#
	Field _viewx,_viewy,_viewwidth,_viewheight
	Field _clsmode,_near#,_far#
	Field _zoom#
	
	Field _lastmodelview:TMatrix=New TMatrix
	Field _lastprojection:TMatrix=New TMatrix
	Field _lastviewport[4]
	Field _lastfrustum:TFrustum
	
	Method New()
		SetMode CAMMODE_PERSP
		SetFogMode FOGMODE_NONE
		SetFogRange 1,1000
		SetViewport 0,0,WorldConfig.Width,WorldConfig.Height
		SetClsMode CLSMODE_COLOR|CLSMODE_DEPTH
		SetColor 0,0,0
		SetRange 1,1000
		SetZoom 1.0
	End Method
	
	Method Copy:TCamera(parent:TEntity=Null)
		Local camera:TCamera=New TCamera
		camera.SetMode _projmode
		camera.SetFogMode _fogmode
		camera.SetFogColor _fogr*255.0,_fogg*255.0,_fogb*255.0
		camera.SetFogRange _fognear,_fogfar
		camera.SetViewport _viewx,_viewy,_viewwidth,_viewheight
		camera.SetClsMode _clsmode
		camera.SetRange _near,_far
		camera.SetZoom _zoom
		Return camera
	End Method
	
	Method GetMode()
		Return _projmode
	End Method
	Method SetMode(mode)
		_projmode=mode
	End Method	
	
	Method GetFogMode()
		Return _fogmode
	End Method
	Method SetFogMode(mode)
		_fogmode=mode
	End Method
	
	Method GetFogColor(red Var,green Var,blue Var)
		red=_fogr*255.0;green=_fogg*255.0;blue=_fogb*255.0
	End Method
	Method SetFogColor(red,green,blue)
		_fogr=red/255.0;_fogg=green/255.0;_fogb=blue/255.0
	End Method
	
	Method GetFogRange(near# Var,far# Var)
		near=_fognear;far=_fogfar
	End Method
	Method SetFogRange(near#,far#)
		_fognear=near;_fogfar=far
	End Method
	
	Method GetViewport(x Var,y Var,width Var,height Var)
		x=_viewx;y=_viewy;width=_viewwidth;height=_viewheight
	End Method
	Method SetViewport(x,y,width,height)
		_viewx=x;_viewy=y;_viewwidth=width;_viewheight=height
	End Method
	
	Method GetClsMode()
		Return _clsmode
	End Method
	Method SetClsMode(mode)
		_clsmode=mode
	End Method
	
	Method GetRange(near# Var,far# Var)
		near=_near;far=_far
	End Method
	Method SetRange(near#,far#)
		_near=near;_far=far
	End Method	
	
	Method GetZoom#()
		Return _zoom
	End Method
	Method SetZoom(zoom#)
		_zoom=zoom
	End Method
	
	Method Project(target:Object,x# Var,y# Var)
		Local z#
		TEntity.GetTargetPosition target,x,y,z
		
		Local w#=1.0
	   _lastmodelview.TransformVector x,y,z,w
	   _lastprojection.TransformVector x,y,z,w
	   If w=0 Return False
	   x:/w;y:/w;z:/w
	    
	   x=x*0.5+0.5;y=-y*0.5+0.5;z=z*0.5+0.5;
	
	   x=x*_lastviewport[2]+_lastviewport[0]
	   y=y*_lastviewport[3]+_lastviewport[1]
		Return True
	End Method
	
	Method InView#(target:Object)
		Local x#,y#,z#,radius#
		Local entity:TEntity=TEntity(target),point#[]=Float[](target)
		If entity
			entity.GetCullParams x,y,z,radius
		Else
			x=point[0];y=point[1];z=point[2];radius=point[3]
		EndIf
		Return _lastfrustum.IntersectsPoint(x,y,z,radius)
	End Method
End Type
