#include "geometry.cuh"

__host__ __device__ line::line() :origin(), dir() {}

__host__ __device__ line::line(point ��, vector ����) : origin(��), dir(����.unitize()) {}

__host__ __device__ line::line(point ��, double �Ƕ�, bool rad) : origin(��)
{
	if (!rad)
	{
		�Ƕ� = deg2rad(�Ƕ�);
	}
	dir[0] = cos(�Ƕ�);
	dir[1] = sin(�Ƕ�);
}

__host__ __device__ line::line(double ��_1_x, double ��_1_y, double ��_2_x, double ��_2_y) :origin(��_1_x, ��_1_y), dir((vector(��_2_x, ��_2_y) - vector(��_1_x, ��_1_y)).unitize()) {}

__host__ __device__ line::line(point ��_1, point ��_2) :origin(��_1), dir((vector(��_2) - vector(��_1)).unitize()) {}

__host__ __device__ line::line(double k, double b) :origin(0, b), dir(vector(1, k + b).unitize()) {}

__host__ __device__ point line::point_get(double t) const
{
	return point(vector(origin) + (dir * t));
}

__host__ __device__ double line::angle_get(bool rad) const
{
	return dir.angle_get(rad);
}

__host__ __device__ line line::rotate(const point ��, double �Ƕ�, bool rad) const
{
	return line(::rotate(��, origin, �Ƕ�, rad), dir.rotate(�Ƕ�, rad));
}

__host__ __device__ double line::point_dist(const point ��) const
{
	line temp;
	temp.origin = ��;
	temp.dir[0] = dir[1];
	temp.dir[1] = -dir[0];

	double t_1, t_2;
	cross(*this, temp, t_1, t_2);
	return abs(t_2);
}


__host__ __device__ void cross(const line l_1, const line l_2, double& t_1, double& t_2)
{
	double ����[2][3] =
	{
		{l_1.dir[0],-l_2.dir[0],-l_1.origin[0] + l_2.origin[0]},
		{l_1.dir[1],-l_2.dir[1],-l_1.origin[1] + l_2.origin[1]}
	};
	if (����[0][0] != 0)
	{
		{
			double a00 = ����[0][0];
			double a10 = ����[1][0];
			for (int i = 0; i < 3; i++)
			{
				����[0][i] /= a00;
				����[1][i] -= ����[0][i] * a10;
			}
		}

		if (����[1][1] == 0)
		{
			t_1 = DBL_MAX;
			t_2 = DBL_MAX;
			return;
		}

		{
			double a01 = ����[0][1];
			double a11 = ����[1][1];
			for (int i = 0; i < 3; i++)
			{
				����[1][i] /= a11;
				����[0][i] -= ����[1][i] * a01;
			}
		}

		t_1 = ����[0][2];
		t_2 = ����[1][2];
	}
	else if (����[1][0] != 0)
	{
		{
			double a10 = ����[1][0];
			double a00 = ����[0][0];
			for (int i = 0; i < 3; i++)
			{
				����[1][i] /= a10;
				����[0][i] -= ����[1][i] * a00;
			}
		}

		if (����[0][1] == 0)
		{
			t_1 = DBL_MAX;
			t_2 = DBL_MAX;
			return;
		}

		{
			double a11 = ����[1][1];
			double a01 = ����[0][1];
			for (int i = 0; i < 3; i++)
			{
				����[0][i] /= a01;
				����[1][i] -= ����[0][i] * a11;
			}
		}


		t_2 = ����[0][2];
		t_1 = ����[1][2];
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