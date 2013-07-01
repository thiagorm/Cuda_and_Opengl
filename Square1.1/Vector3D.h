#ifndef _Vector3D_
#define _Vector3D_

class Vector3D
{
public:
	float x; 
	float y;
	float z;

	Vector3D();
	Vector3D(float x, float y, float z);
	~Vector3D();

	Vector3D operator+(Vector3D vec);
	Vector3D operator-(Vector3D vec);
	Vector3D operator*(float factor);
	Vector3D operator/(float div);
	Vector3D operator+=(float b);
	Vector3D operator/=(float c);
	Vector3D operator*=(float d);

	float length();
	Vector3D rotate(float angle);
	float getSize();
	inline void Normalize();
	Vector3D truncVector(Vector3D vector3, float max);
};


#endif