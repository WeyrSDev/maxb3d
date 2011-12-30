
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
	
	Method Lists[]()
		Return Super.Lists() + [WORLDLIST_CAMERA]
	End Method

	Method CopyData:TEntity(entity:TEntity)
		Local camera:TCamera = TCamera(entity)
		Local red,green,blue,fognear#,fogfar#,x,y,width,height,near#,far#
		camera.GetFogColor red,green,blue
		camera.GetFogRange fognear,fogfar
		camera.GetViewport x,y,width,height
		camera.GetRange near,far
		
		SetMode camera.GetMode()
		SetFogMode camera.GetFogMode()
		SetFogColor red,green,blue
		SetFogRange fognear,fogfar
		SetViewport x,y,width,height
		SetClsMode camera.GetClsMode()
		SetRange near,far
		SetZoom camera.GetZoom()
		Return Super.CopyData(entity)
	End Method
	
	Method Copy:TCamera(parent:TEntity=Null)
		Return TCamera(Super.Copy_(parent))
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
		_fognear=Max(near,0);_fogfar=Max(far,0.001)
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
	
	Method GetFOV#()
		Return ATan(_zoom / 1.0)
	End Method
	Method SetFOV(angle#)
		_zoom = 1.0 / Tan(angle / 2.0)
	End Method
	
	Method GetEye:TRay()
		Local x#,y#,z#,dx#,dy#,dz#=1.0,o:TVector,d:TVector
		GetPosition x,y,z,True
		_matrix.TransformVec3 dx,dy,dz
		Return New TRay.Create(New TVector.Create3(x,y,z),New TVector.Create3(dx-x,dy-y,dz-x))		
	End Method
	
	Method UpdateMatrices()
		_lastviewport[0]=_viewx
		_lastviewport[1]=_viewy
		_lastviewport[2]=_viewwidth
		_lastviewport[3]=_viewheight
		
		_lastmodelview = _matrix.Inverse()
		
		Local ratio#=(Float(_viewwidth)/_viewheight)
		_lastprojection = TMatrix.PerspectiveFovRH(ATan((1.0/(_zoom*ratio)))*2.0,ratio,_near,_far)		

		_lastfrustum=TFrustum.Extract(_lastmodelview, _lastprojection)
	End Method
	
	Method Project(target:Object,x# Var,y# Var, offset#[] = Null)
		Local z#
		TEntity.GetTargetPosition target,x,y,z
		
		If offset
		  x :+ offset[0]
		  y :+ offset[1]
		  z :+ offset[2]
		EndIf
		
		Local w#=1.0
	   _lastmodelview.TransformVec4 x,y,z,w
	   _lastprojection.TransformVec4 x,y,z,w
	   If w=0 Return False
	   x:/w;y:/w;z:/w
	    
	   x=x*0.5+0.5;y=-y*0.5+0.5;z=z*0.5+0.5;
	
	   x=x*_lastviewport[2]+_lastviewport[0]
	   y=y*_lastviewport[3]+_lastviewport[1]
		Return True
	End Method
	
	Method Unproject(wx#,wy#,wz#,x# Var,y# Var,z# Var)
		Local matrix:TMatrix=_lastprojection.Multiply(_lastmodelview).Inverse()
		
		x=(wx-_lastviewport[0])*2/_lastviewport[2] - 1.0
		y=(wy-_lastviewport[1])*2/_lastviewport[3] - 1.0
		z=2*wz-1.0
		Local w#=1.0
				
		matrix.TransformVec4 x,y,z,w
		If w=0 Return False
		
		x:/w;y:/w;z:/w
		Return True
	End Method
	
	Method InView#(target:Object)
		Local x#,y#,z#,radius#
		Local entity:TEntity=TEntity(target),point#[]=Float[](target)
		If entity
			entity.GetCullParams x,y,z,radius
		ElseIf point
			x=point[0];y=point[1];z=point[2];radius=point[3]
		Else
			Return 0
		EndIf
		Return _lastfrustum.IntersectsPoint(x,y,z,radius)
	End Method
End Type
