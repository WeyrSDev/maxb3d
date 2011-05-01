
Strict

Import "worldconfig.bmx"
Import "entity.bmx"
Import "mesh.bmx"

Const BODY_NONE   = 0
Const BODY_BOX 	  = 1
Const BODY_SPHERE = 2

Type TPhysicsDriver 
	Method Init();End Method
	
	Method Update(config:TWorldConfig) Abstract
	
	Function QuickCheck(entity:TEntity,entity2:TEntity)
		Local x#,y#,z#
		entity.GetPosition x,y,z,True
		If entity._oldx=x And entity._oldy=y And entity._oldz=z Return False
		Return True	
	End Function
End Type

Type TB3DPhysicsDriver Extends TPhysicsDriver
	Method Update(config:TWorldConfig)
		Global c_vec_a:Byte Ptr=C_CreateVecObject(0.0,0.0,0.0)
		Global c_vec_b:Byte Ptr=C_CreateVecObject(0.0,0.0,0.0)
		Global c_vec_radius:Byte Ptr=C_CreateVecObject(0.0,0.0,0.0)
							
		Global c_vec_i:Byte Ptr=C_CreateVecObject(0.0,0.0,0.0)
		Global c_vec_j:Byte Ptr=C_CreateVecObject(0.0,0.0,0.0)
		Global c_vec_k:Byte Ptr=C_CreateVecObject(0.0,0.0,0.0)
	
		Global c_mat:Byte Ptr=C_CreateMatrixObject(c_vec_i,c_vec_j,c_vec_k)
					
		Global c_vec_v:Byte Ptr=C_CreateVecObject(0.0,0.0,0.0)
		
		Global c_tform:Byte Ptr=C_CreateTFormObject(c_mat,c_vec_v)
	
		For Local i=0 To MAX_COLLISION_TYPES-1
			If config.CollisionType[i]=Null Then Continue
			For Local entity:TEntity=EachIn config.CollisionType[i]
				entity._collision=Null
		
				If entity.GetVisible()=False Continue
				
				Local x#,y#,z#
				entity.GetPosition x,y,z,True
				C_UpdateVecObject(c_vec_a,x,y,z)
				C_UpdateVecObject(c_vec_b,entity._oldx,entity._oldy,entity._oldz)
				C_UpdateVecObject(c_vec_radius,entity._radiusx,entity._radiusy,entity._radiusx)
	
				Local c_col_info:Byte Ptr=C_CreateCollisionInfoObject(c_vec_a,c_vec_b,c_vec_radius)	
				Local c_coll:Byte Ptr=Null
	
				Local response
				Repeat	
					Local hit=False		
					c_coll=C_CreateCollisionObject()	
					Local entity2_hit:TEntity=Null					
					For Local col_pair:TCollisionPair=EachIn config.CollisionPairs					
						If col_pair.src=i
							If config.CollisionType[col_pair.dest]=Null Then Continue
						
							For Local entity2:TEntity=EachIn config.CollisionType[col_pair.dest]
								If entity2.GetVisible()=False Then Continue				
								If entity=entity2 Then Continue
								
								If QuickCheck(entity,entity2)=False Then Continue
			
								C_UpdateVecObject(c_vec_i,entity2._matrix._m[0,0],entity2._matrix._m[0,1],entity2._matrix._m[0,2])
								C_UpdateVecObject(c_vec_j,entity2._matrix._m[1,0],entity2._matrix._m[1,1],entity2._matrix._m[1,2])
								C_UpdateVecObject(c_vec_k,entity2._matrix._m[2,0],entity2._matrix._m[2,1],entity2._matrix._m[2,2])
						
								C_UpdateMatrixObject(c_mat,c_vec_i,c_vec_j,c_vec_k)
								C_UpdateVecObject(c_vec_v,entity2._matrix._m[3,0],entity2._matrix._m[3,1],entity2._matrix._m[3,2])
								C_UpdateTFormObject(c_tform,c_mat,c_vec_v)
			
								If col_pair.methd<>COLLISION_METHOD_POLYGON
									C_UpdateCollisionInfoObject(c_col_info,entity2._radiusx,entity2._boxx,entity2._boxy,entity2._boxz,entity2._boxx+entity2._boxwidth,entity2._boxy+entity2._boxheight,entity2._boxz+entity2._boxdepth)
								EndIf
					
								Local tree:Byte Ptr
								If TMesh(entity2)<>Null tree=TMesh(entity2).TreeCheck()
			
								hit=C_CollisionDetect(c_col_info,c_coll,c_tform,tree,col_pair.methd)
			
								If hit Then entity2_hit=entity2;response=col_pair.response							
							Next						
						EndIf					
					Next
					
					If entity2_hit<>Null		
						Local collision:TCollision=New TCollision
						collision.x=C_CollisionX()
						collision.y=C_CollisionY()
						collision.z=C_CollisionZ()
						collision.nx=C_CollisionNX()
						collision.ny=C_CollisionNY()
						collision.nz=C_CollisionNZ()
						collision.entity=entity2_hit
						collision.triangle=C_CollisionTriangle()						
						If TMesh(entity2_hit)<>Null collision.surface=C_CollisionSurface()						
						
						entity._collision=entity._collision[..entity._collision.length+1]
						entity._collision[entity._collision.length-1]=collision	
							
						If C_CollisionResponse(c_col_info,c_coll,response)=False Then Exit						
					Else				
						Exit								
					EndIf				
					C_DeleteCollisionObject(c_coll)									
				Forever
	
				C_DeleteCollisionObject(c_coll)	
				If C_CollisionFinal(c_col_info) entity.SetPosition(C_CollisionPosX(),C_CollisionPosY(),C_CollisionPosZ(),True)		
				C_DeleteCollisionInfoObject(c_col_info)		
				entity.GetPosition entity._oldx,entity._oldy,entity._oldz,True
			Next										
		Next	
	End Method
End Type

Type TPhysicsData
End Type

Type TBody Extends TEntity
	Field _mass#,_shape
	Field _data:TPhysicsData,_update
	
	Method New()
		_shape = BODY_SPHERE
	End Method
	
	Method Copy:TBody(parent:TEntity=Null)
		Local body:TBody=New TBody
		Return body
	End Method
	
	Method SetScale(x#,y#,z#,glob=False)
		Super.SetScale(x,y,z,glob)
		_update=True
	End Method
	
	Method SetRotation(x#,y#,z#,glob=False)
		Super.SetRotation(x,y,z,glob)
		_update=True
	End Method
	
	Method SetPosition(x#,y#,z#,glob=False)
		Super.SetPosition(x,y,z,glob)
		_update=True
	End Method
	
	Method SetBox(x#,y#,z#,width#,height#,depth#)
		Super.SetBox(x,y,z,width,height,depth)
		_shape = BODY_BOX
		_update=True
	End Method

	Method GetMass#()
		Return _mass
	End Method
	Method SetMass(mass#)
		_mass=mass
		_update=True
	End Method
End Type

Function B3DPhysicsDriver:TB3DPhysicsDriver()
	Global _driver:TB3DPhysicsDriver=New TB3DPhysicsDriver
	Return _driver	
End Function
