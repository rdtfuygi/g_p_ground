#pragma once
#define _USE_MATH_DEFINES 

#ifndef geometry
#define geometry
#include "geometry.cuh"
#endif

#include "cuda_runtime.h"
#include "device_launch_parameters.h"


#include <cmath>
#include <vector>
#include <opencv.hpp>

class ground
{
public:
	int door[2];
	poly site;
	__host__ __device__ ground();
	__host__ __device__ ground(point 点[20], int 门_1, int 门_2);
	ground(std::vector<point>& 点, int 门_1, int 门_2);

	__host__ __device__ seg get_door(int i = 0) const;

	__host__ __device__ float area() const;

	void print(cv::InputOutputArray 图像, float 比例, const cv::Scalar& 颜色, int 粗细 = 1) const;

	void data(std::vector<float>& 数据);
};

const int
fun_port = 0,
fun_sort = 1,
fun_ware = 2,
fun_cold = 3,
fun_freezing = 4,
fun_adm = 5,
fun_live = 6,
fun_port_2 = 7;


class building :public ground
{
public:
	int fun;
	float target_area;
	__host__ __device__ building();
	__host__ __device__ building(point 点[20], int 门_1, int 门_2, int 类型, float 目标大小);
	building(std::vector<point>& 点, int 门_1, int 门_2, int 类型, float 目标大小);
	__host__ __device__ void move(vector 移动, int index);
	__host__ __device__ void move(vector 移动[20]);
	void move(std::vector<vector>& 移动, std::vector<building>& b, ground a,int& n);
	__host__ __device__ void change(point 点, int index);
	__host__ __device__ void change(point 点[20]);

	void data(std::vector<float>& 数据);
};


//void 建筑更改(std::vector<building>& 建筑, std::vector<vector>& 移动);

building 停车场设置(building 分拣区);

extern float
面积_权重,
平直角_权重,
距离_权重,
门_权重,
周长_权重;

float 奖励函数(ground 场地, std::vector<building>& 建筑, bool& reset);

void 仓库面积_计算(std::vector<float>& 仓库面积, std::vector<float>& 补货点_, std::vector<float>& 订货批量_, std::vector<char>& 库存类型, std::vector<float>& 仓库限高);

void 面积设定(std::vector<building>& 建筑, float 总需求, std::vector<float>& 仓库面积);