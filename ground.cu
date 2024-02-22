#include"ground.cuh"

#define _USE_MATH_DEFINES 
#include <math.h>

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

__host__ __device__ double ground::area() const
{
	return abs(site.area());
}

void ground::print(cv::InputOutputArray 图像, double 比例, const cv::Scalar& 颜色, int 粗细) const
{
	site.print(图像, 比例, 颜色, 粗细);
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




__global__ void building_move(building* 建筑, vector* 移动, int 尺寸)
{
	int i = threadIdx.x + blockIdx.x * blockDim.x;
	if (i >= 尺寸)
	{
		return;
	}
	建筑[i / 20].move(移动[i], i % 20);
}

__global__ void building_reset_seg(building* 建筑, int 尺寸)
{
	int i = threadIdx.x + blockIdx.x * blockDim.x;
	if (i >= 尺寸)
	{
		return;
	}
	建筑[i / 20].site.reset_seg(i % 20);
}

void 建筑更改(std::vector<building>& 建筑, std::vector<vector>& 移动)
{
	int cuda设备数量;
	cudaGetDeviceCount(&cuda设备数量);
	if (cuda设备数量 == 0)
	{
		for (int i = 0; i < 建筑.size(); i++)
		{
			for (int j = 0; j < 移动.size(); j++)
			{
				建筑[i].move(移动[i * 20 + j], j);
			}
			建筑[i].site.reset_seg();
		}
	}
	else
	{
		int 显卡id;
		cudaGetDevice(&显卡id);
		cudaDeviceProp 显卡属性;
		cudaGetDeviceProperties(&显卡属性, 显卡id);
		int 每块线程 = 显卡属性.maxThreadsPerBlock;
		int 块数 = 移动.size() / 每块线程 + 1;

		building* 建筑_dev = NULL;//
		vector* 移动_dev = NULL;//
		cudaMalloc((void**)建筑_dev, sizeof(building) * 建筑.size());
		cudaMalloc((void**)移动_dev, sizeof(vector) * 移动.size());
		cudaMemcpy(建筑_dev, 建筑.data(), sizeof(building) * 建筑.size(), cudaMemcpyHostToDevice);
		cudaMemcpy(移动_dev, 建筑.data(), sizeof(vector) * 移动.size(), cudaMemcpyHostToDevice);

		building_move << < 块数, 每块线程 >> > (建筑_dev, 移动_dev, 移动.size());

		cudaFree(移动_dev);

		building_reset_seg << < 块数, 每块线程 >> > (建筑_dev, 移动.size());

		cudaMemcpy(建筑.data(), 建筑_dev, sizeof(building) * 建筑.size(), cudaMemcpyDeviceToHost);
		cudaFree(建筑_dev);
	}
}

building 停车场设置(building 分拣区)
{
	seg 平行[5];
	double 旋转 = 90;
	if (分拣区.site.area() > 0)
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



const char 关联表[6][6] =
{
	{0, 4, 2, 2, 0, 0},
	{4, 0, 0,-1, 0, 0},
	{2, 0, 0,-1, 0, 0},
	{2,-1,-1, 0,-1,-1},
	{0, 0, 0,-1, 0, 3},
	{0, 0, 0,-1, 3,	0}
};


double 奖励函数(ground 场地, std::vector<building>& 建筑)
{
	double 分数 = 0;

	const double
		场地内_权重 = 10000,
		面积_权重 = -1,
		平直角_权重 = 10,
		距离_权重 = 10;


	for (int i = 0; i < 建筑.size(); i++)
	{
		if (场地.site.full_overlap(建筑[i].site))
		{
			分数 += 场地内_权重;
		}

		if(建筑[i].fun!=fun_port)
		{
			分数 += pow(建筑[i].area() - 建筑[i].target_area, 2) * 面积_权重;
		}

		for (int j = 0; j < 20; j++)
		{
			分数 += (fmax(abs(建筑[i].site[j].dir * 建筑[i].site[(j + 1) % 20].dir), abs(建筑[i].site[j].dir ^ 建筑[i].site[(j + 1) % 20].dir)) - M_SQRT1_2) * 平直角_权重;
		}

		for (int j = 0; j < i; j++)
		{
			if ((建筑[i].fun != fun_port) && (建筑[j].fun != fun_port))
			{
				分数 += -dist(建筑[i].site, 建筑[j].site) * 距离_权重 * 关联表[i][j];
			}
		}
	}
	return 分数;
}
