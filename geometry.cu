#define _USE_MATH_DEFINES 

#include "geometry.cuh"
#include <limits>


__host__ __device__ double deg2rad(double rad)
{
	return rad * M_PI / 180;
}

__host__ __device__ double rad2deg(double deg)
{
	return deg / M_PI * 180;
}



__host__ __device__ double length(double ��_1_x, double ��_1_y, double ��_2_x, double ��_2_y)
{
	return sqrt(pow(��_1_x - ��_2_x, 2) + pow(��_1_y - ��_2_y, 2));
}

__host__ __device__ double length(point ��_1, point ��_2)
{
	return length(��_1[0], ��_1[1], ��_2[0], ��_2[1]);
}

__host__ __device__ point rotate(const point ԭ��, const point ��_2, double �Ƕ�, bool rad)
{
	if (!rad)
	{
		�Ƕ� = deg2rad(�Ƕ�);
	}
	double x = (��_2[0] - ԭ��[0]) * cos(�Ƕ�) - (��_2[1] - ԭ��[1]) * sin(�Ƕ�) + ԭ��[0];
	double y = (��_2[0] - ԭ��[0]) * sin(�Ƕ�) + (��_2[1] - ԭ��[1]) * cos(�Ƕ�) + ԭ��[1];
	return point(x, y);
}
