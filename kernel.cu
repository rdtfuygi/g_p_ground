
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>

#include "geometry.cuh"

#include "ground.cuh"

#include <opencv2/core/utils/logger.hpp>

#include <random>


#include <cmath>

#include "other.cuh"
#include "pipe.cuh"

//cudaError_t addWithCuda(int *c, const int *p, const int *b, unsigned int size);
//
//__global__ void addKernel(int *c, const int *p, const int *b)
//{
//    int i = threadIdx.x;
//    c[i] = p[i] + b[i];
//}
//
//int main_()
//{
//    const int arraySize = 5;
//    const int p[arraySize] = { 1, 2, 3, 4, 5 };
//    const int b[arraySize] = { 10, 20, 30, 40, 50 };
//    int c[arraySize] = { 0 };
//
//    // Add vectors in parallel.
//    cudaError_t cudaStatus = addWithCuda(c, p, b, arraySize);
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
//cudaError_t addWithCuda(int *c, const int *p, const int *b, unsigned int size)
//{
//    int *dev_a = 0;
//    int *dev_b = 0;
//    int *dev_c = 0;
//    cudaError_t cudaStatus;
//
//    // Choose which GPU to run on, change this on p multi-GPU system.
//    cudaStatus = cudaSetDevice(0);
//    if (cudaStatus != cudaSuccess) {
//        fprintf(stderr, "cudaSetDevice failed!  Do you have p CUDA-capable GPU installed?");
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
//    cudaStatus = cudaMemcpy(dev_a, p, size * sizeof(int), cudaMemcpyHostToDevice);
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
//    // Launch p kernel on the GPU with one thread for each element.
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



	////m^3
	//std::vector<double>年需求量 = { 13950000,13950000 * 0.3,13950000 * 0.2 };
	//
	//std::vector<double>订货成本 = { 10000,10000,10000 };
	//std::vector<double>持有成本 = { 10,20,30 };
	//
	//std::vector<double>需求方差 = { 400,100,100 };
	//std::vector<double>提前期 = { 0.0004,0.0003,0.0003 };
	//std::vector<double>提前期方差 = { 0.003,0.003,0.003 };
	//std::vector<double>服务水平 = { 0.95,0.95,0.95 };
	//
	//std::vector<char>库存类型 = { 0,1,2 };
	//
	//std::vector<double>补货点_(年需求量.size());
	//std::vector<double>订货批量_(年需求量.size());
	//
	//
	//double 总需求 = 0;
	//for (int i = 0; i < 年需求量.size(); i++)
	//{
	//	补货点_[i] = 补货点(年需求量[i], 需求方差[i], 提前期[i], 提前期方差[i], 服务水平[i]);
	//	订货批量_[i] = 订货批量(年需求量[i], 订货成本[i], 持有成本[i]);
	//
	//
	//	总需求 += 年需求量[i];
	//}
	//
	//std::vector<double>仓库面积;
	//std::vector<double>仓库限高 = { 30,10,10 };
	//仓库面积_计算(仓库面积, 补货点_, 订货批量_, 库存类型, 仓库限高);
	//
	//std::vector<building> b;
	//
	//面积设定(b, 总需求, 仓库面积);


	int w = 900, h = 900;
	double 比例 = 1;
	point o(0, 0);


	pipe output_pip("asd_out", 8192);
	pipe input_pip("asd_in");
	pipe callback_pip("asd_back");


	wchar_t command[] = L"python D:\\Users\\57247\\OneDrive\\Desktop\\g_p\\g_p_ground_ai\\g_p_ground_ai.py asd";
	STARTUPINFOW si = { 0 };
	PROCESS_INFORMATION pi = { 0 };
	CreateProcessW
	(
		NULL,
		command,
		NULL,
		NULL,
		FALSE,
		NULL,
		NULL,
		NULL,
		&si,
		&pi
	);

	vector 初始解[8] = { vector(0.0,0.0),vector(0.0,-1.0),vector(0.0,-2.0),vector(1.0,-2.0),vector(1.0,-1.0),vector(-1.0,1.0),vector(-1.0,-1.0),vector(-1.0,0.0) };

	while(true)
	{
		ground a;
		cv::Mat p;
		while (true)
		{
			a = 场地设定(double(rand()) / RAND_MAX * 200000 + 200000);
			a.site.move2center();

			p = cv::Mat::zeros(h, w, CV_8UC3);
			a.print(p, 比例, cv::Scalar(255, 255, 255));

			cv::imshow("123", p);
			cv::waitKey(1000);
			if (cv::waitKey(3000) != 'r')
			{
				break;
			}
		}

		double s = a.area();

		std::vector<building> b(8);



		for (int i = 0; i < b.size(); i++)
		{
			b[i].fun = i;
			for (int j = 0; j < 20; j++)
			{
				b[i].site[j].origin = point(vector(b[i].site[j].origin) + ((初始解[b[i].fun]) * 50) + ((vector(1.0, 0.0).rotate(18 * j + 45)) * 10));
			}


			b[i].site.reset_seg();

			b[i].target_area = double(rand()) / RAND_MAX * s * 0.125;
		}

		//double 温度 = 10000;
		//double 冷却_率 = 0.999;
		//double g = -DBL_MAX;
		//while (温度 > 1)
		//{
		//	std::vector<building> b_t = b;
		//	for (int i = 0; i < b_t.size(); i++)
		//	{
		//		for (int j = 0; j < 20; j++)
		//		{
		//			b_t[i].site[j].origin = point(vector(b_t[i].site[j].origin) + vector((double(rand()) / RAND_MAX - 0.5) * 2, (double(rand()) / RAND_MAX - 0.5) * 2));
		//		}
		//
		//		b_t[i].site.reset_seg();
		//		//b_t[0] = 停车场设置(b_t[1]);
		//		double g_t = 奖励函数(a, b_t);
		//		printf("%3f\n", g_t);
		//		if (g < g_t)
		//		{
		//			b = b_t;
		//			g = g_t;
		//		}
		//		else
		//		{
		//			double d = g_t - g;
		//			if (exp(-d / 温度) > (double(rand()) / RAND_MAX))
		//			{
		//				b = b_t;
		//				g = g_t;
		//			}
		//		}
		//		cv::Mat p = cv::Mat::zeros(h, w, CV_8UC3);
		//		a.print(p, 比例, cv::Scalar(255, 255, 255));
		//		for (int i = 0; i < b.size(); i++)
		//		{
		//			b[i].print(p, 比例, cv::Scalar(255, 255 / b.size() * i, 0));
		//		}
		//		cv::imshow("123", p);
		//		cv::waitKey(1);
		//	}
		//	温度 *= 冷却_率;
		//}

		for (int i = 0; i < b.size(); i++)
		{
			b[i].print(p, 比例, cv::Scalar(255, 255 / b.size() * i, 0));
		}

		cv::imshow("123", p);
		cv::waitKey(1);

		while(true)
		{
			std::vector<double> output;
			output.reserve(926);
			std::vector<double> a_data;
			a.data(a_data);
			output.insert(output.end(), a_data.begin(), a_data.end());
			for (int i = 0; i < b.size(); i++)
			{
				std::vector<double> b_data;
				b[i].data(b_data);
				output.insert(output.end(), b_data.begin(), b_data.end());
			}

			output_pip.send(output);

			std::vector<double> input;
			input_pip.receive(input);

			
			for (int i = 0; i < b.size(); i++)
			{
				std::vector<vector> input_point;
				input_point.reserve(20);
				for (int j = 0; j < 20; j++)
				{				
					vector temp = vector(point(input[i * 42 + j * 2], input[i * 42 + j * 2 + 1])) * 5;
					input_point.push_back(temp);
				}
				b[i].move(input_point.data());
				b[i].door[0] = int(input[i * 42 + 40]);
				b[i].door[1] = int(input[i * 42 + 41]);
				b[i].site.reset_seg();
			}
			std::vector<double> callback(1);
			callback[0] = 奖励函数(a, b);
			callback_pip.send(callback);

			p = cv::Mat::zeros(h, w, CV_8UC3);
			a.print(p, 比例, cv::Scalar(255, 255, 255));
			for (int i = 0; i < b.size(); i++)
			{
				b[i].print(p, 比例, cv::Scalar(255, 255 / b.size() * i, 0));
			}


			cv::imshow("123", p);
			int key = cv::waitKey(1);
			if (key == 'n')
			{
				break;
			}
			else if (key == 'r')
			{
				b = std::vector<building>(8);
				for (int i = 0; i < b.size(); i++)
				{
					b[i].fun = i;
					for (int j = 0; j < 20; j++)
					{
						b[i].site[j].origin = point(vector(b[i].site[j].origin) + ((初始解[b[i].fun]) * 50) + ((vector(1.0, 0.0).rotate(18 * j + 45)) * 10));
					}


					b[i].site.reset_seg();

					b[i].target_area = double(rand()) / RAND_MAX * s * 0.125;
				}
			}

			double s = 0;
			for (int i = 0; i < b.size(); i++)
			{
				s += b[i].area();
			}
			if (s > a.area())
			{
				b = std::vector<building>(8);
				for (int i = 0; i < b.size(); i++)
				{
					b[i].fun = i;
					for (int j = 0; j < 20; j++)
					{
						b[i].site[j].origin = point(vector(b[i].site[j].origin) + ((初始解[b[i].fun]) * 50) + ((vector(1.0, 0.0).rotate(18 * j + 45)) * 10));
					}


					b[i].site.reset_seg();

					b[i].target_area = double(rand()) / RAND_MAX * s * 0.125;
				}
			}
		}
	}

	return 0;
}