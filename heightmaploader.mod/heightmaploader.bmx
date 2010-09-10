
Strict

Module MaxB3D.HeightmapLoader
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: LGPL"

Import MaxB3D.Core

Type TMeshLoaderHMAP Extends TMeshLoader
	Method Run(url:Object,mesh:TMesh)
		Local pixmap:TPixmap=TPixmap(url)
		If pixmap=Null pixmap=LoadPixmap(url)
		If pixmap=Null Return False
		
		pixmap=ConvertPixmap(pixmap,PF_I8)
		Local width=PixmapWidth(pixmap),height=PixmapHeight(pixmap)
		
		Local surface:TSurface=mesh.AddSurface(height*width,height*width*2)		
		
		Local stx#=-1,sty#=stx,y#=sty
		For Local a=0 To height-1
			Local x#=stx,v#=a/Float(height)
			For Local b=0 To width-1
				Local u#=b/Float(width)
				Local vert=surface.AddVertex(x,pixmap.pixels[a*height+b]/255.0,y,u,v)
				surface.SetColor vert,255,255,255,0
				x:+2.0/width
			Next
			y:+2.0/height
		Next
		
		For Local a=0 To height-2
			For Local b=0 To width-2
				Local v0=a*height+b,v1=v0+1
				Local v2=(a+1)*height+(b+1),v3=v2-1
				surface.AddTriangle( v1,v2,v0 )
				surface.AddTriangle( v2,v3,v0 )
			Next
		Next
		
		mesh.UpdateNormals()
		
		Return True
	End Method
End Type
New TMeshLoaderHMAP