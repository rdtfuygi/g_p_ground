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



__host__ __device__ double length(double ��_1_x, double ��_1_y, double ��_2_x, double ��_2_y)
{
	return sqrt(pow(��_1_x - ��_2_x, 2) + pow(��_1_y - ��_2_y, 2));
}

__host__ __device__ double length(point ��_1, point ��_2)
{
	return length(��_1[0], ��_1[1], ��_2[0], ��_2[1]);
}

__host__ __device__ double length(vector ����)
{
	return length({ 0,0 }, ����);
}



__host__ __device__ double operator*(vector ����_1, vector ����_2)
{
	return ����_1[0] * ����_2[0] + ����_1[1] * ����_2[1];
}

__host__ __device__ double operator^(vector ����_1, vector ����_2)
{
	return __host__ __device__ double();
}