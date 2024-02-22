#include "geometry.cuh"

__host__ __device__ seg::seg() :ray(), dist(1) {}

__host__ __device__ seg::seg(point 点, vector 向量, double 长度) : ray(点, 向量), dist(长度) {}

__host__ __device__ seg::seg(point 点, double 方向, double 长度, bool rad) : ray(点, 方向, rad), dist(长度) {}

__host__ __device__ seg::seg(double 点_1_x, double 点_1_y, double 点_2_x, double 点_2_y) :ray(点_1_x, 点_1_y, 点_2_x, 点_2_y), dist(length(点_1_x, 点_1_y, 点_2_x, 点_2_y)) {}

__host__ __device__ seg::seg(point 点_1, point 点_2) : ray(点_1, 点_2), dist(length(点_1, 点_2)) {}

__host__ __device__ point seg::end() const
{
	return point(vector(origin) + (dir * dist));
}

__host__ __device__ seg seg::rotate(const point 点, double 角度, bool rad) const
{
	return seg(::rotate(点, origin, 角度, rad), dir.rotate(角度, rad));
}

__host__ __device__ double seg::point_dist(const point 点) const
{
	line temp;
	temp.origin = 点;
	temp.dir[0] = dir[1];
	temp.dir[1] = -dir[0];

	double t_1, t_2;
	cross(*this, temp, t_1, t_2);
	if (t_1 < 0)
	{
		return length(点, origin);
	}
	else if (t_1 > dist)
	{
		return length(点, end());
	}
	else
	{
		return abs(t_2);
	}
}

void seg::print(cv::InputOutputArray 图像, double 比例, const cv::Scalar& 颜色, int 粗细) const
{
	int 高 = 图像.rows(), 宽 = 图像.cols();
	int 原点_x = 宽 / 2, 原点_y = 高 / 2;

	int 放大 = 2 * (高 > 宽 ? 高 : 宽);

	cv::Point 点_1(origin[0] * 比例 + 原点_x, -origin[1] * 比例 + 原点_y);
	cv::Point 点_2(end()[0] * 比例 + 原点_x, -end()[1] * 比例 + 原点_y);
	cv::line(图像, 点_1, 点_2, 颜色, 粗细);
}


__host__ __device__ void cross(const seg l_1, const line l_2, double& t_1, double& t_2)
{
	cross(line(l_1), line(l_2), t_1, t_2);
	if ((0 > t_1) || (t_1 > l_1.dist))
	{
		t_1 = DBL_MAX;
		t_2 = DBL_MAX;
	}
}

__host__ __device__ void cross(const seg l_1, const ray l_2, double& t_1, double& t_2)
{
	point end = l_1.end();
	if ((fmin(l_1.origin[0], end[0]) > l_2.origin[0]) && (l_1.dir[0] < 0) ||
		(fmin(l_1.origin[1], end[1]) > l_2.origin[1]) && (l_1.dir[1] < 0) ||
		(fmax(l_1.origin[0], end[0]) < l_2.origin[0]) && (l_1.dir[0] > 0) ||
		(fmax(l_1.origin[1], end[1]) < l_2.origin[1]) && (l_1.dir[1] > 0))
	{
		t_2 = DBL_MAX;
		t_1 = DBL_MAX;
		return;
	}
	cross(line(l_2), line(l_1), t_2, t_1);
	if ((0 > t_2) || (0 > t_1) || (t_1 > l_1.dist))
	{
		t_2 = DBL_MAX;
		t_1 = DBL_MAX;
	}
}

__host__ __device__ void cross(const seg l_1, const seg l_2, double& t_1, double& t_2)
{
	point end_1 = l_1.end();
	point end_2 = l_2.end();
	if ((fmin(l_1.origin[0], end_1[0]) > fmax(l_2.origin[0], end_2[0])) ||
		(fmin(l_2.origin[1], end_2[1]) > fmax(l_1.origin[1], end_1[1])) ||
		(fmin(l_1.origin[0], end_1[0]) > fmax(l_2.origin[0], end_2[0])) ||
		(fmin(l_2.origin[1], end_2[1]) > fmax(l_1.origin[1], end_1[1])))
	{
		t_2 = DBL_MAX;
		t_1 = DBL_MAX;
		return;
	}
	cross(line(l_1), line(l_2), t_2, t_1);
	if ((0 > t_2) || (t_2 > l_2.dist) || (0 > t_1) || (t_1 > l_1.dist))
	{
		t_2 = DBL_MAX;
		t_1 = DBL_MAX;
	}
}

__host__ __device__ point cross(const seg l_1, const line l_2)
{
	double t_1, t_2;
	cross(l_1, l_2, t_1, t_2);
	if (t_1 != DBL_MAX)
	{
		return l_1.point_get(t_1);
	}
	else
	{
		return point(DBL_MAX, DBL_MAX);
	}
}

__host__ __device__ point cross(const seg l_1, const ray l_2)
{
	double t_1, t_2;
	cross(l_1, l_2, t_1, t_2);
	if (t_1 != DBL_MAX)
	{
		return l_1.point_get(t_1);
	}
	else
	{
		return point(DBL_MAX, DBL_MAX);
	}
}

__host__ __device__ point cross(const seg l_1, const seg l_2)
{
	double t_1, t_2;
	cross(l_1, l_2, t_1, t_2);
	if (t_1 != DBL_MAX)
	{
		return l_1.point_get(t_1);
	}
	else
	{
		return point(DBL_MAX, DBL_MAX);
	}
}

__host__ __device__ bool is_cross(const seg l_1, const seg l_2)
{
	vector a = vector(l_2.origin) - vector(l_1.origin);
	vector b = vector(l_2.end()) - vector(l_1.origin);
	vector c = vector(l_1.origin) - vector(l_2.origin);
	vector d = vector(l_1.end()) - vector(l_2.origin);
	return ((a ^ b) < 0) && ((c ^ d) < 0);
}

__host__ __device__ bool is_cross(const seg l_1, const ray l_2)
{
	double t_1, t_2;
	cross(l_1, l_2, t_1, t_2);
	if (t_1 != DBL_MAX)
	{
		return true;
	}
	return false;
}