#include"ground.cuh"

//#define _USE_MATH_DEFINES 
//#include <cmath>

__host__ __device__ ground::ground() :site(), door() {}

__host__ __device__ ground::ground(point 点[20], int 门_1, int 门_2) : site(点)
{
	door[0] = 门_1;
	door[1] = 门_2;
}

ground::ground(std::vector<point>& 点, int 门_1, int 门_2) : site(点)
{
	door[0] = 门_1;
	door[1] = 门_2;
}

__host__ __device__ seg ground::get_door(int i) const
{
	return site[door[i]];
}

__host__ __device__ double ground::area() const
{
	return site.area();
}

void ground::print(cv::InputOutputArray 图像, double 比例, const cv::Scalar& 颜色, int 粗细) const
{
	site.print(图像, 比例, 颜色, 粗细);
	get_door(0).print(图像, 比例, 颜色, 粗细 * 2);
	get_door(1).print(图像, 比例, 颜色, 粗细 * 2);
	//site.center().print(图像, 比例, 颜色, 粗细);
}

void ground::data(std::vector<double>& 数据)
{
	数据 = std::vector<double>();
	数据.reserve(103);
	for (int i = 0; i < 20; i++)
	{
		数据.push_back(site[i].origin[0]);
		数据.push_back(site[i].origin[1]);
		数据.push_back(site[i].dir[0]);
		数据.push_back(site[i].dir[1]);
		数据.push_back(site[i].dist);
	}
	数据.push_back(double(door[0]));
	数据.push_back(double(door[1]));
	数据.push_back(area());
}


building::building() :ground(), fun(0), target_area(0) {}

building::building(point 点[20], int 门_1, int 门_2, int 类型, double 目标大小) :ground(点, 门_1, 门_2), fun(类型), target_area(目标大小) {}

building::building(std::vector<point>& 点, int 门_1, int 门_2, int 类型, double 目标大小) :ground(点, 门_1, 门_2), fun(类型), target_area(目标大小) {}

__host__ __device__ void building::move(vector 移动, int index)
{
	site[index].origin = point(vector(site[index].origin) + 移动);
}

__host__ __device__ void building::move(vector 移动[20])
{
	for (int i = 0; i < 20; i++)
	{
		move(移动[i], i);
	}
	site.reset_seg();
}

void building::move(std::vector<vector>& 移动, std::vector<building>& b, ground a, int& n)
{
	for (int i = 0; i < 20; i++)
	{
		poly temp = site;
		move(移动[i], i);

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

__host__ __device__ void building::change(point 点, int index)
{
	site[index].origin = 点;
}

__host__ __device__ void building::change(point 点[20])
{
	for (int i = 0; i < 20; i++)
	{
		change(点[i], i);
	}
	site.reset_seg();
}

void building::data(std::vector<double>& 数据)
{
	数据 = std::vector<double>();
	数据.reserve(106);
	point 重心 = site.center();
	数据.push_back(重心[0] / 1024);
	数据.push_back(重心[1] / 1024);
	for (int i = 0; i < 20; i++)
	{
		数据.push_back(site[i].origin[0]);
		数据.push_back(site[i].origin[1]);
		数据.push_back(site[i].dir[0]);
		数据.push_back(site[i].dir[1]);
		数据.push_back(site[i].dist);
	}
	数据.push_back(double(door[0]));
	数据.push_back(double(door[1]));
	数据.push_back(area());
	数据.push_back(target_area);
}




//__global__ void building_move(building* 建筑, vector* 移动, int 尺寸)
//{
//	int i = threadIdx.x + blockIdx.x * blockDim.x;
//	if (i >= 尺寸)
//	{
//		return;
//	}
//	建筑[i / 20].move(移动[i], i % 20);
//}
//
//__global__ void building_reset_seg(building* 建筑, int 尺寸)
//{
//	int i = threadIdx.x + blockIdx.x * blockDim.x;
//	if (i >= 尺寸)
//	{
//		return;
//	}
//	建筑[i / 20].site.reset_seg(i % 20);
//}
//
//void 建筑更改(std::vector<building>& 建筑, std::vector<vector>& 移动)
//{
//	int cuda设备数量;
//	cudaGetDeviceCount(&cuda设备数量);
//	if (cuda设备数量 == 0)
//	{
//		for (int i = 0; i < 建筑.size(); i++)
//		{
//			for (int j = 0; j < 移动.size(); j++)
//			{
//				建筑[i].move(移动[i * 20 + j], j);
//			}
//			建筑[i].site.reset_seg();
//		}
//	}
//	else
//	{
//		int 显卡id;
//		cudaGetDevice(&显卡id);
//		cudaDeviceProp 显卡属性;
//		cudaGetDeviceProperties(&显卡属性, 显卡id);
//		int 每块线程 = 显卡属性.maxThreadsPerBlock;
//		int 块数 = 移动.size() / 每块线程 + 1;
//
//		building* 建筑_dev = NULL;//
//		vector* 移动_dev = NULL;//
//		cudaMalloc((void**)建筑_dev, sizeof(building) * 建筑.size());
//		cudaMalloc((void**)移动_dev, sizeof(vector) * 移动.size());
//		cudaMemcpy(建筑_dev, 建筑.data(), sizeof(building) * 建筑.size(), cudaMemcpyHostToDevice);
//		cudaMemcpy(移动_dev, 建筑.data(), sizeof(vector) * 移动.size(), cudaMemcpyHostToDevice);
//
//		building_move << < 块数, 每块线程 >> > (建筑_dev, 移动_dev, 移动.size());
//
//		cudaFree(移动_dev);
//
//		building_reset_seg << < 块数, 每块线程 >> > (建筑_dev, 移动.size());
//
//		cudaMemcpy(建筑.data(), 建筑_dev, sizeof(building) * 建筑.size(), cudaMemcpyDeviceToHost);
//		cudaFree(建筑_dev);
//	}
//}

building 停车场设置(building 分拣区)
{
	seg 平行[5];
	double 旋转 = 90;
	if (分拣区.site.dir_area() > 0)
	{
		旋转 = -90;
	}

	for (int i = 0; i < 5; i++)
	{
		平行[i].origin = rotate(分拣区.site[i].origin, 分拣区.site[i].point_get(27), 旋转);
		平行[i].dir = 分拣区.site[i].dir;
		平行[i].dist = 分拣区.site[i].dist;
	}



	point 点[20];
	for (int i = 0; i < 5; i++)
	{
		点[i] = 分拣区.site[i].origin;
	}
	点[5] = 平行[4].end();
	for (int i = 1; i < 4; i++)
	{
		点[i + 5] = cross(line(平行[5 - i]), line(平行[5 - i - 1]));
	}
	点[9] = 平行[0].origin;

	for (int i = 10; i < 20; i++)
	{
		点[i] = 点[0];
	}


	return building(点, 0, 4, fun_port, 0);
}



const char 关联表[8][8] =
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
面积_权重 = 0,
平直角_权重 = 0,
距离_权重 = 0,
门_权重 = 0,
周长_权重 = 0;

double 奖励函数(ground 场地, std::vector<building>& 建筑, bool& reset)
{
	double 分数 = 0;




	for (int i = 0; i < 建筑.size(); i++)
	{
		double 面积 = 建筑[i].area();

		//if (场地.site.full_overlap(建筑[i].site))
		//{
		//	分数 += 场地内_权重;
		//}
		//else
		//{
		//	double a = fmin(1, pow(overlap_area(场地.site, 建筑[i].site) / 面积, 2));
		//	分数 += 场地内_权重 * a / 2;
		//	reset = true;
		//}

		for (int j = 0; j < i; j++)
		{
			//if (!建筑[i].site.is_overlap(建筑[j].site))
			//{
			//	分数 += 重叠_权重 / 28 * 8;
			//}
			//else
			//{
			//	double a = (1 - fmin(1, pow(overlap_area(建筑[j].site, 建筑[i].site) / 面积, 2)));
			//	分数 += 重叠_权重 * a / 2 / 28 * 8;
			//	reset = true;
			//}

			if (关联表[建筑[i].fun][建筑[j].fun] >= 0)
			{
				分数 += exp(-dist(建筑[i].site, 建筑[j].site) * 关联表[建筑[i].fun][建筑[j].fun] / 100) * 距离_权重 / 28 * 8;

				分数 += exp(-fmin(dist(建筑[j].site, 建筑[i].get_door(0)), dist(建筑[j].site, 建筑[i].get_door(1))) * 关联表[建筑[i].fun][建筑[j].fun] / 100) * 门_权重 / 28 * 8;
			}
			else
			{
				分数 += (1 - exp(-dist(建筑[i].site, 建筑[j].site)) / 100) * 距离_权重 / 28 * 8;

				分数 += (1 - exp(-fmin(dist(建筑[j].site, 建筑[i].get_door(0)), dist(建筑[j].site, 建筑[i].get_door(1))) / 100)) * 门_权重 / 28 * 8;
			}
		}

		分数 += -pow((建筑[i].target_area - 面积) / 1048576, 2) * 面积_权重;

		double 周长 = 0;
		for (int j = 0; j < 20; j++)
		{
			double a = fmax(fmax((建筑[i].site[j].dir * 建筑[i].site[(j + 1) % 20].dir), 0), abs(建筑[i].site[j].dir ^ 建筑[i].site[(j + 1) % 20].dir));
			分数 += (a + pow(a, 16)) / 2 / 20 * 平直角_权重;

			周长 += 建筑[i].site[j].dist;

			if (a < M_SQRT1_2)
			{
				reset = true;
			}
		}

		分数 += (4 * sqrt(面积) - fmax(周长, 4 * sqrt(面积))) / 1024 * 周长_权重;

		//if (建筑[i].site.legal())
		//{
		//	分数 += 合法_权重;
		//}
		//else
		//{
		//	double a = fmin(1, pow(建筑[i].site.dir_area() / 面积, 2));
		//	分数 += 合法_权重 * a / 2;
		//	reset = true;
		//}
	}
	return 分数 / 8;
}

void 仓库面积_计算(std::vector<double>& 仓库面积, std::vector<double>& 补货点_, std::vector<double>& 订货批量_, std::vector<char>& 库存类型, std::vector<double>& 仓库限高)
{
	仓库面积 = { 0,0,0 };
	for (int i = 0; i < 补货点_.size(); i++)
	{
		仓库面积[库存类型[i]] += (补货点_[i] + 订货批量_[i]) / 仓库限高[库存类型[i]];
	}
}

void 面积设定(std::vector<building>& 建筑, double 总需求, std::vector<double>& 仓库面积)
{
	建筑 = std::vector<building>(8);

	建筑[0].target_area = 总需求 / 30 / 365 / 24 * 3 * 35;
	建筑[1].target_area = 总需求 / 30 / 365 / 24 * 3 * 20;
	建筑[2].target_area = 仓库面积[0] * 1.7;
	建筑[3].target_area = 仓库面积[1] * 1.7;
	建筑[4].target_area = 仓库面积[2] * 1.7;
	建筑[5].target_area = 5000;
	建筑[6].target_area = 总需求 / 30 / 365 / 24 * (3 + 2) * 10;
	建筑[7].target_area = (500 * 0.7 + 总需求 / 30 / 365 / 24 * 3 * 0.3) * 40;

	for (int i = 0; i < 建筑.size(); i++)
	{
		建筑[i].fun = i;
	}
}
