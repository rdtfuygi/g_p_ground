#include "geometry.cuh"


__host__ __device__ vector::vector() :point(1, 0) {}

__host__ __device__ vector::vector(double x, double y) : point(x, y) {}

__host__ __device__ vector::vector(point 点) : point(点) {};

__host__ __device__ vector::vector(double 方向[2], double 长度)
{
	double 比例 = 长度 / length({ 0,0 }, 方向);
	locat[0] = 方向[0] * 比例;
	locat[1] = 方向[1] * 比例;
}

__host__ __device__ vector::vector(double 角度, bool rad, double 长度)
{
	if (!rad)
	{
		角度 = deg2rad(角度);
	}
	locat[0] = cos(角度) * 长度;
	locat[1] = sin(角度) * 长度;
}

__host__ __device__ double& vector::operator[](int i)
{
	return locat[i & 1];
}

__host__ __device__ vector& vector::operator+=(vector 向量)
{
	locat[0] += 向量[0];
	locat[1] += 向量[1];
	return *this;
}

__host__ __device__ vector& vector::operator-=(vector 向量)
{
	locat[0] -= 向量[0];
	locat[1] -= 向量[1];
	return *this;
}

__host__ __device__ vector& vector::operator*=(double 数)
{
	locat[0] *= 数;
	locat[1] *= 数;
	return *this;
}

__host__ __device__ vector& vector::operator/=(double 数)
{
	locat[0] /= 数;
	locat[1] /= 数;
	return *this;
}

__host__ __device__ vector vector::unitize()
{
	return vector(*this / length(*this));
}

__host__ __device__ vector operator+(vector 向量_1, vector 向量_2)
{
	return vector(向量_1[0] + 向量_2[0], 向量_1[1] + 向量_2[1]);
}

__host__ __device__ vector operator-(vector 向量_1, vector 向量_2)
{
	return vector(向量_1[0] - 向量_2[0], 向量_1[1] - 向量_2[1]);
}

__host__ __device__ vector operator*(vector 向量, double 数)
{
	return vector(向量[0] * 数, 向量[1] * 数);
}

__host__ __device__ vector operator*(double 数, vector 向量)
{
	return vector(向量[0] * 数, 向量[1] * 数);
}

__host__ __device__ vector operator/(vector 向量, double 数)
{
	return vector(向量[0] / 数, 向量[1] / 数);
}