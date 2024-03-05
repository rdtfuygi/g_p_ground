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

__host__ __device__ double poly::one_link_area()
{
	point max = segs[0].origin, min = segs[0].origin;
	for (int i = 1; i < 20; i++)
	{
		max[0] = (max[0] > segs[i].origin[0]) ? max[0] : segs[i].origin[0];
		max[1] = (max[1] > segs[i].origin[1]) ? max[1] : segs[i].origin[1];
		min[0] = (min[0] < segs[i].origin[0]) ? min[0] : segs[i].origin[0];
		min[1] = (min[1] < segs[i].origin[1]) ? min[1] : segs[i].origin[1];
	}


	double last[20];
	{
		ray temp;
		temp.origin = point(int(min[0] + 1), min[1]);
		temp.dir = vector(0.0, 1.0);
		for (int i = 0; i < 20; i++)
		{
			double t_1, t_2;
			cross(temp, segs[i], t_1, t_2);
			last[i] = t_1;
		}
		for (int i = 19; i > 0; i--)
		{
			bool swap = false;
			for (int j = 0; j < i; j++)
			{
				if (last[j] < last[j + 1])
				{
					continue;
				}
				double temp_dist = last[j];
				last[j] = last[j + 1];
				last[j + 1] = temp_dist;
				swap = true;
			}
			if (!swap)
			{
				break;
			}
		}
	}


	double areas[10];
	char map[10] = { 0,1,2,3,4,5,6,7,8,9 };
	for (int i = 0; i < 10; i++)
	{
		if ((last[2 * i + 1] != DBL_MAX) && (last[2 * i] != DBL_MAX))
		{
			areas[i] = last[2 * i + 1] - last[2 * i];
		}
		else
		{
			areas[i] = 0;
		}
	}

	for (int x = min[0] + 2; x < max[0]; x++)
	{
		double dist[20];
		char map_new[10] = { 10,10,10,10,10,10,10,10,10,10 };

		seg temp;
		temp.origin = point(x, min[1]);
		temp.dir = vector(0.0, 1.0);
		temp.dist = max[1] - min[1];
		for (int i = 0; i < 20; i++)
		{
			double t_1, t_2;
			cross(temp, segs[i], t_1, t_2);
			dist[i] = t_1;
		}
		for (int i = 19; i > 0; i--)
		{
			bool swap = false;
			for (int j = 0; j < i; j++)
			{
				if (dist[j] > dist[j + 1])
				{
					double temp_dist = dist[j];
					dist[j] = dist[j + 1];
					dist[j + 1] = temp_dist;
					swap = true;
				}
			}
			if (!swap)
			{
				break;
			}
		}

		int i = 0, j = 0;
		while ((i < 10) && (j < 10))
		{
			if ((last[2 * i] == DBL_MAX) || (last[2 * i + 1] == DBL_MAX) || (dist[2 * j] == DBL_MAX) || (dist[2 * j + 1] == DBL_MAX))
			{
				break;
			}
			if ((last[2 * i + 1] > dist[2 * j]) && (last[2 * i] < dist[2 * j + 1]))
			{
				if (map_new[j] == 10)
				{
					map_new[j] = map[i];
					areas[map_new[j]] += dist[2 * j + 1] - dist[2 * j];
				}
				else if (map_new[j] != map[i])
				{
					areas[map_new[j]] += areas[map[i]];
				}

			}
			if (last[2 * i + 1] < dist[2 * j + 1])
			{
				i++;
			}
			else if (last[2 * i + 1] > dist[2 * j + 1])
			{
				j++;
			}
			else
			{
				i++;
				j++;
			}
		}
		for (int i = 0; i < 10; i++)
		{
			last[2 * i] = dist[2 * i];
			last[2 * i + 1] = dist[2 * i + 1];
			if (map_new[i] != 10)
			{
				map[i] = map_new[i];
			}
		}
	}
	double output = 0;
	for (int i = 0; i < 10; i++)
	{
		output = (areas[i] > output) ? areas[i] : output;
	}

	return output;
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
		max[1] = (max[1] > segs[i].origin[1]) ? max[1] : segs[i].origin[1];
		min[0] = (min[0] < segs[i].origin[0]) ? min[0] : segs[i].origin[0];
		min[1] = (min[1] < segs[i].origin[1]) ? min[1] : segs[i].origin[1];
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

__host__ __device__ double poly::dir_area() const
{
	double s = 0;
	for (int i = 0; i < 20 - 1; i++)
	{
		s += vector(segs[i].origin) ^ vector(segs[i + 1].origin);
	}
	s += vector(segs[20 - 1].origin) ^ vector(segs[0].origin);
	return s / 2;
}

__host__ __device__ double poly::area() const
{
	point max = segs[0].origin, min = segs[0].origin;
	for (int i = 1; i < 20; i++)
	{
		max[0] = (max[0] > segs[i].origin[0]) ? max[0] : segs[i].origin[0];
		max[1] = (max[1] > segs[i].origin[1]) ? max[1] : segs[i].origin[1];
		min[0] = (min[0] < segs[i].origin[0]) ? min[0] : segs[i].origin[0];
		min[1] = (min[1] < segs[i].origin[1]) ? min[1] : segs[i].origin[1];
	}
	double output = 0;
	for (int x = min[0]; x < max[0]; x++)
	{
		seg temp;
		temp.origin = point(x, min[1]);
		temp.dir = vector(0.0, 1.0);
		temp.dist = max[1] - min[1];

		double dist[20];

		for (int i = 0; i < 20; i++)
		{
			double t_1, t_2;
			cross(temp, segs[i], t_1, t_2);
			dist[i] = t_1;
		}
		for (int i = 19; i > 0; i--)
		{
			bool swap = false;
			for (int j = 0; j < i; j++)
			{
				if (dist[j] > dist[j + 1])
				{
					double temp_dist = dist[j];
					dist[j] = dist[j + 1];
					dist[j + 1] = temp_dist;
					swap = true;
				}
			}
			if (!swap)
			{
				break;
			}
		}

		for (int i = 0; i < 10; i++)
		{
			if ((dist[2 * i + 1] == DBL_MAX) || (dist[2 * i] == DBL_MAX))
			{
				break;
			}
			output += dist[2 * i + 1] - dist[2 * i];
		}
	}
	return output;
}

void poly::print(cv::InputOutputArray 图像, double 比例, const cv::Scalar& 颜色, int 粗细) const
{
	//seg(segs[0].origin, segs[1].origin).print(图像, 比例, 颜色, 粗细 * 2);
	for (int i = 0; i < 19; i++)
	{
		seg(segs[i].origin, segs[i + 1].origin).print(图像, 比例, 颜色, 粗细);
	}
	seg(segs[19].origin, segs[0].origin).print(图像, 比例, 颜色, 粗细);
	//segs[0].origin.print(图像, 比例, 颜色, 粗细 * 4);
}

vector poly::move2center()
{
	reset_seg();


	double s = (dir_area() > 0) ? area() : -area();
	double x = 0, y = 0;
	for (int i = 0; i < 19; i++)
	{
		double 积 = segs[i].dir ^ segs[i + 1].dir;
		x += (segs[i].origin[0] + segs[i+1].origin[0]) * 积;
		y += (segs[i].origin[1] + segs[i+1].origin[1]) * 积;
	}
	vector move(x / 6 / s, y / 6 / s);

	for (int i = 0; i < 20; i++)
	{
		segs[i].origin = point(vector(segs[i].origin) + move);
	}

	return move;
}

__host__ __device__ void poly::simple(double 角度, bool rad)
{
	if (!rad)
	{
		角度 = deg2rad(角度);
	}
	double cos_ = cos(角度);

	reset_seg();
	int n = 1;
	while (n != 0)	{

		n = 0;
		for (int i = 0, j = 1; j < 20; j++)
		{
			i = j - 1;

			double cos_t = (vector(0.0, 0.0) - segs[i].dir) * segs[j].dir;
			if ((cos_t < cos_) || (segs[i].dist < 0.0001) || (segs[j].dist < 0.0001))
			{
				continue;
			}

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
		if (cos_t < cos_)
		{
			continue;
		}

		n++;
		for (int j = 0; j < 20 - 1; j++)
		{
			segs[j].origin = segs[j + 1].origin;
		}
		reset_seg();
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
		if (!point_in(other[i].origin))
		{
			return false;
		}
	}
	return true;
}

__host__ __device__ double poly::overlap_area(const poly other) const
{
	return ::overlap_area(*this, other);
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

__host__ __device__ double overlap_area(const poly p_1, const poly p_2)
{
	point max_1 = p_1.segs[0].origin, min_1 = p_1.segs[0].origin;
	for (int i = 1; i < 20; i++)
	{
		max_1[0] = (max_1[0] > p_1.segs[i].origin[0]) ? max_1[0] : p_1.segs[i].origin[0];
		max_1[1] = (max_1[1] > p_1.segs[i].origin[1]) ? max_1[1] : p_1.segs[i].origin[1];
		min_1[0] = (min_1[0] < p_1.segs[i].origin[0]) ? min_1[0] : p_1.segs[i].origin[0];
		min_1[1] = (min_1[1] < p_1.segs[i].origin[1]) ? min_1[1] : p_1.segs[i].origin[1];
	}
	point max_2 = p_2.segs[0].origin, min_2 = p_2.segs[0].origin;
	for (int i = 0; i < 20; i++)
	{
		max_2[0] = (max_2[0] > p_2.segs[i].origin[0]) ? max_2[0] : p_2.segs[i].origin[0];
		max_2[1] = (max_2[1] > p_2.segs[i].origin[1]) ? max_2[1] : p_2.segs[i].origin[1];
		min_2[0] = (min_2[0] < p_2.segs[i].origin[0]) ? min_2[0] : p_2.segs[i].origin[0];
		min_2[1] = (min_2[1] < p_2.segs[i].origin[1]) ? min_2[1] : p_2.segs[i].origin[1];
	}

	point max(fmin(max_1[0], max_2[0]), fmin(max_1[1], max_2[1])), min(fmax(min_1[0], min_2[0]), fmax(min_1[1], min_2[1]));

	double output = 0;
	for (int i = min[0]; i < max[0]; i++)
	{
		ray temp;
		temp.origin = point(i, min[1]);
		temp.dir = vector(0.0, 1.0);

		
		bool in_1 = false, in_2 = false;
		double dist[2][20];
		for (int j = 0; j < 20; j++)
		{
			double t_1, t_2;
			cross(temp, p_1.segs[j], t_1, t_2);
			dist[0][j] = t_1;
			if (t_1 != DBL_MAX)
			{
				in_1 = !in_1;
			}
			cross(temp, p_2.segs[j], t_1, t_2);
			dist[1][j] = t_1;
			if (t_1 != DBL_MAX)
			{
				in_2 = !in_2;
			}
		}
		for (int j = 19; j > 0; j--)
		{
			bool swap = false;
			for (int k = 0; k < j; k++)
			{
				if (dist[0][k] > dist[0][k + 1])
				{
					swap = true;
					double t = dist[0][k];
					dist[0][k + 1] = dist[0][k];
					dist[0][k] = t;
				}
			}
		}
		for (int j = 19; j > 0; j--)
		{
			bool swap = false;
			for (int k = 0; k < j; k++)
			{
				if (dist[1][k] > dist[1][k + 1])
				{
					swap = true;
					double t = dist[1][k];
					dist[1][k + 1] = dist[1][k];
					dist[1][k] = t;
				}
			}
		}

		int j = 0, k = 0;
		while ((j < 20) && (k < 20))
		{
			double next_1 = min[1] + dist[0][j] - temp.origin[1], next_2 = min[1] + dist[1][k] - temp.origin[1];

			if (in_1 && in_2 && ((next_1 != DBL_MAX) || (next_2 != DBL_MAX)))
			{
				output += fmin(next_1, next_2);
			}
			if (next_1 < next_2)
			{
				j++;
				in_1 = !in_1;
			}
			else if (next_1 > next_2)
			{
				k++;
				in_2 = !in_2;
			}
			else
			{
				j++;
				k++;
				in_1 = !in_1;
				in_2 = !in_2;
			}

		}
	}
	return output;
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
