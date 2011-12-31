
Strict

Rem
	bbdoc: MD2 model loader for MaxB3D
End Rem
Module MaxB3D.MD2Loader
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import MaxB3D.Core
Import MaxB3D.VertexAnimator
Import BRL.EndianStream

Private
Global md2_anorms#[][]= [[ -0.525731,  0.000000,  0.850651 ],[ -0.442863,  0.238856,  0.864188 ],[ -0.295242,  0.000000,  0.955423 ], [ -0.309017,  0.500000,  0.809017 ], [ -0.162460,  0.262866,  0.951056 ], [  0.000000,  0.000000,  1.000000 ], [  0.000000,  0.850651,  0.525731 ], [ -0.147621,  0.716567,  0.681718 ], [  0.147621,  0.716567,  0.681718 ], [  0.000000,  0.525731,  0.850651 ], [  0.309017,  0.500000,  0.809017 ], [  0.525731,  0.000000,  0.850651 ], [  0.295242,  0.000000,  0.955423 ], [  0.442863,  0.238856,  0.864188 ], [  0.162460,  0.262866,  0.951056 ], [ -0.681718,  0.147621,  0.716567 ], [ -0.809017,  0.309017,  0.500000 ], [ -0.587785,  0.425325,  0.688191 ], [ -0.850651,  0.525731,  0.000000 ], [ -0.864188,  0.442863,  0.238856 ], [ -0.716567,  0.681718,  0.147621 ], [ -0.688191,  0.587785,  0.425325 ], [ -0.500000,  0.809017,  0.309017 ], [ -0.238856,  0.864188,  0.442863 ], [ -0.425325,  0.688191,  0.587785 ], [ -0.716567,  0.681718, -0.147621 ], [ -0.500000,  0.809017, -0.309017 ], [ -0.525731,  0.850651,  0.000000 ], [  0.000000,  0.850651, -0.525731 ], [ -0.238856,  0.864188, -0.442863 ], [  0.000000,  0.955423, -0.295242 ], [ -0.262866,  0.951056, -0.162460 ], [  0.000000,  1.000000,  0.000000 ], [  0.000000,  0.955423,  0.295242 ], [ -0.262866,  0.951056,  0.162460 ], [  0.238856,  0.864188,  0.442863 ], [  0.262866,  0.951056,  0.162460 ], [  0.500000,  0.809017,  0.309017 ], [  0.238856,  0.864188, -0.442863 ], [  0.262866,  0.951056, -0.162460 ], [  0.500000,  0.809017, -0.309017 ], [  0.850651,  0.525731,  0.000000 ], [  0.716567,  0.681718,  0.147621 ], [  0.716567,  0.681718, -0.147621 ], [  0.525731,  0.850651,  0.000000 ], [  0.425325,  0.688191,  0.587785 ], [  0.864188,  0.442863,  0.238856 ], [  0.688191,  0.587785,  0.425325 ], [  0.809017,  0.309017,  0.500000 ], [  0.681718,  0.147621,  0.716567 ], [  0.587785,  0.425325,  0.688191 ], [  0.955423,  0.295242,  0.000000 ], [  1.000000,  0.000000,  0.000000 ], [  0.951056,  0.162460,  0.262866 ], [  0.850651, -0.525731,  0.000000 ], [  0.955423, -0.295242,  0.000000 ], [  0.864188, -0.442863,  0.238856 ], [  0.951056, -0.162460,  0.262866 ], [  0.809017, -0.309017,  0.500000 ], [  0.681718, -0.147621,  0.716567 ], [  0.850651,  0.000000,  0.525731 ], [  0.864188,  0.442863, -0.238856 ], [  0.809017,  0.309017, -0.500000 ], [  0.951056,  0.162460, -0.262866 ], [  0.525731,  0.000000, -0.850651 ], [  0.681718,  0.147621, -0.716567 ], [  0.681718, -0.147621, -0.716567 ], [  0.850651,  0.000000, -0.525731 ], [  0.809017, -0.309017, -0.500000 ], [  0.864188, -0.442863, -0.238856 ], [  0.951056, -0.162460, -0.262866 ], [  0.147621,  0.716567, -0.681718 ], [  0.309017,  0.500000, -0.809017 ], [  0.425325,  0.688191, -0.587785 ], [  0.442863,  0.238856, -0.864188 ], [  0.587785,  0.425325, -0.688191 ], [  0.688191,  0.587785, -0.425325 ], [ -0.147621,  0.716567, -0.681718 ], [ -0.309017,  0.500000, -0.809017 ], [  0.000000,  0.525731, -0.850651 ], [ -0.525731,  0.000000, -0.850651 ], [ -0.442863,  0.238856, -0.864188 ], [ -0.295242,  0.000000, -0.955423 ], [ -0.162460,  0.262866, -0.951056 ], [  0.000000,  0.000000, -1.000000 ], [  0.295242,  0.000000, -0.955423 ], [  0.162460,  0.262866, -0.951056 ], [ -0.442863, -0.238856, -0.864188 ], [ -0.309017, -0.500000, -0.809017 ], [ -0.162460, -0.262866, -0.951056 ], [  0.000000, -0.850651, -0.525731 ], [ -0.147621, -0.716567, -0.681718 ], [  0.147621, -0.716567, -0.681718 ], [  0.000000, -0.525731, -0.850651 ], [  0.309017, -0.500000, -0.809017 ], [  0.442863, -0.238856, -0.864188 ], [  0.162460, -0.262866, -0.951056 ], [  0.238856, -0.864188, -0.442863 ], [  0.500000, -0.809017, -0.309017 ], [  0.425325, -0.688191, -0.587785 ], [  0.716567, -0.681718, -0.147621 ], [  0.688191, -0.587785, -0.425325 ], [  0.587785, -0.425325, -0.688191 ], [  0.000000, -0.955423, -0.295242 ], [  0.000000, -1.000000,  0.000000 ], [  0.262866, -0.951056, -0.162460 ], [  0.000000, -0.850651,  0.525731 ], [  0.000000, -0.955423,  0.295242 ], [  0.238856, -0.864188,  0.442863 ], [  0.262866, -0.951056,  0.162460 ], [  0.500000, -0.809017,  0.309017 ], [  0.716567, -0.681718,  0.147621 ], [  0.525731, -0.850651,  0.000000 ], [ -0.238856, -0.864188, -0.442863 ], [ -0.500000, -0.809017, -0.309017 ], [ -0.262866, -0.951056, -0.162460 ], [ -0.850651, -0.525731,  0.000000 ], [ -0.716567, -0.681718, -0.147621 ], [ -0.716567, -0.681718,  0.147621 ], [ -0.525731, -0.850651,  0.000000 ], [ -0.500000, -0.809017,  0.309017 ], [ -0.238856, -0.864188,  0.442863 ], [ -0.262866, -0.951056,  0.162460 ], [ -0.864188, -0.442863,  0.238856 ], [ -0.809017, -0.309017,  0.500000 ], [ -0.688191, -0.587785,  0.425325 ], [ -0.681718, -0.147621,  0.716567 ], [ -0.442863, -0.238856,  0.864188 ], [ -0.587785, -0.425325,  0.688191 ], [ -0.309017, -0.500000,  0.809017 ], [ -0.147621, -0.716567,  0.681718 ], [ -0.425325, -0.688191,  0.587785 ], [ -0.162460, -0.262866,  0.951056 ], [  0.442863, -0.238856,  0.864188 ], [  0.162460, -0.262866,  0.951056 ], [  0.309017, -0.500000,  0.809017 ], [  0.147621, -0.716567,  0.681718 ], [  0.000000, -0.525731,  0.850651 ], [  0.425325, -0.688191,  0.587785 ], [  0.587785, -0.425325,  0.688191 ], [  0.688191, -0.587785,  0.425325 ], [ -0.955423,  0.295242,  0.000000 ], [ -0.951056,  0.162460,  0.262866 ], [ -1.000000,  0.000000,  0.000000 ], [ -0.850651,  0.000000,  0.525731 ], [ -0.955423, -0.295242,  0.000000 ], [ -0.951056, -0.162460,  0.262866 ], [ -0.864188,  0.442863, -0.238856 ], [ -0.951056,  0.162460, -0.262866 ], [ -0.809017,  0.309017, -0.500000 ], [ -0.864188, -0.442863, -0.238856 ], [ -0.951056, -0.162460, -0.262866 ], [ -0.809017, -0.309017, -0.500000 ], [ -0.681718,  0.147621, -0.716567 ], [ -0.681718, -0.147621, -0.716567 ], [ -0.850651,  0.000000, -0.525731 ], [ -0.688191,  0.587785, -0.425325 ], [ -0.587785,  0.425325, -0.688191 ], [ -0.425325,  0.688191, -0.587785 ], [ -0.425325, -0.688191, -0.587785 ], [ -0.587785, -0.425325, -0.688191 ], [ -0.688191, -0.587785, -0.425325 ]]

Public

Type TMeshLoaderMD2 Extends TMeshLoader
	Method Run(config:TWorldConfig,mesh:TMesh,stream:TStream,url:Object)
		If stream=Null Return False
		stream=LittleEndianStream(stream)
		
		If ReadInt(stream)<>844121161 Return False
		If ReadInt(stream)<>8 Return False
	  
	  Local skinwidth=ReadInt(stream),skinheight=ReadInt(stream)
	
	  Local framesize=ReadInt(stream)
	
	  Local num_skins=ReadInt(stream)
	  Local num_vertices=ReadInt(stream)
	  Local num_st=ReadInt(stream)
	  Local num_tris=ReadInt(stream)
	  Local num_glcmds=ReadInt(stream)
	  Local num_frames=ReadInt(stream)
	
	  Local offset_skins=ReadInt(stream)
	  Local offset_st=ReadInt(stream)
	  Local offset_tris=ReadInt(stream)
	  Local offset_frames=ReadInt(stream)
	  Local offset_glcmds=ReadInt(stream)
	  Local offset_end=ReadInt(stream)
		
		Local skin$[num_skins]
		Local st#[num_st*2]
		Local tri:Short[num_tris*6]
				
		SeekStream stream, offset_skins
		For Local i=0 To num_skins-1
			skin[i]=ReadString(stream,64)
		Next
		
		SeekStream stream, offset_st
		For Local i=0 To num_st-1
			st[(i*2)+0]=ReadShort(stream)/Float(skinwidth)
			st[(i*2)+1]=ReadShort(stream)/Float(skinwidth)
		Next
		
		SeekStream stream, offset_tris
		For Local i=0 To num_tris-1
			tri[(i*6)+0]=ReadShort(stream)
			tri[(i*6)+1]=ReadShort(stream)
			tri[(i*6)+2]=ReadShort(stream)
			tri[(i*6)+3]=ReadShort(stream)
			tri[(i*6)+4]=ReadShort(stream)
			tri[(i*6)+5]=ReadShort(stream)
		Next
		
		Local master_surface:TSurface=New TSurface
		master_surface.Resize(num_vertices,num_tris)
		For Local i=0 To num_tris-1
			Local v0=tri[(i*6)+0],v1=tri[(i*6)+1],v2=tri[(i*6)+2]
			Local tc0=tri[(i*6)+3],tc1=tri[(i*6)+4],tc2=tri[(i*6)+5]
						
			master_surface.SetTriangle i,v2,v1,v0
			master_surface.SetTexCoords v0,1-st[(tc0*2)+0],1-st[(tc0*2)+1]
			master_surface.SetTexCoords v1,1-st[(tc1*2)+0],1-st[(tc1*2)+1]
			master_surface.SetTexCoords v2,1-st[(tc2*2)+0],1-st[(tc2*2)+1]
		Next
				
		SeekStream stream,offset_frames
		
		mesh._animator=New TVertexAnimator		
		For Local i=0 To num_frames-1
			Local sx#=ReadFloat(stream),sy#=ReadFloat(stream),sz#=ReadFloat(stream)
			Local tx#=ReadFloat(stream),ty#=ReadFloat(stream),tz#=ReadFloat(stream)
			Local name$=ReadString(stream,16)
			
			Local surface:TSurface=master_surface.Copy(SURFACE_POS|SURFACE_NML)
			For Local v=0 To num_vertices-1
				Local x#=ReadByte(stream)*sx+tx,y#=ReadByte(stream)*sy+ty,z#=ReadByte(stream)*sz+tz
				Local ni=ReadByte(stream)
				surface.SetCoords v,x,y,z
				surface.SetNormal v,md2_anorms[ni][2],md2_anorms[ni][1],md2_anorms[ni][0]
			Next
			surface.Transform TMatrix.YawPitchRoll(-90,90,0)
			
			If i=0							
				master_surface._vertexpos=surface._vertexpos[..]
				master_surface._vertexnml=surface._vertexnml[..]				
				mesh.AppendSurface master_surface
			EndIf
			
			mesh._animator.SetKey i,surface
		Next
			
		Return True
	End Method

	Method Info$()
		Return "MD2|.md2"
	End Method
	Method ModuleName$()
		Return "md2loader"
	End Method
End Type
New TMeshLoaderMD2

