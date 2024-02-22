
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>

#include "geometry.cuh"

#include "ground.cuh"

#include <opencv2/core/utils/logger.hpp>

#include <random>


#include <cmath>

#include "other.cuh"

//cudaError_t addWithCuda(int *c, const int *a, const int *b, unsigned int size);
//
//__global__ void addKernel(int *c, const int *a, const int *b)
//{
//    int i = threadIdx.x;
//    c[i] = a[i] + b[i];
//}
//
//int main_()
//{
//    const int arraySize = 5;
//    const int a[arraySize] = { 1, 2, 3, 4, 5 };
//    const int b[arraySize] = { 10, 20, 30, 40, 50 };
//    int c[arraySize] = { 0 };
//
//    // Add vectors in parallel.
//    cudaError_t cudaStatus = addWithCuda(c, a, b, arraySize);
//    if (cudaStatus != cudaSuccess) {
//        fprintf(stderr, "addWithCuda failed!");
//        return 1;
//    }
//
//    printf("{1,2,3,4,5} + {10,20,30,40,50} = {%d,%d,%d,%d,%d}\n",
//        c[0], c[1], c[2], c[3], c[4]);
//
//    // cudaDeviceReset must be called before exiting in order for profiling and
//    // tracing tools such as Nsight and Visual Profiler to show complete traces.
//    cudaStatus = cudaDeviceReset();
//    if (cudaStatus != cudaSuccess) {
//        fprintf(stderr, "cudaDeviceReset failed!");
//        return 1;
//    }
//
//    return 0;
//}
//
//// Helper function for using CUDA to add vectors in parallel.
//cudaError_t addWithCuda(int *c, const int *a, const int *b, unsigned int size)
//{
//    int *dev_a = 0;
//    int *dev_b = 0;
//    int *dev_c = 0;
//    cudaError_t cudaStatus;
//
//    // Choose which GPU to run on, change this on a multi-GPU system.
//    cudaStatus = cudaSetDevice(0);
//    if (cudaStatus != cudaSuccess) {
//        fprintf(stderr, "cudaSetDevice failed!  Do you have a CUDA-capable GPU installed?");
//        goto Error;
//    }
//
//    // Allocate GPU buffers for three vectors (two input, one output)    .
//    cudaStatus = cudaMalloc((void**)&dev_c, size * sizeof(int));
//    if (cudaStatus != cudaSuccess) {
//        fprintf(stderr, "cudaMalloc failed!");
//        goto Error;
//    }
//
//    cudaStatus = cudaMalloc((void**)&dev_a, size * sizeof(int));
//    if (cudaStatus != cudaSuccess) {
//        fprintf(stderr, "cudaMalloc failed!");
//        goto Error;
//    }
//
//    cudaStatus = cudaMalloc((void**)&dev_b, size * sizeof(int));
//    if (cudaStatus != cudaSuccess) {
//        fprintf(stderr, "cudaMalloc failed!");
//        goto Error;
//    }
//
//    // Copy input vectors from host memory to GPU buffers.
//    cudaStatus = cudaMemcpy(dev_a, a, size * sizeof(int), cudaMemcpyHostToDevice);
//    if (cudaStatus != cudaSuccess) {
//        fprintf(stderr, "cudaMemcpy failed!");
//        goto Error;
//    }
//
//    cudaStatus = cudaMemcpy(dev_b, b, size * sizeof(int), cudaMemcpyHostToDevice);
//    if (cudaStatus != cudaSuccess) {
//        fprintf(stderr, "cudaMemcpy failed!");
//        goto Error;
//    }
//
//    // Launch a kernel on the GPU with one thread for each element.
//    addKernel<<<1, size>>>(dev_c, dev_a, dev_b);
//
//    // Check for any errors launching the kernel
//    cudaStatus = cudaGetLastError();
//    if (cudaStatus != cudaSuccess) {
//        fprintf(stderr, "addKernel launch failed: %s\n", cudaGetErrorString(cudaStatus));
//        goto Error;
//    }
//    
//    // cudaDeviceSynchronize waits for the kernel to finish, and returns
//    // any errors encountered during the launch.
//    cudaStatus = cudaDeviceSynchronize();
//    if (cudaStatus != cudaSuccess) {
//        fprintf(stderr, "cudaDeviceSynchronize returned error code %d after launching addKernel!\n", cudaStatus);
//        goto Error;
//    }
//
//    // Copy output vector from GPU buffer to host memory.
//    cudaStatus = cudaMemcpy(c, dev_c, size * sizeof(int), cudaMemcpyDeviceToHost);
//    if (cudaStatus != cudaSuccess) {
//        fprintf(stderr, "cudaMemcpy failed!");
//        goto Error;
//    }
//
//Error:
//    cudaFree(dev_c);
//    cudaFree(dev_a);
//    cudaFree(dev_b);
//    
//    return cudaStatus;
//}





int main()
{
	srand(time(0));
	cv::utils::logging::setLogLevel(cv::utils::logging::LOG_LEVEL_ERROR);



	//m^3
	std::vector<double>年需求量 = { 13950000 };

	std::vector<double>订货成本 = { 10000 };
	std::vector<double>持有成本 = { 10 };

	std::vector<double>需求方差 = { 400 };
	std::vector<double>提前期 = { 0.0004 };
	std::vector<double>提前期方差 = { 0.003 };
	std::vector<double>服务水平 = { 0.95 };

	std::vector<char>库存类型 = { 0 };

	std::vector<double>补货点_(年需求量.size());
	std::vector<double>订货批量_(年需求量.size());


	double 总需求 = 0;
	for (int i = 0; i < 年需求量.size(); i++)
	{
		补货点_[i] = 补货点(年需求量[i], 需求方差[i], 提前期[i], 提前期方差[i], 服务水平[i]);
		订货批量_[i] = 订货批量(年需求量[i], 订货成本[i], 持有成本[i]);


		总需求 += 年需求量[i];
	}

	std::vector<double>仓库面积;
	std::vector<double>仓库限高 = { 30,10,10 };
	仓库面积_计算(仓库面积, 补货点_, 订货批量_, 库存类型, 仓库限高);

	std::vector<building> b;

	面积设定(b, 总需求, 仓库面积);


	int w = 1500, h = 900;
	double 比例 = 1;
	point o(0, 0);


	ground abc;
	while(true)
	{
		for (int i = 0; i < 3; i++)
		{
			abc.site[i] = seg((double(rand()) / RAND_MAX) * 800, (double(rand()) / RAND_MAX) * 800, (double(rand()) / RAND_MAX) * 800, (double(rand()) / RAND_MAX) * 800);
		}
		abc.site.reset_seg();

		cv::Mat a = cv::Mat::zeros(h, w, CV_8UC3);
		abc.print(a, 比例, cv::Scalar(255, 255, 255));




		abc.print(a, 比例, cv::Scalar(255, 255, 255));


		cv::imshow("123", a);
		cv::waitKey(1);

		double s = abc.area();

		printf("%3f\n", s);

		if (abc.site.legal() && (s > 400000))
		{
			break;
		}
	}




	abc.site.move2center();

	cv::Mat a = cv::Mat::zeros(h, w, CV_8UC3);
	abc.print(a, 比例, cv::Scalar(255, 255, 255));

	cv::imshow("123", a);
	cv::waitKey(0);


	double 温度 = 10000;
	double 冷却_率 = 0.999;
	double g = -DBL_MAX;
	while (温度 > 1)
	{
		std::vector<building> b_t = b;
		for (int i = 1; i < b_t.size(); i++)
		{
			for (int j = 0; j < 20; j++)
			{
				b_t[i].site[j].origin = point(vector(b_t[i].site[j].origin) + vector((double(rand()) / RAND_MAX - 0.5) * 2, (double(rand()) / RAND_MAX - 0.5) * 2));
			}
			b_t[i].site.reset_seg();
		}
		b_t[0] = 停车场设置(b_t[1]);
		double g_t = 奖励函数(abc, b_t);
		if (g < g_t)
		{
			b = b_t;
			g = g_t;
		}
		else
		{
			double d = g_t - g;
			if (exp(-d / 温度) > (double(rand()) / RAND_MAX))
			{
				b = b_t;
				g = g_t;
			}
		}
		温度 *= 冷却_率;

		cv::Mat a = cv::Mat::zeros(h, w, CV_8UC3);
		abc.print(a, 比例, cv::Scalar(255, 255, 255));
		for (int i = 0; i < b.size(); i++)
		{
			b[i].print(a, 比例, cv::Scalar(0, 255 / b.size() * i, 0));
		}

		cv::imshow("123", a);
		cv::waitKey(1);
	}
	

	return 0;
}