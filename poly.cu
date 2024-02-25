#include "geometry.cuh"



__host__ __device__ poly::poly() {}

__host__ __device__ poly::poly(const point* ��, int m)
{
	int temp = m < 20 ? m : 20 ;
	for (int i = 0; i < temp - 1; i++)
	{
		segs[i] = seg(��[i], ��[i + 1]);
	}
	for (int i = temp; i < 20 ; i++)
	{
		segs[i] = seg(��[temp], ��[temp + 1]);
	}
	segs[20 - 1] = seg(��[temp - 1], ��[0]);
}

poly::poly(std::vector<point>& ��)
{
	int temp = (��.size() < 20 ) ? ��.size() : 20 ;
	for (int i = 0; i < temp - 1; i++)
	{
		segs[i] = seg(��[i], ��[i + 1]);
	}
	for (int i = temp - 1; i < 20 - 1; i++)
	{
		segs[i] = seg(��[��.size() - 1], ��[��.size() - 1]);
	}
	segs[20 - 1] = seg(��[temp - 1], ��[0]);
}

__host__ __device__ bool poly::legal()
{
	reset_seg();
	for (int i = 0; i < 20; i++)
	{
		for (int j = 0; j < 20; j++)
		{
			double t_1, t_2;
			cross(segs[i], segs[j], t_1, t_2);
			if ((t_1 != DBL_MAX) && (((abs(t_1 - segs[i].dist) > 0.0001) && (abs(t_1) > 0.0001)) || ((abs(t_2 - segs[j].dist) > 0.0001) && (abs(t_2) > 0.0001))))
			{
				return false;
			}
		}
	}
	return true;
}

__host__ __device__ void poly::point_get(point*& ��) const
{
	if (�� != nullptr)
	{
		delete[]��;
	}
	�� = new point[20];
	for (int i = 0; i < 20 ; i++)
	{
		��[i] = (segs[i]).origin;
	}
}

void poly::point_get(std::vector<point>& ��) const
{
	�� = std::vector<point>(20);
	for (int i = 0; i < 20 ; i++)
	{
		��[i] = (segs[i]).origin;
	}
}

__host__ __device__ void poly::seg_get(seg*& �߶�) const
{
	if (�߶� != nullptr)
	{
		delete[]�߶�;
	}
	�߶� = new seg[20];
	for (int i = 0; i < 20 ; i++)
	{
		�߶�[i] = (segs[i]);
	}
}

void poly::seg_get(std::vector<seg>& �߶�) const
{
	�߶� = std::vector<seg>(20);
	for (int i = 0; i < 20 ; i++)
	{
		�߶�[i] = (segs[i]);
	}
}

__host__ __device__ bool poly::point_in(point ��) const
{
	ray temp;
	temp.origin = ��;
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
	if ((max[0] < ��[0]) || (max[1] < ��[1]) || (min[0] > ��[0]) || (min[1] > ��[1]))
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
	for (int i = 0, n = 0; (i < 20 - 1) && (n < 20); i++)
	{
		if ((abs(segs[i].origin[0] - segs[i + 1].origin[0]) > 0.001) || (abs(segs[i].origin[1] - segs[i + 1].origin[1]) > 0.001))
		{
			continue;
		}
		n++;
		i--;
		for (int j = i + 1; j < 20 - 1; j++)
		{
			segs[j].origin = segs[j + 1].origin;
		}
		segs[19].origin = segs[0].origin;
	}
	


	for (int i = 0; i < 20 - 1; i++)
	{
		segs[i] = seg(segs[i].origin, segs[i + 1].origin);
	}
	segs[19] = seg(segs[19].origin, segs[0].origin);
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

void poly::print(cv::InputOutputArray ͼ��, double ����, const cv::Scalar& ��ɫ, int ��ϸ) const
{
	//seg(segs[0].origin, segs[1].origin).print(ͼ��, ����, ��ɫ, ��ϸ * 2);
	for (int i = 0; i < 19; i++)
	{
		seg(segs[i].origin, segs[i + 1].origin).print(ͼ��, ����, ��ɫ, ��ϸ);
	}
	seg(segs[19].origin, segs[0].origin).print(ͼ��, ����, ��ɫ, ��ϸ);
	//segs[0].origin.print(ͼ��, ����, ��ɫ, ��ϸ * 4);
}

vector poly::move2center()
{
	reset_seg();


	double s = area();
	double x = 0, y = 0;
	for (int i = 0; i < 19; i++)
	{
		double �� = segs[i].dir ^ segs[i + 1].dir;
		x += (segs[i].origin[0] + segs[i+1].origin[0]) * ��;
		y += (segs[i].origin[1] + segs[i+1].origin[1]) * ��;
	}
	vector move(x / 6 / s, y / 6 / s);

	//for (int i = 0; i < 19; i++)
	//{
	//	if ((abs(segs[i].origin[0] - segs[i + 1].origin[0]) > 0.00001) || (abs(segs[i].origin[1] - segs[i + 1].origin[1]) > 0.00001))
	//	{
	//		move -= vector(segs[i].origin);
	//		n++;
	//	}
	//}
	//if ((abs(segs[19].origin[0] - segs[0].origin[0]) > 0.00001) || (abs(segs[19].origin[1] - segs[0].origin[1]) > 0.00001))
	//{
	//	move -= vector(segs[19].origin);
	//	n++;
	//}
	//
	//move /= n;
	for (int i = 0; i < 20; i++)
	{
		segs[i].origin = point(vector(segs[i].origin) + move);
	}

	return move;
}

__host__ __device__ void poly::simple(double �Ƕ�, bool rad)
{
	if (!rad)
	{
		�Ƕ� = deg2rad(�Ƕ�);
	}
	double cos_ = cos(�Ƕ�);

	reset_seg();
	int n = 1;
	while (n != 0)	{

		n = 0;
		for (int i = 0, j = 1; j < 20; j++)
		{
			i = j - 1;

			double cos_t = (vector(0.0, 0.0) - segs[i].dir) * segs[j].dir;
			if ((cos_t > cos_) && (segs[i].dist > 0.0001) && (segs[j].dist > 0.0001))
			{
				n++;
				if (i == 18)
				{
					segs[19].origin = segs[0].origin;
				}
				for (int k = i + 1; k < 20 - 1; k++)
				{
					segs[k].origin = segs[k + 1].origin;
				}
				reset_seg();
			}
		}
		vector dir_;
		for (int i = 19; i >= 0; i--)
		{
			if (segs[i].dist > 0.0001)
			{
				dir_ = segs[i].dir;
				break;
			}
		}
		double cos_t = (vector(0.0, 0.0) - dir_) * segs[0].dir;
		if (cos_t > cos_)
		{
			n++;
			for (int j = 0; j < 20 - 1; j++)
			{
				segs[j].origin = segs[j + 1].origin;
			}
			reset_seg();
		}
	}
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
