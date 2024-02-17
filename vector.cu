#include "geometry.cuh"


__host__ __device__ vector::vector() :point(1, 0) {}

__host__ __device__ vector::vector(double x, double y) : point(x, y) {}

__host__ __device__ vector::vector(point ��) : point(��) {};

__host__ __device__ vector::vector(double ����[2], double ����)
{
	double ���� = ���� / length({ 0,0 }, ����);
	locat[0] = ����[0] * ����;
	locat[1] = ����[1] * ����;
}

__host__ __device__ vector::vector(double �Ƕ�, bool rad, double ����)
{
	if (!rad)
	{
		�Ƕ� = deg2rad(�Ƕ�);
	}
	locat[0] = cos(�Ƕ�) * ����;
	locat[1] = sin(�Ƕ�) * ����;
}

__host__ __device__ double& vector::operator[](int i)
{
	return locat[i & 1];
}

__host__ __device__ vector& vector::operator+=(vector ����)
{
	locat[0] += ����[0];
	locat[1] += ����[1];
	return *this;
}

__host__ __device__ vector& vector::operator-=(vector ����)
{
	locat[0] -= ����[0];
	locat[1] -= ����[1];
	return *this;
}

__host__ __device__ vector& vector::operator*=(double ��)
{
	locat[0] *= ��;
	locat[1] *= ��;
	return *this;
}

__host__ __device__ vector& vector::operator/=(double ��)
{
	locat[0] /= ��;
	locat[1] /= ��;
	return *this;
}

__host__ __device__ vector vector::unitize()
{
	return vector(*this / length(*this));
}

__host__ __device__ vector operator+(vector ����_1, vector ����_2)
{
	return vector(����_1[0] + ����_2[0], ����_1[1] + ����_2[1]);
}

__host__ __device__ vector operator-(vector ����_1, vector ����_2)
{
	return vector(����_1[0] - ����_2[0], ����_1[1] - ����_2[1]);
}

__host__ __device__ vector operator*(vector ����, double ��)
{
	return vector(����[0] * ��, ����[1] * ��);
}

__host__ __device__ vector operator*(double ��, vector ����)
{
	return vector(����[0] * ��, ����[1] * ��);
}

__host__ __device__ vector operator/(vector ����, double ��)
{
	return vector(����[0] / ��, ����[1] / ��);
}