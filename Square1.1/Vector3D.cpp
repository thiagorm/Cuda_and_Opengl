#include <math.h> 
#include <limits>
#include "Vector3D.h"

using namespace std;

Vector3D::Vector3D()
{
}

Vector3D::Vector3D(float x, float y, float z)
{
	this->x = x;
	this->y = y;
	this->z = z;
}

Vector3D::~Vector3D()
{
}

Vector3D Vector3D::operator+(Vector3D vec)
{
	Vector3D result;

	result.x = x + vec.x;
	result.y = y + vec.y;
	result.z = z + vec.z;

	return result;
}

Vector3D Vector3D::operator-(Vector3D vec)
{
	Vector3D result;

	result.x = x - vec.x;
	result.y = y - vec.y;
	result.z = z - vec.z;

	return result;
}

Vector3D Vector3D::operator*(float factor)
{
	Vector3D result;

	result.x = x * factor;
	result.y = y * factor;
	result.z = z * factor;

	return result;
}

Vector3D Vector3D::operator/(float div)
{
	Vector3D result;

	result.x = x / div;
	result.y = y / div;
	result.z = z / div;

	return result;
}

Vector3D Vector3D::operator += (float b)
{
    x += b;
    y += b;
	z += b;
    return *this;
}

Vector3D Vector3D::operator /= (float c)
{
    x /= c;
    y /= c;
	z /= c;
    return *this;
}

Vector3D Vector3D::operator *= (float d)
{
    x *= d;
    y *= d;
	z *= d;
    return *this;
}

float Vector3D::length()
{
	return sqrt(x*x + y*y);
}

/*Vector3D Vector3D::rotate(float angle)
{
	Vector3D result;

	result.x = x * cos(angle) + y * sin(angle);
	result.y = -1 * x * sin(angle) + y * cos(angle);

	return result;
}*/

inline void Vector3D::Normalize()
{ 
  float vector_length = this->length();

  //if (vector_length > std::numeric_limits<float>::epsilon())
  //{
    this->x /= vector_length;
    this->y /= vector_length;
	this->z /= vector_length;
  //}
}

Vector3D Vector3D::truncVector(Vector3D vector3, float max)
{
	if(vector3.length() > max)
	{
		vector3.Normalize();
		vector3 *= max;
	}
			
	return vector3;
}