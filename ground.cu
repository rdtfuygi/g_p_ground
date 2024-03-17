#include"ground.cuh"

//#define _USE_MATH_DEFINES 
//#include <cmath>

__host__ __device__ ground::ground() :site(), door() {}

__host__ __device__ ground::ground(point ��[20], int ��_1, int ��_2) : site(��)
{
	door[0] = ��_1;
	door[1] = ��_2;
}

ground::ground(std::vector<point>& ��, int ��_1, int ��_2) : site(��)
{
	door[0] = ��_1;
	door[1] = ��_2;
}

__host__ __device__ seg ground::get_door(int i) const
{
	return site[door[i]];
}

__host__ __device__ double ground::area() const
{
	return site.area();
}

void ground::print(cv::InputOutputArray ͼ��, double ����, const cv::Scalar& ��ɫ, int ��ϸ) const
{
	site.print(ͼ��, ����, ��ɫ, ��ϸ);
	get_door(0).print(ͼ��, ����, ��ɫ, ��ϸ * 2);
	get_door(1).print(ͼ��, ����, ��ɫ, ��ϸ * 2);
	//site.center().print(ͼ��, ����, ��ɫ, ��ϸ);
}

void ground::data(std::vector<double>& ����)
{
	���� = std::vector<double>();
	����.reserve(103);
	for (int i = 0; i < 20; i++)
	{
		����.push_back(site[i].origin[0]);
		����.push_back(site[i].origin[1]);
		����.push_back(site[i].dir[0]);
		����.push_back(site[i].dir[1]);
		����.push_back(site[i].dist);
	}
	����.push_back(double(door[0]));
	����.push_back(double(door[1]));
	����.push_back(area());
}


building::building() :ground(), fun(0), target_area(0) {}

building::building(point ��[20], int ��_1, int ��_2, int ����, double Ŀ���С) :ground(��, ��_1, ��_2), fun(����), target_area(Ŀ���С) {}

building::building(std::vector<point>& ��, int ��_1, int ��_2, int ����, double Ŀ���С) :ground(��, ��_1, ��_2), fun(����), target_area(Ŀ���С) {}

__host__ __device__ void building::move(vector �ƶ�, int index)
{
	site[index].origin = point(vector(site[index].origin) + �ƶ�);
}

__host__ __device__ void building::move(vector �ƶ�[20])
{
	for (int i = 0; i < 20; i++)
	{
		move(�ƶ�[i], i);
	}
	site.reset_seg();
}

void building::move(std::vector<vector>& �ƶ�, std::vector<building>& b, ground a, int& n)
{
	for (int i = 0; i < 20; i++)
	{
		poly temp = site;
		move(�ƶ�[i], i);

		site.reset_seg();

		bool m = true;

		if (((site[(i + 1) % 20].dir * site[i % 20].dir) < -M_SQRT1_2) || ((site[i].dir * site[(i + 19) % 20].dir) < -M_SQRT1_2) || ((site[(i + 19) % 20].dir * site[(i + 18) % 20].dir) < -M_SQRT1_2))
		{
			m = false;
		}
		else if (!site.legal())
		{
			m = false;
		}
		else if (!a.site.full_overlap(site))
		{
			m = false;
		}
		else
		{
			for (int j = 0; j < 8; j++)
			{
				if(j!=fun)
				{
					if (site.is_overlap(b[j].site))
					{
						m = false;
						break;
					}
				}
			}
		}



		if (!m)
		{
			n++;
			site = temp;
		}
	}
}

__host__ __device__ void building::change(point ��, int index)
{
	site[index].origin = ��;
}

__host__ __device__ void building::change(point ��[20])
{
	for (int i = 0; i < 20; i++)
	{
		change(��[i], i);
	}
	site.reset_seg();
}

void building::data(std::vector<double>& ����)
{
	���� = std::vector<double>();
	����.reserve(106);
	point ���� = site.center();
	����.push_back(����[0] / 1024);
	����.push_back(����[1] / 1024);
	for (int i = 0; i < 20; i++)
	{
		����.push_back(site[i].origin[0]);
		����.push_back(site[i].origin[1]);
		����.push_back(site[i].dir[0]);
		����.push_back(site[i].dir[1]);
		����.push_back(site[i].dist);
	}
	����.push_back(double(door[0]));
	����.push_back(double(door[1]));
	����.push_back(area());
	����.push_back(target_area);
}




//__global__ void building_move(building* ����, vector* �ƶ�, int �ߴ�)
//{
//	int i = threadIdx.x + blockIdx.x * blockDim.x;
//	if (i >= �ߴ�)
//	{
//		return;
//	}
//	����[i / 20].move(�ƶ�[i], i % 20);
//}
//
//__global__ void building_reset_seg(building* ����, int �ߴ�)
//{
//	int i = threadIdx.x + blockIdx.x * blockDim.x;
//	if (i >= �ߴ�)
//	{
//		return;
//	}
//	����[i / 20].site.reset_seg(i % 20);
//}
//
//void ��������(std::vector<building>& ����, std::vector<vector>& �ƶ�)
//{
//	int cuda�豸����;
//	cudaGetDeviceCount(&cuda�豸����);
//	if (cuda�豸���� == 0)
//	{
//		for (int i = 0; i < ����.size(); i++)
//		{
//			for (int j = 0; j < �ƶ�.size(); j++)
//			{
//				����[i].move(�ƶ�[i * 20 + j], j);
//			}
//			����[i].site.reset_seg();
//		}
//	}
//	else
//	{
//		int �Կ�id;
//		cudaGetDevice(&�Կ�id);
//		cudaDeviceProp �Կ�����;
//		cudaGetDeviceProperties(&�Կ�����, �Կ�id);
//		int ÿ���߳� = �Կ�����.maxThreadsPerBlock;
//		int ���� = �ƶ�.size() / ÿ���߳� + 1;
//
//		building* ����_dev = NULL;//
//		vector* �ƶ�_dev = NULL;//
//		cudaMalloc((void**)����_dev, sizeof(building) * ����.size());
//		cudaMalloc((void**)�ƶ�_dev, sizeof(vector) * �ƶ�.size());
//		cudaMemcpy(����_dev, ����.data(), sizeof(building) * ����.size(), cudaMemcpyHostToDevice);
//		cudaMemcpy(�ƶ�_dev, ����.data(), sizeof(vector) * �ƶ�.size(), cudaMemcpyHostToDevice);
//
//		building_move << < ����, ÿ���߳� >> > (����_dev, �ƶ�_dev, �ƶ�.size());
//
//		cudaFree(�ƶ�_dev);
//
//		building_reset_seg << < ����, ÿ���߳� >> > (����_dev, �ƶ�.size());
//
//		cudaMemcpy(����.data(), ����_dev, sizeof(building) * ����.size(), cudaMemcpyDeviceToHost);
//		cudaFree(����_dev);
//	}
//}

building ͣ��������(building �ּ���)
{
	seg ƽ��[5];
	double ��ת = 90;
	if (�ּ���.site.dir_area() > 0)
	{
		��ת = -90;
	}

	for (int i = 0; i < 5; i++)
	{
		ƽ��[i].origin = rotate(�ּ���.site[i].origin, �ּ���.site[i].point_get(27), ��ת);
		ƽ��[i].dir = �ּ���.site[i].dir;
		ƽ��[i].dist = �ּ���.site[i].dist;
	}



	point ��[20];
	for (int i = 0; i < 5; i++)
	{
		��[i] = �ּ���.site[i].origin;
	}
	��[5] = ƽ��[4].end();
	for (int i = 1; i < 4; i++)
	{
		��[i + 5] = cross(line(ƽ��[5 - i]), line(ƽ��[5 - i - 1]));
	}
	��[9] = ƽ��[0].origin;

	for (int i = 10; i < 20; i++)
	{
		��[i] = ��[0];
	}


	return building(��, 0, 4, fun_port, 0);
}



const char ������[8][8] =
{
	{0, 4, 0, 0, 0, 3, 0, 0},
	{4, 0, 4, 2, 2, 0, 0, 0},
	{0, 4, 0, 0,-1, 0, 0, 0},
	{0, 2, 0, 0,-1, 0, 0, 0},
	{0, 2,-1,-1, 0,-1,-1, 0},
	{3, 0, 0, 0,-1, 0, 3, 1},
	{0, 0, 0, 0,-1, 3, 0, 4},
	{0, 0, 0, 0, 0, 1, 4, 0}
};

double
���_Ȩ�� = 0,
ƽֱ��_Ȩ�� = 0,
����_Ȩ�� = 0,
��_Ȩ�� = 0,
�ܳ�_Ȩ�� = 0;

double ��������(ground ����, std::vector<building>& ����, bool& reset)
{
	double ���� = 0;




	for (int i = 0; i < ����.size(); i++)
	{
		double ��� = ����[i].area();

		//if (����.site.full_overlap(����[i].site))
		//{
		//	���� += ������_Ȩ��;
		//}
		//else
		//{
		//	double a = fmin(1, pow(overlap_area(����.site, ����[i].site) / ���, 2));
		//	���� += ������_Ȩ�� * a / 2;
		//	reset = true;
		//}

		for (int j = 0; j < i; j++)
		{
			//if (!����[i].site.is_overlap(����[j].site))
			//{
			//	���� += �ص�_Ȩ�� / 28 * 8;
			//}
			//else
			//{
			//	double a = (1 - fmin(1, pow(overlap_area(����[j].site, ����[i].site) / ���, 2)));
			//	���� += �ص�_Ȩ�� * a / 2 / 28 * 8;
			//	reset = true;
			//}

			if (������[����[i].fun][����[j].fun] >= 0)
			{
				���� += exp(-dist(����[i].site, ����[j].site) * ������[����[i].fun][����[j].fun] / 100) * ����_Ȩ�� / 28 * 8;

				���� += exp(-fmin(dist(����[j].site, ����[i].get_door(0)), dist(����[j].site, ����[i].get_door(1))) * ������[����[i].fun][����[j].fun] / 100) * ��_Ȩ�� / 28 * 8;
			}
			else
			{
				���� += (1 - exp(-dist(����[i].site, ����[j].site)) / 100) * ����_Ȩ�� / 28 * 8;

				���� += (1 - exp(-fmin(dist(����[j].site, ����[i].get_door(0)), dist(����[j].site, ����[i].get_door(1))) / 100)) * ��_Ȩ�� / 28 * 8;
			}
		}

		���� += -pow((����[i].target_area - ���) / 1048576, 2) * ���_Ȩ��;

		double �ܳ� = 0;
		for (int j = 0; j < 20; j++)
		{
			double a = fmax(fmax((����[i].site[j].dir * ����[i].site[(j + 1) % 20].dir), 0), abs(����[i].site[j].dir ^ ����[i].site[(j + 1) % 20].dir));
			���� += (a + pow(a, 16)) / 2 / 20 * ƽֱ��_Ȩ��;

			�ܳ� += ����[i].site[j].dist;

			if (a < M_SQRT1_2)
			{
				reset = true;
			}
		}

		���� += (4 * sqrt(���) - fmax(�ܳ�, 4 * sqrt(���))) / 1024 * �ܳ�_Ȩ��;

		//if (����[i].site.legal())
		//{
		//	���� += �Ϸ�_Ȩ��;
		//}
		//else
		//{
		//	double a = fmin(1, pow(����[i].site.dir_area() / ���, 2));
		//	���� += �Ϸ�_Ȩ�� * a / 2;
		//	reset = true;
		//}
	}
	return ���� / 8;
}

void �ֿ����_����(std::vector<double>& �ֿ����, std::vector<double>& ������_, std::vector<double>& ��������_, std::vector<char>& �������, std::vector<double>& �ֿ��޸�)
{
	�ֿ���� = { 0,0,0 };
	for (int i = 0; i < ������_.size(); i++)
	{
		�ֿ����[�������[i]] += (������_[i] + ��������_[i]) / �ֿ��޸�[�������[i]];
	}
}

void ����趨(std::vector<building>& ����, double ������, std::vector<double>& �ֿ����)
{
	���� = std::vector<building>(8);

	����[0].target_area = ������ / 30 / 365 / 24 * 3 * 35;
	����[1].target_area = ������ / 30 / 365 / 24 * 3 * 20;
	����[2].target_area = �ֿ����[0] * 1.7;
	����[3].target_area = �ֿ����[1] * 1.7;
	����[4].target_area = �ֿ����[2] * 1.7;
	����[5].target_area = 5000;
	����[6].target_area = ������ / 30 / 365 / 24 * (3 + 2) * 10;
	����[7].target_area = (500 * 0.7 + ������ / 30 / 365 / 24 * 3 * 0.3) * 40;

	for (int i = 0; i < ����.size(); i++)
	{
		����[i].fun = i;
	}
}
