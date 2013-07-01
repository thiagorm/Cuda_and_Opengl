#include <limits>
#include <stdio.h>
#include <math.h>
#include "Agent.h"


Agent::Agent(Vector3D position, Vector3D velocity)
{
	this->position = position;
	this->velocity = velocity;
}

Agent::Agent()
{
}

inline Vector3D Vec3DNormalize(Vector3D v)
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

void Agent::AgentMovement(float vVerts[], Vector3D vector, float verticeLenth, int i)
{
		vVerts[i + 0] = -vector.x; 
		vVerts[i + 1] = vector.y; 
		vVerts[i + 2] = vector.z;
		vVerts[i + 3] = -(vector.x-verticeLenth); 
		vVerts[i + 4] = vector.y; 
		vVerts[i + 5] = vector.z;
		vVerts[i + 6] = -vector.x; 
		vVerts[i + 7] = (vector.y-verticeLenth); 
		vVerts[i + 8] = vector.z;
		vVerts[i + 9] = -(vector.x-verticeLenth); 
		vVerts[i + 10] =  (vector.y-verticeLenth); 
		vVerts[i + 11] = vector.z;
}

Vector3D Agent::calculate_steering(Vector3D target)
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