#include "geometry.cuh"



__host__ __device__ poly::poly() {}

__host__ __device__ poly::poly(const point* 点, int m)
{
	int temp = m < 20 ? m : 20 ;
	for (int i = 0; i < temp - 1; i++)
	{
		segs[i] = seg(点[i], 点[i + 1]);
	}
	for (int i = temp; i < 20 ; i++)
	{
		segs[i] = seg(点[temp], 点[temp + 1]);
	}
	segs[20 - 1] = seg(点[temp - 1], 点[0]);
}

poly::poly(std::vector<point>& 点)
{
	int temp = (点.size() < 20 ) ? 点.size() : 20 ;
	for (int i = 0; i < temp - 1; i++)
	{
		segs[i] = seg(点[i], 点[i + 1]);
	}
	for (int i = temp - 1; i < 20 - 1; i++)
	{
		segs[i] = seg(点[点.size() - 1], 点[点.size() - 1]);
	}
	segs[20 - 1] = seg(点[temp - 1], 点[0]);
}

__host__ __device__ bool poly::legal()
{
	reset_seg();
	for (int i = 0; i < 20; i++)
	{
		for (int j = 0; j < i; j++)
		{
			double t_1, t_2;
			cross(segs[i], segs[j], t_1, t_2);
			if ((t_1 != DBL_MAX) && (((abs(t_1 - segs[i].dist) > 0.01) && (abs(t_1) > 0.01)) || ((abs(t_2 - segs[j].dist) > 0.01) && (abs(t_2) > 0.01))))
			{
				return false;
			}
		}
	}
	return true;
}

__host__ __device__ void poly::point_get(point*& 点) const
{
	if (点 != nullptr)
	{
		delete[]点;
	}
	点 = new point[20];
	for (int i = 0; i < 20 ; i++)
	{
		点[i] = (segs[i]).origin;
	}
}

void poly::point_get(std::vector<point>& 点) const
{
	点 = std::vector<point>(20);
	for (int i = 0; i < 20 ; i++)
	{
		点[i] = (segs[i]).origin;
	}
}

__host__ __device__ void poly::seg_get(seg*& 线段) const
{
	if (线段 != nullptr)
	{
		delete[]线段;
	}
	线段 = new seg[20];
	for (int i = 0; i < 20 ; i++)
	{
		线段[i] = (segs[i]);
	}
}

void poly::seg_get(std::vector<seg>& 线段) const
{
	线段 = std::vector<seg>(20);
	for (int i = 0; i < 20 ; i++)
	{
		线段[i] = (segs[i]);
	}
}

__host__ __device__ bool poly::point_in(point 点) const
{
	ray temp;
	temp.origin = 点;
	temp.dir = vector(point({ 0,1 }));
	int k = 0;

	point max = segs[0].origin, min = segs[0].origin;
	for (int i = 1; i < 20 ; i++)
	{
		max[0] = (max[0] > segs[i].origin[0]) ? max[0] : segs[i].origin[0];
		max[1] = (max[1] > segs[i].origin[0]) ? max[1] : segs[i].origin[1];
		min[0] = (min[0] < segs[i].origin[0]) ? min[0] : segs[i].origin[0];
		min[1] = (min[1] < segs[i].origin[0]) ? min[1] : segs[i].origin[1];
	}
	if ((max[0] < 点[0]) || (max[1] < 点[1]) || (min[0] > 点[0]) || (min[1] > 点[1]))
	{
		return false;
	}

	for (int i = 0; i < 20 ; i++)
	{
		if (is_cross(temp, segs[i]))
		{
			k++;
		}
	}
	if ((k % 2) == 0)
	{
		return false;
	}

	temp.dir = vector(point({ 0,-1 }));
	k = 0;
	for (int i = 0; i < 20 ; i++)
	{
		if (is_cross(temp, segs[i]))
		{
			k++;
		}
	}
	if ((k % 2) == 0)
	{
		return false;
	}
	return true;
}

__host__ __device__ void poly::reset_seg()
{
	for (int i = 0; i < 20 - 1; i++)
	{
		segs[i] = seg(segs[i].origin, segs[i + 1].origin);
	}
	segs[19] = seg(segs[20 - 1].origin, segs[0].origin);
}

__host__ __device__ void poly::reset_seg(int i)
{
	segs[i] = seg(segs[i].origin, segs[(i + 1) % 20].origin);
}

__host__ __device__ seg& poly::operator[](int i)
{
	return segs[i % 20 ];
}

__host__ __device__ seg poly::operator[](int i) const
{
	return segs[i % 20 ];
}

__host__ __device__ double poly::area() const
{
	double s = 0;
	for (int i = 0; i < 20 - 1; i++)
	{
		s += vector(segs[i].origin) ^ vector(segs[i + 1].origin);
	}
	s += vector(segs[20 - 1].origin) ^ vector(segs[0].origin);
	return s / 2;
}

void poly::print(cv::InputOutputArray 图像, double 比例, const cv::Scalar& 颜色, int 粗细) const
{
	for (int i = 0; i < 19; i++)
	{
		seg(segs[i].origin, segs[i + 1].origin).print(图像, 比例, 颜色, 粗细);
	}
	seg(segs[19].origin, segs[0].origin).print(图像, 比例, 颜色, 粗细);
}

vector poly::move2center()
{
	int n = 0;
	vector move(0.0, 0.0);
	for (int i = 0; i < 19; i++)
	{
		if ((abs(segs[i].origin[0] - segs[19].origin[0]) > 0.00001) || (abs(segs[i].origin[1] - segs[19].origin[1]) > 0.00001))
		{
			move -= vector(segs[i].origin);
			n++;
		}
	}
	move -= vector(segs[19].origin);
	n++;

	move /= n;
	for (int i = 0; i < 20; i++)
	{
		segs[i].origin = point(vector(segs[i].origin) + move);
	}

	return move;
}

__host__ __device__ bool poly::is_overlap(const poly other) const
{
	return ::is_overlap(*this, other);
}

__host__ __device__ bool poly::full_overlap(const poly other) const
{
	for (int i = 0; i < 20; i++)
	{
		for (int j = 0; j < 20; j++)
		{
			if (is_cross(other[i], segs[j]))
			{
				return false;
			}
		}
	}
	if (!point_in(other[0].origin))
	{
		return false;
	}
	return true;
}

__host__ __device__ bool is_overlap(const poly p_1, const poly p_2)
{
	int l[20];
	for (int i = 0; i < 20; i++)
	{
		l[i] = 0;
	}

	for (int i = 0; i < 20 ; i++)
	{
		int k = 0;
		for (int j = 0; j < 20; j++)
		{
			double t_1, t_2;
			cross(ray(p_1[i]), ray(p_2[j]), t_1, t_2);
			if ((t_1 < p_1[i].dist) && (t_2 < p_2[j].dist))
			{
				return true;
			}

			if ((t_1 != DBL_MAX) || ((t_2 > p_2[j].dist) && (t_2 != DBL_MAX)))
			{
				l[j]++;
				k++;
			}
		}

		if ((k % 2) == 0)
		{
			continue;
		}

		k = 0;
		for (int j = 0; j < 20; j++)
		{
			double t_1, t_2;
			cross(ray(p_1[i].origin, -1 * p_1[i].dir), p_2[j], t_1, t_2);

			if (t_1 != DBL_MAX)
			{
				k++;
			}
		}

		if ((k % 2) == 1)
		{
			return true;
		}
	}

	for (int i = 0; i < 20; i++)
	{
		if ((l[i] % 2) == 0)
		{
			continue;
		}

		l[i] = 0;
		for (int j = 0; j < 20 ; j++)
		{
			double t_1, t_2;
			cross(p_1[j], ray(p_2[i].origin, -1 * p_2[i].dir), t_1, t_2);

			if (t_1 != DBL_MAX)
			{
				l[i]++;
			}
		}

		if ((l[i] % 2) == 1)
		{
			return true;
		}
	}

	return false;
}

__host__ __device__ double dist(const poly p_1, const poly p_2)
{
	double dist = DBL_MAX;
	for (int i = 0; i < 20; i++)
	{
		for (int j = 0; j < 20; j++)
		{
			dist = fmin(dist, p_1[i].point_dist(p_2[j].origin));
			dist = fmin(dist, p_2[i].point_dist(p_1[j].origin));
		}
	}
	return dist;
}
