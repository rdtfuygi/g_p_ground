#include "geometry.cuh"

__host__ __device__ line::line() :origin(), dir() {}

__host__ __device__ line::line(point 点, vector 向量) : origin(点), dir(向量.unitize()) {}

__host__ __device__ line::line(point 点, double 角度, bool rad) : origin(点)
{
	if (!rad)
	{
		角度 = deg2rad(角度);
	}
	dir[0] = cos(角度);
	dir[1] = sin(角度);
}

__host__ __device__ line::line(double 点_1_x, double 点_1_y, double 点_2_x, double 点_2_y) :origin(点_1_x, 点_1_y), dir((vector(点_2_x, 点_2_y) - vector(点_1_x, 点_1_y)).unitize()) {}

__host__ __device__ line::line(point 点_1, point 点_2) :origin(点_1), dir((vector(点_2) - vector(点_1)).unitize()) {}

__host__ __device__ line::line(double k, double b) :origin(0, b), dir(vector(1, k + b).unitize()) {}

__host__ __device__ point line::point_get(double t)
{
	return point(vector(origin) + (dir * t));
}
