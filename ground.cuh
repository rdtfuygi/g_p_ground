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
	__host__ __device__ ground(point ��[20], int ��_1, int ��_2);
	ground(std::vector<point>& ��, int ��_1, int ��_2);

	__host__ __device__ seg get_door(int i = 0) const;

	__host__ __device__ float area() const;

	void print(cv::InputOutputArray ͼ��, float ����, const cv::Scalar& ��ɫ, int ��ϸ = 1) const;

	void data(std::vector<float>& ����);
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
	__host__ __device__ building(point ��[20], int ��_1, int ��_2, int ����, float Ŀ���С);
	building(std::vector<point>& ��, int ��_1, int ��_2, int ����, float Ŀ���С);
	__host__ __device__ void move(vector �ƶ�, int index);
	__host__ __device__ void move(vector �ƶ�[20]);
	void move(std::vector<vector>& �ƶ�, std::vector<building>& b, ground a,int& n);
	__host__ __device__ void change(point ��, int index);
	__host__ __device__ void change(point ��[20]);

	void data(std::vector<float>& ����);
};


//void ��������(std::vector<building>& ����, std::vector<vector>& �ƶ�);

building ͣ��������(building �ּ���);

extern float
���_Ȩ��,
ƽֱ��_Ȩ��,
����_Ȩ��,
��_Ȩ��,
�ܳ�_Ȩ��;

float ��������(ground ����, std::vector<building>& ����, bool& reset);

void �ֿ����_����(std::vector<float>& �ֿ����, std::vector<float>& ������_, std::vector<float>& ��������_, std::vector<char>& �������, std::vector<float>& �ֿ��޸�);

void ����趨(std::vector<building>& ����, float ������, std::vector<float>& �ֿ����);