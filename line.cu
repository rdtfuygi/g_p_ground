#include "geometry.cuh"

__host__ __device__ line::line() :origin(), dir() {}

__host__ __device__ line::line(point µ„, vector œÚ¡ø) : origin(µ„), dir(œÚ¡ø.unitize()) {}

__host__ __device__ line::line(point µ„, double Ω«∂», bool rad) : origin(µ„)
{
	if (!rad)
	{
		Ω«∂» = deg2rad(Ω«∂»);
	}
	dir[0] = cos(Ω«∂»);
	dir[1] = sin(Ω«∂»);
}

__host__ __device__ line::line(double µ„_1_x, double µ„_1_y, double µ„_2_x, double µ„_2_y) :origin(µ„_1_x, µ„_1_y), dir((vector(µ„_2_x, µ„_2_y) - vector(µ„_1_x, µ„_1_y)).unitize()) {}

__host__ __device__ line::line(point µ„_1, point µ„_2) :origin(µ„_1), dir((vector(µ„_2) - vector(µ„_1)).unitize()) {}

__host__ __device__ line::line(double k, double b) :origin(0, b), dir(vector(1, k + b).unitize()) {}

__host__ __device__ point line::point_get(double t) const
{
	return point(vector(origin) + (dir * t));
}

__host__ __device__ double line::angle_get(bool rad) const
{
	return dir.angle_get(rad);
}

__host__ __device__ line line::rotate(const point µ„, double Ω«∂», bool rad) const
{
	return line(::rotate(µ„, origin, Ω«∂», rad), dir.rotate(Ω«∂», rad));
}

__host__ __device__ double line::point_dist(const point µ„) const
{
	line temp;
	temp.origin = µ„;
	temp.dir[0] = dir[1];
	temp.dir[1] = -dir[0];

	double t_1, t_2;
	cross(*this, temp, t_1, t_2);
	return abs(t_2);
}


__host__ __device__ void cross(const line l_1, const line l_2, double& t_1, double& t_2)
{
	double æÿ’Û[2][3] =
	{
		{l_1.dir[0],-l_2.dir[0],-l_1.origin[0] + l_2.origin[0]},
		{l_1.dir[1],-l_2.dir[1],-l_1.origin[1] + l_2.origin[1]}
	};
	if (æÿ’Û[0][0] != 0)
	{
		{
			double a00 = æÿ’Û[0][0];
			double a10 = æÿ’Û[1][0];
			for (int i = 0; i < 3; i++)
			{
				æÿ’Û[0][i] /= a00;
				æÿ’Û[1][i] -= æÿ’Û[0][i] * a10;
			}
		}

		if (æÿ’Û[1][1] == 0)
		{
			t_1 = DBL_MAX;
			t_2 = DBL_MAX;
			return;
		}

		{
			double a01 = æÿ’Û[0][1];
			double a11 = æÿ’Û[1][1];
			for (int i = 0; i < 3; i++)
			{
				æÿ’Û[1][i] /= a11;
				æÿ’Û[0][i] -= æÿ’Û[1][i] * a01;
			}
		}

		t_1 = æÿ’Û[0][2];
		t_2 = æÿ’Û[1][2];
	}
	else if (æÿ’Û[1][0] != 0)
	{
		{
			double a10 = æÿ’Û[1][0];
			double a00 = æÿ’Û[0][0];
			for (int i = 0; i < 3; i++)
			{
				æÿ’Û[1][i] /= a10;
				æÿ’Û[0][i] -= æÿ’Û[1][i] * a00;
			}
		}

		if (æÿ’Û[0][1] == 0)
		{
			t_1 = DBL_MAX;
			t_2 = DBL_MAX;
			return;
		}

		{
			double a11 = æÿ’Û[1][1];
			double a01 = æÿ’Û[0][1];
			for (int i = 0; i < 3; i++)
			{
				æÿ’Û[0][i] /= a01;
				æÿ’Û[1][i] -= æÿ’Û[0][i] * a11;
			}
		}


		t_2 = æÿ’Û[0][2];
		t_1 = æÿ’Û[1][2];
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