#pragma once

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include<cmath>

class point
{
public:
	double locat[2];
	__host__ __device__ point();
	__host__ __device__ point(double x, double y);
	__host__ __device__ point(double λ��[2]);
	__host__ __device__ double& operator[](int i);
};

class vector :public point
{
public:
	__host__ __device__ vector();
	__host__ __device__ vector(double x, double y);
	__host__ __device__ vector(point ��);
	__host__ __device__ vector(double ����[2], double ����);
	__host__ __device__ vector(double �Ƕ�, bool rad = false, double ���� = 1);
	__host__ __device__ double& operator[](int i);
	__host__ __device__ friend vector operator + (vector ����_1, vector ����_2);
	__host__ __device__ friend vector operator - (vector ����_1, vector ����_2);
	__host__ __device__ friend vector operator * (vector ����, double ��);
	__host__ __device__ friend vector operator * (double ��, vector ����);
	__host__ __device__ friend vector operator / (vector ����, double ��);
	__host__ __device__ vector& operator += (vector ����);
	__host__ __device__ vector& operator -= (vector ����);
	__host__ __device__ vector& operator *= (double ��);
	__host__ __device__ vector& operator /= (double ��);
	__host__ __device__ vector unitize();
};

class line
{
public:
	point origin;
	vector dir;
	__host__ __device__ line();
	__host__ __device__ line(point ��, vector ����);
	__host__ __device__ line(point ��, double �Ƕ�, bool rad = false);
	__host__ __device__ line(double ��_1_x, double ��_1_y, double ��_2_x, double ��_2_y);
	__host__ __device__ line(point ��_1, point ��_2);
	__host__ __device__ line(double k, double b);
	__host__ __device__ point point_get(double t);
};

class ray :public line
{
public:
	__host__ __device__ ray();
	__host__ __device__ ray(point ��, vector ����);
	__host__ __device__ ray(point ��, double �Ƕ�, bool rad = false);
	__host__ __device__ ray(double ��_1_x, double ��_1_y, double ��_2_x, double ��_2_y);
	__host__ __device__ ray(point ��_1, point ��_2);
};

class seg :public ray
{
public:
	double dist;
	__host__ __device__ seg();
	__host__ __device__ seg(point ��, vector ����, double ����);
	__host__ __device__ seg(point ��, double ����, double ����, bool rad = false);
	__host__ __device__ seg(double ��_1_x, double ��_1_y, double ��_2_x, double ��_2_y);
	__host__ __device__ seg(point ��_1, point ��_2);
	__host__ __device__ point end();
};

__host__ __device__ double deg2rad(double rad);
__host__ __device__ double rad2deg(double deg);

__host__ __device__ double length(double ��_1_x, double ��_1_y, double ��_2_x, double ��_2_y);
__host__ __device__ double length(point ��_1, point ��_2);
__host__ __device__ double length(vector ����);

__host__ __device__ double operator * (vector ����_1, vector ����_2);
__host__ __device__ double operator ^ (vector ����_1, vector ����_2);

__host__ __device__ void cross(const line l_1, const line l_2, double& t_1, double& t_2);
__host__ __device__ void cross(const line l_1, const ray l_2, double& t_1, double& t_2);
__host__ __device__ void cross(const line l_1, const seg l_2, double& t_1, double& t_2);
__host__ __device__ void cross(const ray l_1, const line l_2, double& t_1, double& t_2);
__host__ __device__ void cross(const ray l_1, const ray l_2, double& t_1, double& t_2);
__host__ __device__ void cross(const ray l_1, const seg l_2, double& t_1, double& t_2);
__host__ __device__ void cross(const seg l_1, const line l_2, double& t_1, double& t_2);
__host__ __device__ void cross(const seg l_1, const ray l_2, double& t_1, double& t_2);
__host__ __device__ void cross(const seg l_1, const seg l_2, double& t_1, double& t_2);
__host__ __device__ point cross(const line l_1, const line l_2);
__host__ __device__ point cross(const line l_1, const ray l_2);
__host__ __device__ point cross(const line l_1, const seg l_2);
__host__ __device__ point cross(const ray l_1, const line l_2);
__host__ __device__ point cross(const ray l_1, const ray l_2);
__host__ __device__ point cross(const ray l_1, const seg l_2);
__host__ __device__ point cross(const seg l_1, const line l_2);
__host__ __device__ point cross(const seg l_1, const ray l_2);
__host__ __device__ point cross(const seg l_1, const seg l_2);
