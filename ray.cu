#include "geometry.cuh"

__host__ __device__ ray::ray() :line() {}

__host__ __device__ ray::ray(point ��, vector ����) :line(��, ����) {}

__host__ __device__ ray::ray(point ��, double �Ƕ�, bool rad) :line(��, �Ƕ�, rad) {}

__host__ __device__ ray::ray(double ��_1_x, double ��_1_y, double ��_2_x, double ��_2_y) :line(��_1_x, ��_1_y, ��_2_x, ��_2_y) {}

__host__ __device__ ray::ray(point ��_1, point ��_2) :line(��_1, ��_2) {}

__host__ __device__ ray ray::rotate(const point ��, double �Ƕ�, bool rad) const
{
	return ray(::rotate(��, origin, �Ƕ�, rad), dir.rotate(�Ƕ�, rad));
}

__host__ __device__ double ray::point_dist(const point ��) const
{
	line temp;
	temp.origin = ��;
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
		return length(��, origin);
	}
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
	if (((l_1.origin[0] < l_2.origin[0]) && (l_1.dir[0] < 0) && (0 < l_2.dir[0])) ||
		((l_1.origin[0] > l_2.origin[0]) && (l_1.dir[0] > 0) && (0 > l_2.dir[0])) ||
		((l_1.origin[1] < l_2.origin[1]) && (l_1.dir[1] < 0) && (0 < l_2.dir[1])) ||
		((l_1.origin[1] > l_2.origin[1]) && (l_1.dir[1] > 0) && (0 > l_2.dir[1])))
	{
		t_1 = DBL_MAX;
		t_2 = DBL_MAX;
		return;
	}
	cross(line(l_1), line(l_2), t_1, t_2);
	if ((0 > t_1) || (0 > t_2))
	{
		t_1 = DBL_MAX;
		t_2 = DBL_MAX;
	}
}

__host__ __device__ void cross(const ray l_1, const seg l_2, double& t_1, double& t_2)
{
	point end = l_2.end();
	if ((fmin(l_2.origin[0], end[0]) > l_1.origin[0]) && (l_2.dir[0] < 0) ||
		(fmin(l_2.origin[1], end[1]) > l_1.origin[1]) && (l_2.dir[1] < 0) ||
		(fmax(l_2.origin[0], end[0]) < l_1.origin[0]) && (l_2.dir[0] > 0) ||
		(fmax(l_2.origin[1], end[1]) < l_1.origin[1]) && (l_2.dir[1] > 0))
	{
		t_1 = DBL_MAX;
		t_2 = DBL_MAX;
		return;
	}
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


