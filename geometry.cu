#include "geometry.cuh"
#include <numbers>










__host__ __device__ double deg2rad(double rad)
{
	return rad / std::numbers::pi * 180;
}

__host__ __device__ double rad2deg(double deg)
{
	return deg * std::numbers::pi / 180;
}



__host__ __device__ double length(double 点_1_x, double 点_1_y, double 点_2_x, double 点_2_y)
{
	return sqrt(pow(点_1_x - 点_2_x, 2) + pow(点_1_y - 点_2_y, 2));
}

__host__ __device__ double length(point 点_1, point 点_2)
{
	return length(点_1[0], 点_1[1], 点_2[0], 点_2[1]);
}

__host__ __device__ double length(vector 向量)
{
	return length({ 0,0 }, 向量);
}



__host__ __device__ double operator*(vector 向量_1, vector 向量_2)
{
	return 向量_1[0] * 向量_2[0] + 向量_1[1] * 向量_2[1];
}

__host__ __device__ double operator^(vector 向量_1, vector 向量_2)
{
	return __host__ __device__ double();
}