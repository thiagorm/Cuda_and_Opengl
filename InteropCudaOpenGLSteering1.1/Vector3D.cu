#ifndef _Vector3D_
#define _Vector3D_

#include <math.h> 
#include <limits>

class Vector3D
{
	public:

	float x; 
	float y;
	float z;

	__host__ __device__ Vector3D()
	{
	}

	__host__ __device__ Vector3D(float x, float y, float z)
	{
		this->x = x;
		this->y = y;
		this->z = z;
	}

	__host__ __device__ ~Vector3D()
	{
	}

	__host__ __device__ Vector3D operator+(Vector3D vec)
	{
		Vector3D result;

		result.x = x + vec.x;
		result.y = y + vec.y;
		result.z = z + vec.z;

		return result;
	}

	__host__ __device__ Vector3D operator-(Vector3D vec)
	{
		Vector3D result;

		result.x = x - vec.x;
		result.y = y - vec.y;
		result.z = z - vec.z;

		return result;
	}

	__host__ __device__ Vector3D operator*(float factor)
	{
		Vector3D result;

		result.x = x * factor;
		result.y = y * factor;
		result.z = z * factor;

		return result;
	}

	__host__ __device__ Vector3D operator/(float div)
	{
		Vector3D result;

		result.x = x / div;
		result.y = y / div;
		result.z = z / div;

		return result;
	}

	__host__ __device__ Vector3D operator += (float b)
	{
		x += b;
		y += b;
		z += b;
		return *this;
	}

	__host__ __device__ Vector3D operator /= (float c)
	{
		x /= c;
		y /= c;
		z /= c;
		return *this;
	}

	__host__ __device__ Vector3D operator *= (float d)
	{
		x *= d;
		y *= d;
		z *= d;
		return *this;
	}

	__host__ __device__ float length()
	{
		return sqrt(x*x + y*y);
	}

	/*Vector3D rotate(float angle)
	{
		Vector3D result;

		result.x = x * cos(angle) + y * sin(angle);
		result.y = -1 * x * sin(angle) + y * cos(angle);

		return result;
	}*/

	__host__ __device__ inline void Normalize()
	{ 
	  float vector_length = this->length();

	  //if (vector_length > std::numeric_limits<float>::epsilon())
	  //{
		this->x /= vector_length;
		this->y /= vector_length;
		this->z /= vector_length;
	  //}
	}

	__device__ Vector3D truncVector(Vector3D vector3, float max)
	{
		if(vector3.length() > max)
		{
			vector3.Normalize();
			vector3 *= max;
		}
			
		return vector3;
	}
};

#endif