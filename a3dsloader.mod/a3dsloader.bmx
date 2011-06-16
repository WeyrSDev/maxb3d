
Strict

Rem
	bbdoc: Autodesk 3DS loader for MaxB3D
End Rem
Module MaxB3D.A3DSLoader

ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"
ModuleInfo "Credit: Utilizes lib3ds."

Import MaxB3D.Core
Import sys87.lib3ds

Private
Function ModuleLog(message$)
	TMaxB3DLogger.Write "a3dsloader",message
End Function

Public

Type TMeshLoader3DS Extends TMeshLoader
	Global _stream:TStream
	
	Method Run(mesh:TMesh,stream:TStream,url:Object)	
		If stream=Null Return False
		
		Local io:Lib3dsIo=New Lib3dsIo
		io.self_= stream ' Only including this to prevent the lib from failing.
		io.seek_func = a3ds_seek_func
		io.tell_func = a3ds_tell_func
		io.read_func = a3ds_read_func
		io.write_func = a3ds_write_func
		io.log_func = a3ds_log_func
		
		_stream = stream
		
		Local file:Byte Ptr=lib3ds_file_new()
		If Not lib3ds_file_read(file,io)
			_stream = Null
			Return False
		EndIf
		
		_stream = Null		
		DebugLog lib3ds_file_get_materials_size (file)
		Local brush:TBrush[lib3ds_file_get_nmaterials(file)]
		For Local i=0 To brush.length-1
			DebugLog "de"
		Next

		Return True
	End Method
	
	Function a3ds_seek_func:Long(self_:Byte Ptr, offset:Long, origin)
		Local pos
		Select origin
		Case LIB3DS_SEEK_SET
			pos=offset
		Case LIB3DS_SEEK_CUR
			pos=StreamPos(_stream)+offset
		Case LIB3DS_SEEK_END
			pos=StreamSize(_stream)-offset
			DebugStop
    End Select
		SeekStream _stream,pos
	End Function
	
	Function a3ds_tell_func:Long(self_:Byte Ptr)
		Return StreamPos(_stream)
	End Function

	Function a3ds_read_func(self_:Byte Ptr,buffer:Byte Ptr,size)
		Return _stream.ReadBytes(buffer,size)
	End Function
	
	Function a3ds_write_func(self_:Byte Ptr,buffer:Byte Ptr,size)
		Return _stream.WriteBytes(buffer,size)
	End Function
		
	Function a3ds_log_func(self_:Byte Ptr, level, indent, msg:Byte Ptr)
		ModuleLog String.FromCString(msg)
	End Function
	
	Method Name$()
		Return "Autodesk 3DS"
	End Method
	Method ModuleName$()
		Return "a3dsloader"
	End Method
End Type
New TMeshLoader3DS
