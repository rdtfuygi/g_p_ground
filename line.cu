#include "geometry.cuh"

__host__ __device__ line::line() :origin(), dir() {}

__host__ __device__ line::line(point ��, vector ����) : origin(��), dir(����.unitize()) {}

__host__ __device__ line::line(point ��, double �Ƕ�, bool rad) : origin(��)
{
	if (!rad)
	{
		�Ƕ� = deg2rad(�Ƕ�);
	}
	dir[0] = cos(�Ƕ�);
	dir[1] = sin(�Ƕ�);
}

__host__ __device__ line::line(double ��_1_x, double ��_1_y, double ��_2_x, double ��_2_y) :origin(��_1_x, ��_1_y), dir((vector(��_2_x, ��_2_y) - vector(��_1_x, ��_1_y)).unitize()) {}

__host__ __device__ line::line(point ��_1, point ��_2) :origin(��_1), dir((vector(��_2) - vector(��_1)).unitize()) {}

__host__ __device__ line::line(double k, double b) :origin(0, b), dir(vector(1, k + b).unitize()) {}

__host__ __device__ point line::point_get(double t)
{
	return point(vector(origin) + (dir * t));
}
