#include "geometry.cuh"

template<int n>
__host__ __device__ poly<n>::poly() {}

template<int n>
__host__ __device__ poly<n>::poly(const point 点[n])
{
	for (int i = 0; i < n - 1; i++)
	{
		segs[i] = seg(点[i], 点[i + 1]);
	}
	segs[n - 1] = seg(点[n - 1], 点[0]);
}

template<int n>
__host__ __device__ poly<n>::poly(std::vector<point>& 点)
{
	for (int i = 0; i < 点.size() - 1; i++)
	{
		segs[i] = seg(点[i], 点[i + 1]);
	}
	for (int i = 点.size() - 1; i < n - 1; i++)
	{
		segs[i] = seg(点[点.size() - 1], 点[点.size() - 1]);
	}
	segs[n - 1] = seg(点[点.size() - 1], 点[0]);
}
