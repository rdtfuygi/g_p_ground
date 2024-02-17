#include "geometry.cuh"

__host__ __device__ seg::seg() :ray(), dist(1) {}

__host__ __device__ seg::seg(point 点, vector 向量, double 长度) : ray(点, 向量), dist(长度) {}

__host__ __device__ seg::seg(point 点, double 方向, double 长度, bool rad) : ray(点, 方向, rad), dist(长度) {}

__host__ __device__ seg::seg(double 点_1_x, double 点_1_y, double 点_2_x, double 点_2_y) :ray(点_1_x, 点_1_y, 点_2_x, 点_2_y), dist(length(点_1_x, 点_1_y, 点_2_x, 点_2_y)) {}

__host__ __device__ seg::seg(point 点_1, point 点_2) : ray(点_1, 点_2), dist(length(点_1, 点_2)) {}

__host__ __device__ point seg::end()
{
	return point(vector(origin) + (dir * dist));
}


