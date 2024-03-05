#include "geometry.cuh"

__host__ __device__ line::line() :origin(), dir() {}

__host__ __device__ line::line(point 点, vector 向量) : origin(点), dir(向量.unitize()) {}

__host__ __device__ line::line(point 点, double 角度, bool rad) : origin(点)
{
	if (!rad)
	{
		角度 = deg2rad(角度);
	}
	dir[0] = cos(角度);
	dir[1] = sin(角度);
}

__host__ __device__ line::line(double 点_1_x, double 点_1_y, double 点_2_x, double 点_2_y) :origin(点_1_x, 点_1_y), dir((vector(点_2_x, 点_2_y) - vector(点_1_x, 点_1_y)).unitize()) {}

__host__ __device__ line::line(point 点_1, point 点_2) :origin(点_1), dir((vector(点_2) - vector(点_1)).unitize()) {}

__host__ __device__ line::line(double k, double b) :origin(0, b), dir(vector(1, k + b).unitize()) {}

__host__ __device__ point line::point_get(double t) const
{
	return point(vector(origin) + (dir * t));
}

__host__ __device__ double line::angle_get(bool rad) const
{
	return dir.angle_get(rad);
}

__host__ __device__ line line::rotate(const point 点, double 角度, bool rad) const
{
	return line(::rotate(点, origin, 角度, rad), dir.rotate(角度, rad));
}

__host__ __device__ double line::point_dist(const point 点) const
{
	line temp;
	temp.origin = 点;
	temp.dir[0] = dir[1];
	temp.dir[1] = -dir[0];

	double t_1, t_2;
	cross(*this, temp, t_1, t_2);
	return abs(t_2);
}

void line::print(cv::InputOutputArray 图像, double 比例, const cv::Scalar& 颜色, int 粗细) const
{
	int 高 = 图像.rows(), 宽 = 图像.cols();
	int 原点_x = 宽 / 2, 原点_y = 高 / 2;

	int 放大 = 2 * (高 > 宽 ? 高 : 宽);

	cv::Point 点_1(origin[0] * 比例 - dir[0] * 放大 + 原点_x, -origin[1] * 比例 + dir[1] * 放大 + 原点_y);
	cv::Point 点_2(origin[0] * 比例 + dir[0] * 放大 + 原点_x, -origin[1] * 比例 - dir[1] * 放大 + 原点_y);
	cv::line(图像, 点_1, 点_2, 颜色, 粗细);
}


__host__ __device__ void cross(const line l_1, const line l_2, double& t_1, double& t_2)
{
	double 矩阵[2][3] =
	{
		{l_1.dir[0],-l_2.dir[0],-l_1.origin[0] + l_2.origin[0]},
		{l_1.dir[1],-l_2.dir[1],-l_1.origin[1] + l_2.origin[1]}
	};
	if (矩阵[0][0] != 0)
	{
		double a00 = 矩阵[0][0];
		double a10 = 矩阵[1][0];
		for (int i = 0; i < 3; i++)
		{
			矩阵[0][i] /= a00;
			矩阵[1][i] -= 矩阵[0][i] * a10;
		}

		if (矩阵[1][1] == 0)
		{
			t_1 = DBL_MAX;
			t_2 = DBL_MAX;
			return;
		}

		double a01 = 矩阵[0][1];
		double a11 = 矩阵[1][1];
		for (int i = 0; i < 3; i++)
		{
			矩阵[1][i] /= a11;
			矩阵[0][i] -= 矩阵[1][i] * a01;
		}

		t_1 = 矩阵[0][2];
		t_2 = 矩阵[1][2];
	}
	else if (矩阵[1][0] != 0)
	{
		double a10 = 矩阵[1][0];
		double a00 = 矩阵[0][0];
		for (int i = 0; i < 3; i++)
		{
			矩阵[1][i] /= a10;
			矩阵[0][i] -= 矩阵[1][i] * a00;
		}

		if (矩阵[0][1] == 0)
		{
			t_1 = DBL_MAX;
			t_2 = DBL_MAX;
			return;
		}

		double a11 = 矩阵[1][1];
		double a01 = 矩阵[0][1];
		for (int i = 0; i < 3; i++)
		{
			矩阵[0][i] /= a01;
			矩阵[1][i] -= 矩阵[0][i] * a11;
		}


		t_2 = 矩阵[0][2];
		t_1 = 矩阵[1][2];
	}
	else
	{
		t_1 = DBL_MAX;
		t_2 = DBL_MAX;
	}
}

__host__ __device__ void cross(const line l_1, const ray l_2, double& t_1, double& t_2)
{
	cross(line(l_1), line(l_2), t_1, t_2);
	if (0 > t_2)
	{
		t_1 = DBL_MAX;
		t_2 = DBL_MAX;
	}
}

__host__ __device__ void cross(const line l_1, const seg l_2, double& t_1, double& t_2)
{
	cross(line(l_1), line(l_2), t_1, t_2);
	if ((0 > t_2) || (t_2 > l_2.dist))
	{
		t_1 = DBL_MAX;
		t_2 = DBL_MAX;
	}
}

__host__ __device__ point cross(const line l_1, const line l_2)
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

__host__ __device__ point cross(const line l_1, const ray l_2)
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

__host__ __device__ point cross(const line l_1, const seg l_2)
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