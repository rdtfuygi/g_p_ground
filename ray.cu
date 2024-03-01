#include "geometry.cuh"

__host__ __device__ ray::ray() :line() {}

__host__ __device__ ray::ray(point 点, vector 向量) :line(点, 向量) {}

__host__ __device__ ray::ray(point 点, double 角度, bool rad) :line(点, 角度, rad) {}

__host__ __device__ ray::ray(double 点_1_x, double 点_1_y, double 点_2_x, double 点_2_y) :line(点_1_x, 点_1_y, 点_2_x, 点_2_y) {}

__host__ __device__ ray::ray(point 点_1, point 点_2) :line(点_1, 点_2) {}

__host__ __device__ ray ray::rotate(const point 点, double 角度, bool rad) const
{
	return ray(::rotate(点, origin, 角度, rad), dir.rotate(角度, rad));
}

__host__ __device__ double ray::point_dist(const point 点) const
{
	line temp;
	temp.origin = 点;
	temp.dir[0] = dir[1];
	temp.dir[1] = -dir[0];

	double t_1, t_2;
	cross(*this, temp, t_1, t_2);
	if (t_1 > 0)
	{
		return abs(t_2);
	}
	else
	{
		return length(点, origin);
	}
}

void ray::print(cv::InputOutputArray 图像, double 比例, const cv::Scalar& 颜色, int 粗细) const
{
	int 高 = 图像.rows(), 宽 = 图像.cols();
	int 原点_x = 宽 / 2, 原点_y = 高 / 2;

	int 放大 = 2 * (高 > 宽 ? 高 : 宽);

	cv::Point 点_1(origin[0] * 比例 + 原点_x, -origin[1] * 比例 + 原点_y);
	cv::Point 点_2(origin[0] * 比例 + dir[0] * 放大 + 原点_x, -origin[1] * 比例 - dir[1] * 放大 + 原点_y);
	cv::line(图像, 点_1, 点_2, 颜色, 粗细);
}


__host__ __device__ void cross(const ray l_1, const line l_2, double& t_1, double& t_2)
{
	cross(line(l_1), line(l_2), t_1, t_2);
	if (0 > t_1)
	{
		t_1 = DBL_MAX;
		t_2 = DBL_MAX;
	}
}

__host__ __device__ void cross(const ray l_1, const ray l_2, double& t_1, double& t_2)
{
	//if (((l_1.origin[0] < l_2.origin[0]) && (l_1.dir[0] < 0) && (0 < l_2.dir[0])) ||
	//	((l_1.origin[0] > l_2.origin[0]) && (l_1.dir[0] > 0) && (0 > l_2.dir[0])) ||
	//	((l_1.origin[1] < l_2.origin[1]) && (l_1.dir[1] < 0) && (0 < l_2.dir[1])) ||
	//	((l_1.origin[1] > l_2.origin[1]) && (l_1.dir[1] > 0) && (0 > l_2.dir[1])))
	//{
	//	t_1 = DBL_MAX;
	//	t_2 = DBL_MAX;
	//	return;
	//}
	cross(line(l_1), line(l_2), t_1, t_2);
	if ((0 > t_1) || (0 > t_2))
	{
		t_1 = DBL_MAX;
		t_2 = DBL_MAX;
	}
}

__host__ __device__ void cross(const ray l_1, const seg l_2, double& t_1, double& t_2)
{
	//point end = l_2.end();
	//if ((fmin(l_2.origin[0], end[0]) > l_1.origin[0]) && (l_2.dir[0] < 0) ||
	//	(fmin(l_2.origin[1], end[1]) > l_1.origin[1]) && (l_2.dir[1] < 0) ||
	//	(fmax(l_2.origin[0], end[0]) < l_1.origin[0]) && (l_2.dir[0] > 0) ||
	//	(fmax(l_2.origin[1], end[1]) < l_1.origin[1]) && (l_2.dir[1] > 0))
	//{
	//	t_1 = DBL_MAX;
	//	t_2 = DBL_MAX;
	//	return;
	//}
	cross(line(l_1), line(l_2), t_1, t_2);
	if ((0 > t_1) || (0 > t_2) || (t_2 > l_2.dist))
	{
		t_1 = DBL_MAX;
		t_2 = DBL_MAX;
	}
}

__host__ __device__ point cross(const ray l_1, const line l_2)
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

__host__ __device__ point cross(const ray l_1, const ray l_2)
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

__host__ __device__ point cross(const ray l_1, const seg l_2)
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

__host__ __device__ bool is_cross(const ray l_1, const seg l_2)
{
	double t_1, t_2;
	cross(l_1, l_2, t_1, t_2);
	if (t_1 != DBL_MAX)
	{
		return true;
	}
	return false;
}


