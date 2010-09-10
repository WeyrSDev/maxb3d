
Strict

Module MaxB3D.Primitives
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: LGPL"

Import MaxB3D.Core

Function CreateCube:TMesh(parent:TEntity=Null)
	Return _currentworld.AddMesh("*cube*",parent)
End Function
Function CreateCone:TMesh(segments=8,solid=True,parent:TEntity=Null)
	Return _currentworld.AddMesh("*cone*("+segments+","+solid+")",parent)
End Function
Function CreateCylinder:TMesh(segments=8,solid=True,parent:TEntity=Null)
	Return _currentworld.AddMesh("*cylinder*("+segments+","+solid+")",parent)
End Function
Function CreateSphere:TMesh(segments=8,parent:TEntity=Null)
	Return _currentworld.AddMesh("*sphere*("+segments+")",parent)
End Function

Type TMeshLoaderPrimitives Extends TMeshLoader
	Method Run(url:Object,mesh:TMesh)
		Local str$=String(url)
		Local params$[]=str[str.Find("(")+1..str.FindLast(")")].Split(",")
		
		Select str[str.Find("*")+1..str.FindLast("*")]
		Case "sphere"
			Local segments=Int(params[0])
			If segments<2 Or segments>100 Then Return Null
			
			'Vertex count
			'((segments*2)*4) '2
			'((segments*2)*6)+((segments*2)*((segments-2)*4)) '>2
			
			'Triangle count
			'(segments*2)*2
			'(segments*2)*2+(segments*2)*(segments-2)*2

			Local vertexcount=4*segments*(3+((segments-2)*2))
			Local trianglecount=segments*4*(1+(segments-2))
			If segments=2
				vertexcount=segments*8
				trianglecount=segments*4
			EndIf
			
			Local surface:TSurface=mesh.AddSurface(vertexcount,trianglecount)
			
			Local div#=Float(360.0/(segments*2))
			Local height#=1.0
			Local upos#=1.0
			Local udiv#=Float(1.0/(segments*2))
			Local vdiv#=Float(1.0/segments)
			Local RotAngle#=90	
			
			If segments=2
				For Local i=1 To (segments*2)
					Local np=surface.AddVertex(0.0,height,0.0,upos#-(udiv#/2.0),0)'northpole
					Local sp=surface.AddVertex(0.0,-height,0.0,upos#-(udiv#/2.0),1)'southpole
					Local XPos#=-Cos(RotAngle#)
					Local ZPos#=Sin(RotAngle#)
					Local v0=surface.AddVertex(XPos#,0,ZPos#,upos#,0.5)
					RotAngle#=RotAngle#+div#
					If RotAngle#>=360.0 Then RotAngle#=RotAngle#-360.0
					XPos#=-Cos(RotAngle#)
					ZPos#=Sin(RotAngle#)
					upos#=upos#-udiv#
					Local v1=surface.AddVertex(XPos#,0,ZPos#,upos#,0.5)
					surface.AddTriangle(v1,v0,np)
					surface.AddTriangle(sp,v0,v1)	
				Next	
			Else
				For Local i=1 To (segments*2)	
					Local np=surface.AddVertex(0.0,height,0.0,upos#-(udiv#/2.0),0)'northpole
					Local sp=surface.AddVertex(0.0,-height,0.0,upos#-(udiv#/2.0),1)'southpole
					
					Local YPos#=Cos(div#)
					
					Local XPos#=-Cos(RotAngle#)*(Sin(div#))
					Local ZPos#=Sin(RotAngle#)*(Sin(div#))
					
					Local v0t=surface.AddVertex(XPos#,YPos#,ZPos#,upos#,vdiv#)
					Local v0b=surface.AddVertex(XPos#,-YPos#,ZPos#,upos#,1-vdiv#)
					
					RotAngle#=RotAngle#+div#
					
					XPos#=-Cos(RotAngle#)*(Sin(div#))
					ZPos#=Sin(RotAngle#)*(Sin(div#))
					
					upos#=upos#-udiv#
			
					Local v1t=surface.AddVertex(XPos#,YPos#,ZPos#,upos#,vdiv#)
					Local v1b=surface.AddVertex(XPos#,-YPos#,ZPos#,upos#,1-vdiv#)
					
					surface.AddTriangle(v1t,v0t,np)
					surface.AddTriangle(sp,v0b,v1b)
					
				Next
			
				upos#=1.0
				RotAngle#=90
				For Local i=1 To (segments*2)
				
					Local mult#=1
					Local YPos#=Cos(div#*(mult#))
					Local YPos2#=Cos(div#*(mult#+1.0))
					Local Thisvdiv#=vdiv#
					For Local j=1 To (segments-2)			
						Local XPos#=-Cos(RotAngle#)*(Sin(div#*(mult#)))
						Local ZPos#=Sin(RotAngle#)*(Sin(div#*(mult#)))
			
						Local XPos2#=-Cos(RotAngle#)*(Sin(div#*(mult#+1.0)))
						Local ZPos2#=Sin(RotAngle#)*(Sin(div#*(mult#+1.0)))
									
						Local v0t=surface.AddVertex(XPos#,YPos#,ZPos#,upos#,Thisvdiv#)
						Local v0b=surface.AddVertex(XPos2#,YPos2#,ZPos2#,upos#,Thisvdiv#+vdiv#)
					
						surface.SetTexCoord(v0t,upos#,Thisvdiv#,0.0)
						surface.SetTexCoord(v0b,upos#,Thisvdiv#+vdiv#,0.0)
					
						Local tempRotAngle#=RotAngle#+div#
					
						XPos#=-Cos(tempRotAngle#)*(Sin(div#*(mult#)))
						ZPos#=Sin(tempRotAngle#)*(Sin(div#*(mult#)))
						
						XPos2#=-Cos(tempRotAngle#)*(Sin(div#*(mult#+1.0)))
						ZPos2#=Sin(tempRotAngle#)*(Sin(div#*(mult#+1.0)))				
					
						Local temp_upos#=upos-udiv
			
						Local v1t=surface.AddVertex(XPos,YPos,ZPos,temp_upos,Thisvdiv)
						Local v1b=surface.AddVertex(XPos2,YPos2,ZPos2,temp_upos,Thisvdiv+vdiv)
						
						surface.SetTexCoord(v1t,temp_upos,Thisvdiv,0.0)
						surface.SetTexCoord(v1b,temp_upos,Thisvdiv+vdiv,0.0)
						
						surface.AddTriangle(v0b,v0t,v1t)
						surface.AddTriangle(v0b,v1t,v1b)
						
						Thisvdiv#=Thisvdiv#+vdiv#			
						mult#=mult#+1
						YPos#=Cos(div#*(mult#))
						YPos2#=Cos(div#*(mult#+1.0))
					
					Next
					upos#=upos#-udiv#
					RotAngle#=RotAngle#+div#
				Next
			EndIf			
			
			mesh.UpdateNormals() 
			'mesh.ForEachSurfaceDo FlipNormals
			Return True 
		Case "cylinder"
			Local ringsegments=0
			
			Local segments=Int(params[0]),solid=Int(params[1])
				
			Local tr,tl,br,bl
			Local ts0,ts1,newts
			Local bs0,bs1,newbs
			If segments<3 Or segments>100 Then Return Null
			If ringsegments<0 Or ringsegments>100 Then Return Null
			
			Local surface:TSurface=mesh.AddSurface(1000,1000)
			Local solidsurface:TSurface
			If solid=True
				solidsurface=mesh.AddSurface(1000,1000)
			EndIf
			Local div#=Float(360.0/(segments))
			
			Local height#=1.0
			Local ringSegmentHeight#=(height#*2.0)/(ringsegments+1)
			Local upos#=1.0
			Local udiv#=Float(1.0/(segments))
			Local vpos#=1.0
			Local vdiv#=Float(1.0/(ringsegments+1))
			
			Local SideRotAngle#=90
			
			Local tRing[segments+1]
			Local bRing[segments+1]
			
			If solid=True
				Local xpos#=-Cos(SideRotAngle#)
				Local zpos#=Sin(SideRotAngle#)
			
				ts0=solidsurface.AddVertex(xpos,height,zpos,xpos/2.0+0.5,zpos/2.0+0.5)
				bs0=solidsurface.AddVertex(xpos,-height,zpos,xpos/2.0+0.5,zpos/2.0+0.5)
				
				solidsurface.SetTexCoord(ts0,xpos/2.0+0.5,zpos/2.0+0.5,0.0)
				solidsurface.SetTexCoord(bs0,xpos/2.0+0.5,zpos/2.0+0.5,0.0)
			
				SideRotAngle=SideRotAngle+div
			
				xpos#=-Cos(SideRotAngle#)
				zpos#=Sin(SideRotAngle#)
				
				ts1=solidsurface.AddVertex(xpos#,height,zpos#,xpos#/2.0+0.5,zpos#/2.0+0.5)
				bs1=solidsurface.AddVertex(xpos#,-height,zpos#,xpos#/2.0+0.5,zpos#/2.0+0.5)
			
				solidsurface.SetTexCoord(ts1,xpos#/2.0+0.5,zpos#/2.0+0.5,0.0)
				solidsurface.SetTexCoord(bs1,xpos#/2.0+0.5,zpos#/2.0+0.5,0.0)
				
				For Local i=1 To (segments-2)
					SideRotAngle#=SideRotAngle#+div#
			
					xpos#=-Cos(SideRotAngle#)
					zpos#=Sin(SideRotAngle#)
					
					newts=solidsurface.AddVertex(xpos#,height,zpos#,xpos#/2.0+0.5,zpos#/2.0+0.5)
					newbs=solidsurface.AddVertex(xpos#,-height,zpos#,xpos#/2.0+0.5,zpos#/2.0+0.5)
					
					solidsurface.SetTexCoord(newts,xpos#/2.0+0.5,zpos#/2.0+0.5,0.0)
					solidsurface.SetTexCoord(newbs,xpos#/2.0+0.5,zpos#/2.0+0.5,0.0)
					
					solidsurface.AddTriangle(newts,ts1,ts0)
					solidsurface.AddTriangle(bs0,bs1,newbs)
				
					If i<(segments-2)
						ts1=newts
						bs1=newbs
					EndIf
				Next
			EndIf
			
			Local thisHeight#=height#
			
			SideRotAngle#=90
			Local xpos#=-Cos(SideRotAngle#)
			Local zpos#=Sin(SideRotAngle#)
			Local thisUPos#=upos#
			Local thisVPos#=0
			tRing[0]=surface.AddVertex(xpos#,thisHeight,zpos#,thisUPos#,thisVPos#)		
			surface.SetTexCoord(tRing[0],thisUPos#,thisVPos#,0.0)
			For Local i=0 To (segments-1)
				SideRotAngle#=SideRotAngle#+div#
				xpos#=-Cos(SideRotAngle#)
				zpos#=Sin(SideRotAngle#)
				thisUPos#=thisUPos#-udiv#
				tRing[i+1]=surface.AddVertex(xpos#,thisHeight,zpos#,thisUPos#,thisVPos#)
				surface.SetTexCoord(tRing[i+1],thisUPos#,thisVPos#,0.0)
			Next	
			
			For Local ring=0 To ringsegments
				Local thisHeight=thisHeight-ringSegmentHeight#
				
				SideRotAngle#=90
				xpos#=-Cos(SideRotAngle#)
				zpos#=Sin(SideRotAngle#)
				thisUPos#=upos#
				thisVPos#=thisVPos#+vdiv#
				bRing[0]=surface.AddVertex(xpos#,thisHeight,zpos#,thisUPos#,thisVPos#)
				surface.SetTexCoord(bRing[0],thisUPos#,thisVPos#,0.0)
				For Local i=0 To (segments-1)
					SideRotAngle#=SideRotAngle#+div#
					xpos#=-Cos(SideRotAngle#)
					zpos#=Sin(SideRotAngle#)
					thisUPos#=thisUPos#-udiv#
					bRing[i+1]=surface.AddVertex(xpos#,thisHeight,zpos#,thisUPos#,thisVPos#)
					surface.SetTexCoord(bRing[i+1],thisUPos#,thisVPos#,0.0)
				Next
				
				For Local v=1 To (segments)
					tl=tRing[v]
					tr=tRing[v-1]
					bl=bRing[v]
					br=bRing[v-1]
					
					surface.AddTriangle(br,tr,tl)
					surface.AddTriangle(br,tl,bl)
				Next
				
				For Local v=0 To (segments)
					tRing[v]=bRing[v]
				Next		
			Next
					
			mesh.UpdateNormals()
			Return True
		Case "cone"
			Local segments=Int(params[0]),solid=Int(params[1])
			
			Local top,br,bl
			Local bs0,bs1,newbs
			
			If segments<3 Or segments>100 Then Return Null
			
			Local surface:TSurface=mesh.AddSurface(1000,1000)
			Local bottomsurface:TSurface
			If solid bottomsurface=mesh.AddSurface(1000,100)
			
			Local div#=Float(360.0/(segments))
		
			Local height#=1.0
			Local upos#=1.0
			Local udiv#=Float(1.0/(segments))
			Local angle#=90	
		
			Local xpos#=-Cos(angle)
			Local zpos#=Sin(angle)
		
			top=surface.AddVertex(0.0,height,0.0,upos-(udiv/2.0),0)
			br=surface.AddVertex(xpos,-height,zpos,upos,1)
			
			surface.SetTexCoord(top,upos-(udiv/2.0),0,0.0)
			surface.SetTexCoord(br,upos,1,0.0)
		
			If solid=True Then bs0=bottomsurface.AddVertex(xpos,-height,zpos,xpos/2.0+0.5,zpos/2.0+0.5)
			If solid=True Then bottomsurface.SetTexCoord(bs0,xpos/2.0+0.5,zpos/2.0+0.5,0.0)
		
			angle=angle+div
		
			xpos=-Cos(angle)
			zpos=Sin(angle)
						
			bl=surface.AddVertex(xpos,-height,zpos,upos#-udiv#,1)
			surface.SetTexCoord(bl,upos-udiv,1,0.0)
		
			If solid=True Then bs1=bottomsurface.AddVertex(xpos,-height,zpos,xpos/2.0+0.5,zpos/2.0+0.5)
			If solid=True Then bottomsurface.SetTexCoord(bs1,xpos/2.0+0.5,zpos/2.0+0.5,0.0)
			
			surface.AddTriangle(br,top,bl)
		
			For Local i=1 To segments-1
				br=bl
				upos#=upos-udiv
				top=surface.AddVertex(0.0,height,0.0,upos#-(udiv#/2.0),0)
				surface.SetTexCoord(top,upos#-(udiv#/2.0),0,0.0)
			
				angle=angle+div
		
				xpos=-Cos(angle)
				zpos=Sin(angle)
				
				bl=surface.AddVertex(xpos,-height,zpos,upos-udiv,1)
				surface.SetTexCoord(bl,upos-udiv,1,0.0)
		
				If solid=True Then newbs=bottomsurface.AddVertex(xpos,-height,zpos,xpos/2.0+0.5,zpos/2.0+0.5)
				If solid=True Then bottomsurface.SetTexCoord(newbs,xpos/2.0+0.5,zpos/2.0+0.5,0.0)
			
				surface.AddTriangle(br,top,bl)
				
				If solid=True
					bottomsurface.AddTriangle(bs0,bs1,newbs)				
					If i<(segments-1) bs1=newbs
				EndIf
			Next		
			
			mesh.UpdateNormals()
			Return True
		Case "cube"
			Local surface:TSurface=mesh.AddSurface(24,12)

			For Local i=0 To 3
				surface.SetNormal(i,0,1,0)
			Next
			surface.SetCoord( 0, 1.0, 1.0,-1.0);surface.SetTexCoord( 0, 0.0, 0.0)
			surface.SetCoord( 1,-1.0, 1.0,-1.0);surface.SetTexCoord( 1, 0.0, 1.0)
			surface.SetCoord( 2,-1.0, 1.0, 1.0);surface.SetTexCoord( 2, 1.0, 1.0)
			surface.SetCoord( 3, 1.0, 1.0, 1.0);surface.SetTexCoord( 3, 1.0, 0.0)
			surface.SetTriangle( 0, 2, 1, 0)
			surface.SetTriangle( 1, 2, 0, 3)			
			
			For Local i=4 To 7
				surface.SetNormal(i,0,-1,0)
			Next
			surface.SetCoord( 4, 1.0,-1.0, 1.0);surface.SetTexCoord( 4, 0.0, 0.0)
			surface.SetCoord( 5,-1.0,-1.0, 1.0);surface.SetTexCoord( 5, 0.0, 1.0)
			surface.SetCoord( 6,-1.0,-1.0,-1.0);surface.SetTexCoord( 6, 1.0, 1.0)
			surface.SetCoord( 7, 1.0,-1.0,-1.0);surface.SetTexCoord( 7, 1.0, 0.0)
			surface.SetTriangle( 2, 6, 5, 4)
			surface.SetTriangle( 3, 6, 4, 7)	
			
			For Local i=8 To 11
				surface.SetNormal(i,0,0,1)
			Next
			surface.SetCoord( 8, 1.0, 1.0, 1.0);surface.SetTexCoord( 8, 1.0, 0.0)
			surface.SetCoord( 9,-1.0, 1.0, 1.0);surface.SetTexCoord( 9, 0.0, 0.0)
			surface.SetCoord(10,-1.0,-1.0, 1.0);surface.SetTexCoord(10, 0.0, 1.0)
			surface.SetCoord(11, 1.0,-1.0, 1.0);surface.SetTexCoord(11, 1.0, 1.0)
			surface.SetTriangle( 4,10, 9, 8)
			surface.SetTriangle( 5,10, 8,11)	
	
			For Local i=12 To 15
				surface.SetNormal(i,0,0,-1)
			Next
			surface.SetCoord(12, 1.0,-1.0,-1.0);surface.SetTexCoord(12, 0.0, 1.0)
			surface.SetCoord(13,-1.0,-1.0,-1.0);surface.SetTexCoord(13, 1.0, 1.0)
			surface.SetCoord(14,-1.0, 1.0,-1.0);surface.SetTexCoord(14, 1.0, 0.0)
			surface.SetCoord(15, 1.0, 1.0,-1.0);surface.SetTexCoord(15, 0.0, 0.0)
			surface.SetTriangle( 6,14,13,12)
			surface.SetTriangle( 7,14,12,15)	
			
			For Local i=16 To 19
				surface.SetNormal(i,-1,0,0)
			Next
			surface.SetCoord(16,-1.0, 1.0, 1.0);surface.SetTexCoord(16, 1.0, 0.0)
			surface.SetCoord(17,-1.0, 1.0,-1.0);surface.SetTexCoord(17, 0.0, 0.0)
			surface.SetCoord(18,-1.0,-1.0,-1.0);surface.SetTexCoord(18, 0.0, 1.0)
			surface.SetCoord(19,-1.0,-1.0, 1.0);surface.SetTexCoord(19, 1.0, 1.0)
			surface.SetTriangle( 8,18,17,16)
			surface.SetTriangle( 9,18,16,19)	
			
			For Local i=20 To 23
				surface.SetNormal(i,1,0,0)
			Next
			surface.SetCoord(20, 1.0, 1.0,-1.0);surface.SetTexCoord(20, 1.0, 0.0)
			surface.SetCoord(21, 1.0, 1.0, 1.0);surface.SetTexCoord(21, 0.0, 0.0)
			surface.SetCoord(22, 1.0,-1.0, 1.0);surface.SetTexCoord(22, 0.0, 1.0)
			surface.SetCoord(23, 1.0,-1.0,-1.0);surface.SetTexCoord(23, 1.0, 1.0)
			surface.SetTriangle(10,22,21,20)
			surface.SetTriangle(11,22,20,23)	
			Return True
		Default
			Return False
		End Select
	End Method
	
	Function FlipNormals(surface:TSurface)
		For Local v=0 To surface._vertexcnt-1
			Local nx#,ny#,nz#
			surface.GetNormal(v,nx,ny,nz)
			surface.SetNormal(v,-nx,-ny,-nz)
		Next
	End Function	
End Type

New TMeshLoaderPrimitives