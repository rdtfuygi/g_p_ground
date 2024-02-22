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

	__host__ __device__ double area() const;

	void print(cv::InputOutputArray 图像, double 比例, const cv::Scalar& 颜色, int 粗细 = 1) const;
};

const int fun_port = 0;
const int fun_sort = 1;
const int fun_ware = 2;
const int fun_cold = 3;
const int fun_freezing = 4;
const int fun_adm = 5;
const int fun_live = 6;
const int fun_port_2 = 7;


class building :public ground
{
public:
	int fun;
	double target_area;
	__host__ __device__ building();
	__host__ __device__ building(point 点[20], int 门_1, int 门_2, int 类型, double 目标大小);
	building(std::vector<point>& 点, int 门_1, int 门_2, int 类型, double 目标大小);
	__host__ __device__ void move(vector 移动, int index);
	__host__ __device__ void move(vector 移动[20]);
	__host__ __device__ void change(point 点, int index);
	__host__ __device__ void change(point 点[20]);


};


void 建筑更改(std::vector<building>& 建筑, std::vector<vector>& 移动);

building 停车场设置(building 分拣区);

double 奖励函数(ground 场地, std::vector<building>& 建筑);

void 仓库面积_计算(std::vector<double>& 仓库面积, std::vector<double>& 补货点_, std::vector<double>& 订货批量_, std::vector<char>& 库存类型, std::vector<double>& 仓库限高);

void 面积设定(std::vector<building>& 建筑, double 总需求, std::vector<double>& 仓库面积);