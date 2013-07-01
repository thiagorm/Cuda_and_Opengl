#ifndef _Agent_
#define _Agent_

#include "Vector3D.h"

const float MAX_FORCE = 0.05f;
const float MAX_SPEED = 0.8f;

class Agent
{
public:
	Vector3D position;
	Vector3D velocity;
	Vector3D force;

	Agent();
	Agent(Vector3D new_position, Vector3D new_velocity);

	void AgentMovement(float vVerts[], Vector3D vector, float verticeLenth, int i);

	Vector3D calculate_steering(Vector3D target);
	//Vector3D TruncateOver(Vector3D vector, float max);
	//Vector3D update_seek(Agent entity, Vector3D target);

};

#endif