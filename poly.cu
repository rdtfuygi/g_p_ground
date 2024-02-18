#include "geometry.cuh"

template<int n>
__host__ __device__ poly<n>::poly() {}

template<int n>
__host__ __device__ poly<n>::poly(const point ��[n])
{
	for (int i = 0; i < n - 1; i++)
	{
		segs[i] = seg(��[i], ��[i + 1]);
	}
	segs[n - 1] = seg(��[n - 1], ��[0]);
}

template<int n>
__host__ __device__ poly<n>::poly(std::vector<point>& ��)
{
	for (int i = 0; i < ��.size() - 1; i++)
	{
		segs[i] = seg(��[i], ��[i + 1]);
	}
	for (int i = ��.size() - 1; i < n - 1; i++)
	{
		segs[i] = seg(��[��.size() - 1], ��[��.size() - 1]);
	}
	segs[n - 1] = seg(��[��.size() - 1], ��[0]);
}
