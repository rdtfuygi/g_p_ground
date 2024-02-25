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



__host__ __device__ double length(double 点_1_x, double 点_1_y, double 点_2_x, double 点_2_y)
{
	return sqrt(pow(点_1_x - 点_2_x, 2) + pow(点_1_y - 点_2_y, 2));
}

__host__ __device__ double length(point 点_1, point 点_2)
{
	return length(点_1[0], 点_1[1], 点_2[0], 点_2[1]);
}

__host__ __device__ point rotate(const point 原点, const point 点_2, double 角度, bool rad)
{
	if (!rad)
	{
		角度 = deg2rad(角度);
	}
	double x = (点_2[0] - 原点[0]) * cos(角度) - (点_2[1] - 原点[1]) * sin(角度) + 原点[0];
	double y = (点_2[0] - 原点[0]) * sin(角度) + (点_2[1] - 原点[1]) * cos(角度) + 原点[1];
	return point(x, y);
}
