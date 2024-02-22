#include "geometry.cuh"

__host__ __device__ seg::seg() :ray(), dist(1) {}

__host__ __device__ seg::seg(point ��, vector ����, double ����) : ray(��, ����), dist(����) {}

__host__ __device__ seg::seg(point ��, double ����, double ����, bool rad) : ray(��, ����, rad), dist(����) {}

__host__ __device__ seg::seg(double ��_1_x, double ��_1_y, double ��_2_x, double ��_2_y) :ray(��_1_x, ��_1_y, ��_2_x, ��_2_y), dist(length(��_1_x, ��_1_y, ��_2_x, ��_2_y)) {}

__host__ __device__ seg::seg(point ��_1, point ��_2) : ray(��_1, ��_2), dist(length(��_1, ��_2)) {}

__host__ __device__ point seg::end() const
{
	return point(vector(origin) + (dir * dist));
}

__host__ __device__ seg seg::rotate(const point ��, double �Ƕ�, bool rad) const
{
	return seg(::rotate(��, origin, �Ƕ�, rad), dir.rotate(�Ƕ�, rad));
}

__host__ __device__ double seg::point_dist(const point ��) const
{
	line temp;
	temp.origin = ��;
	temp.dir[0] = dir[1];
	temp.dir[1] = -dir[0];

	double t_1, t_2;
	cross(*this, temp, t_1, t_2);
	if (t_1 < 0)
	{
		return length(��, origin);
	}
	else if (t_1 > dist)
	{
		return length(��, end());
	}
	else
	{
		return abs(t_2);
	}
}

void seg::print(cv::InputOutputArray ͼ��, double ����, const cv::Scalar& ��ɫ, int ��ϸ) const
{
	int �� = ͼ��.rows(), �� = ͼ��.cols();
	int ԭ��_x = �� / 2, ԭ��_y = �� / 2;

	int �Ŵ� = 2 * (�� > �� ? �� : ��);

	cv::Point ��_1(origin[0] * ���� + ԭ��_x, -origin[1] * ���� + ԭ��_y);
	cv::Point ��_2(end()[0] * ���� + ԭ��_x, -end()[1] * ���� + ԭ��_y);
	cv::line(ͼ��, ��_1, ��_2, ��ɫ, ��ϸ);
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