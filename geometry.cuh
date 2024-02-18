#pragma once

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <cmath>
#include <vector>

__host__ __device__ double deg2rad(double rad);
__host__ __device__ double rad2deg(double deg);


class point
{
public:
	double locat[2];
	__host__ __device__ point();
	__host__ __device__ point(double x, double y);
	__host__ __device__ point(double 位置[2]);
	__host__ __device__ double& operator[](int i);
	__host__ __device__ double operator[](int i) const;
};

__host__ __device__ double length(double 点_1_x, double 点_1_y, double 点_2_x, double 点_2_y);
__host__ __device__ double length(point 点_1, point 点_2);

__host__ __device__ point rotate(const point 点_1, const point 点_2, double 角度, bool rad = false);

class vector :public point
{
public:
	__host__ __device__ vector();
	__host__ __device__ vector(double x, double y);
	__host__ __device__ vector(point 点);
	__host__ __device__ vector(double 方向[2], double 长度);
	__host__ __device__ vector(double 角度, bool rad = false, double 长度 = 1);
	__host__ __device__ friend vector operator + (vector 向量_1, vector 向量_2);
	__host__ __device__ friend vector operator - (vector 向量_1, vector 向量_2);
	__host__ __device__ friend vector operator * (vector 向量, double 数);
	__host__ __device__ friend vector operator * (double 数, vector 向量);
	__host__ __device__ friend vector operator / (vector 向量, double 数);
	__host__ __device__ vector& operator += (vector 向量);
	__host__ __device__ vector& operator -= (vector 向量);
	__host__ __device__ vector& operator *= (double 数);
	__host__ __device__ vector& operator /= (double 数);
	__host__ __device__ vector unitize() const;
	__host__ __device__ double length() const;
	__host__ __device__ vector rotate(double 角度, bool rad = false) const;

	__host__ __device__ double angle_get(bool rad = false) const;
};

__host__ __device__ double operator * (vector 向量_1, vector 向量_2);
__host__ __device__ double operator ^ (vector 向量_1, vector 向量_2);

__host__ __device__ double length(vector 向量);



class line
{
public:
	point origin;
	vector dir;
	__host__ __device__ line();
	__host__ __device__ line(point 点, vector 向量);
	__host__ __device__ line(point 点, double 角度, bool rad = false);
	__host__ __device__ line(double 点_1_x, double 点_1_y, double 点_2_x, double 点_2_y);
	__host__ __device__ line(point 点_1, point 点_2);
	__host__ __device__ line(double k, double b);
	__host__ __device__ point point_get(double t) const;
	__host__ __device__ double angle_get(bool rad = false) const;
	__host__ __device__ line rotate(const point 点, double 角度, bool rad = false) const;
};

class ray :public line
{
public:
	__host__ __device__ ray();
	__host__ __device__ ray(point 点, vector 向量);
	__host__ __device__ ray(point 点, double 角度, bool rad = false);
	__host__ __device__ ray(double 点_1_x, double 点_1_y, double 点_2_x, double 点_2_y);
	__host__ __device__ ray(point 点_1, point 点_2);
	__host__ __device__ ray rotate(const point 点, double 角度, bool rad = false) const;
};

class seg :public ray
{
public:
	double dist;
	__host__ __device__ seg();
	__host__ __device__ seg(point 点, vector 向量, double 长度);
	__host__ __device__ seg(point 点, double 方向, double 长度, bool rad = false);
	__host__ __device__ seg(double 点_1_x, double 点_1_y, double 点_2_x, double 点_2_y);
	__host__ __device__ seg(point 点_1, point 点_2);
	__host__ __device__ point end() const;
	__host__ __device__ seg rotate(const point 点, double 角度, bool rad = false) const;
};

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
__host__ __device__ bool is_cross(const seg l_1, const seg l_2);


template<int n>
class poly
{
public:
	seg segs[n];
	__host__ __device__ poly();
	__host__ __device__ poly(const point 点[n]);
	poly(std::vector<point>& 点);

	__host__ __device__ void point_get(point& 点[n]) const;
	void point_get(std::vector<point>& 点) const;
	__host__ __device__ void seg_get(seg& 线段[n]) const;
	void seg_get(std::vector<seg> 线段) const;
	__host__ __device__ bool point_in(point 点) const;

	template<int m>
	__host__ __device__ vector overlap(poly<m>) const;

	__host__ __device__ point operator[](int i);

	__host__ __device__ double area() const;
};