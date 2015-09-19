
Strict

Import MaxB3D.Core
Import Prime.Newton

Import "util.c"

Extern
	Function _byte_ptr_to_object:Object(p:Byte Ptr)
End Extern

Type TNewtonCollisionDriver Extends TCollisionDriver
	Field _world:Byte Ptr
	
	Method Init()
		_world = NewtonCreate()
		' NewtonSetPlatformArchitecture _world, 0

		Local minSize#[] = [-500.0, -500.0, -500.0]
		Local maxSize#[] = [ 500.0,  500.0,  500.0]
		'NewtonSetWorldSize _world, minSize, maxSize		
	
		NewtonSetSolverModel _world, 1
	End Method
	
	Method Destroy()
		NewtonDestroyAllBodies _world
		NewtonDestroy _world
	End Method
	
	Method Update(config:TWorldConfig,speed#)
		For Local body:TBody=EachIn config.List[WORLDLIST_BODY]
			If Not body._update And body._data<>Null Continue
			If Not TNewtonData(body._data) body._data=New TNewtonData
			Local data:TNewtonData=TNewtonData(body._data)
			
			Local collision:Byte Ptr
			Select body._shape
			Case BODY_SPHERE,BODY_NONE
				collision=NewtonCreateCapsule(_world,body._radiusx,body._radiusy,0,Null)
			Case BODY_BOX
				'Local offset:TMatrix=TMatrix.Translation((body._boxwidth/2.0)-body._boxx,(body._boxheight/2.0)-body._boxy,(body._boxdepth/2.0)-body._boxz)
				collision=NewtonCreateBox(_world,body._boxwidth,body._boxheight,body._boxdepth,0,Null)
			End Select			

			If data._ptr NewtonDestroyBody(data._ptr)

			data._ptr=NewtonCreateDynamicBody(_world,collision,body._matrix.ToPtr())
			NewtonBodySetUserData data._ptr, Byte Ptr(body) - 8
			
			If body._mass>0
				Local inertia#[3],origin#[3]
				NewtonConvexCollisionCalculateInertialMatrix collision,inertia,origin	
				NewtonBodySetMassMatrix data._ptr,body._mass,body._mass*inertia[0],body._mass*inertia[1],body._mass*inertia[2]
				NewtonBodySetCentreOfMass data._ptr,origin
			EndIf
			
			NewtonBodySetDestructorCallback data._ptr, DestroyCallback				
			NewtonBodySetForceAndTorqueCallback data._ptr, ForceAndTorqueCallback
			NewtonBodySetTransformCallback data._ptr, TransformCallback			

			'NewtonReleaseCollision _world,collision
			body._update=False
		Next
  		NewtonUpdate _world,speed
	End Method
	
	Function TransformCallback(body:Byte Ptr,matrix_data:Float Ptr,thread_index)
		GCResume
		Local entity:TBody = TBody(_byte_ptr_to_object(NewtonBodyGetUserData(body)))
		entity.SetMatrix TMatrix.FromPtr(matrix_data)
		entity._update=False
	End Function
	
	Function ForceAndTorqueCallback(body:Byte Ptr,timestep#,thread_index)
		GCResume
		Local ixx#,iyy#,izz#,mass#
		NewtonBodyGetMassMatrix body,Varptr mass,Varptr ixx,Varptr iyy,Varptr izz
		NewtonBodySetForce body,[0.0,mass*-9.8,0.0]
	End Function
	
	Function DestroyCallback(body:Byte Ptr)
		GCResume
	End Function
End Type

Type TNewtonData
	Field _ptr:Byte Ptr
End Type

