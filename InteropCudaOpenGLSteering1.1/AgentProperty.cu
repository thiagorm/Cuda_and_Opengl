#ifndef _AgentProperty_
#define _AgentProperty_

#include <limits>
#include <stdio.h>
#include <math.h>

#include "Vector3D.cu"

__device__ const float MAX_FORCE = 0.05f;
__device__ const float MAX_SPEED = 0.8f;

class AgentProperty
{
    public:

	Vector3D position;
	Vector3D velocity;
	Vector3D force;


	__host__ __device__ AgentProperty(Vector3D position, Vector3D velocity)
	{
		this->position = position;
		this->velocity = velocity;
	}

	__host__ __device__ AgentProperty()
	{
	}

	__host__ __device__ inline Vector3D Vec3DNormalize(Vector3D v)
	{
	  Vector3D vec;

	  float vector_length = v.length();

	  //if (vector_length > std::numeric_limits<float>::epsilon())
	  //{
		vec.x = v.x / vector_length;
		vec.y = v.y / vector_length;
		vec.z = v.z / vector_length;

		//printf("vec --- %f\n", vec.x);
	  //}

	  return vec;
	}

	__host__ __device__ void AgentMovement(float vVerts[], Vector3D vector, float verticeLenth)
	{
	vVerts[0] = -vector.x; vVerts[1] = vector.y; vVerts[2] = vector.z;
	vVerts[3] = -(vector.x-verticeLenth); vVerts[4] = vector.y; vVerts[5] = vector.z;
	vVerts[6] = -vector.x; vVerts[7] = (vector.y-verticeLenth); vVerts[8] = vector.z;
	vVerts[9] = -(vector.x-verticeLenth); vVerts[10] =  (vector.y-verticeLenth); vVerts[11] = vector.z;
	}

	__device__ Vector3D calculate_steering(Vector3D target)
	{
		Vector3D desired_velocity;
		Vector3D teste;

		desired_velocity = Vec3DNormalize(target - this->position) * MAX_SPEED;
		//printf("Position --- %f\n", target.x);
		//printf("Desired --- %f\n", desired_velocity.x);
		teste = desired_velocity - this->velocity;
		//printf("Velocity --- %f\n", this->velocity.x);
		//printf("Desired 2 --- %f\n", teste.x);
		return (desired_velocity - this->velocity);
	}

	/*void AgentMovement(float vVerts[], Vector3D vector, float verticeLenth)
	{
		vVerts[0] = -vector.x; vVerts[1] = vector.y; vVerts[2] = vector.z;
		vVerts[3] = -(vector.x-verticeLenth); vVerts[4] = vector.y; vVerts[5] = vector.z;
		vVerts[6] = -vector.x; vVerts[7] = (vector.y-verticeLenth); vVerts[8] = vector.z;
		vVerts[9] = -(vector.x-verticeLenth); vVerts[10] =  (vector.y-verticeLenth); vVerts[11] = vector.z;
	}*/
};

#endif