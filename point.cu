#include "geometry.cuh"

__host__ __device__ point::point()
{
	locat[0] = 0;
	locat[1] = 0;
}

__host__ __device__ point::point(double x, double y)
{
	locat[0] = x;
	locat[1] = y;
}

__host__ __device__ point::point(double λ��[2])
{
	locat[0] = λ��[0];
	locat[1] = λ��[1];
}

__host__ __device__ double& point::operator[](int i)
{
	return locat[i & 1];
}

__host__ __device__ double point::operator[](int i) const
{
	return locat[i & 1];
}
