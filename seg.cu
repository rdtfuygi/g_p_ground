#include "geometry.cuh"

__host__ __device__ seg::seg() :ray(), dist(1) {}

__host__ __device__ seg::seg(point ��, vector ����, double ����) : ray(��, ����), dist(����) {}

__host__ __device__ seg::seg(point ��, double ����, double ����, bool rad) : ray(��, ����, rad), dist(����) {}

__host__ __device__ seg::seg(double ��_1_x, double ��_1_y, double ��_2_x, double ��_2_y) :ray(��_1_x, ��_1_y, ��_2_x, ��_2_y), dist(length(��_1_x, ��_1_y, ��_2_x, ��_2_y)) {}

__host__ __device__ seg::seg(point ��_1, point ��_2) : ray(��_1, ��_2), dist(length(��_1, ��_2)) {}

__host__ __device__ point seg::end()
{
	return point(vector(origin) + (dir * dist));
}


