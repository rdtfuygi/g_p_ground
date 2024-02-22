#include "geometry.cuh"

__host__ __device__ point::point()
{
	locat[0] = 0;
	locat[1] = 0;
}

__host__ __device__ point::point(double x, double y)
{
	locat[0] = x;
	locat[1] = y;
}

__host__ __device__ point::point(double 位置[2])
{
	locat[0] = 位置[0];
	locat[1] = 位置[1];
}

__host__ __device__ double& point::operator[](int i)
{
	return locat[i & 1];
}

__host__ __device__ double point::operator[](int i) const
{
	return locat[i & 1];
}

void point::print(cv::InputOutputArray 图像, double 比例, const cv::Scalar& 颜色, int 粗细) const
{
	int 高 = 图像.rows(), 宽 = 图像.cols();
	int 原点_x = 宽 / 2, 原点_y = 高 / 2;

	int 放大 = 2 * (高 > 宽 ? 高 : 宽);

	cv::Point 点(locat[0] * 比例 + 原点_x, -locat[1] * 比例 + 原点_y);

	cv::circle(图像, 点, 粗细, 颜色, -1);
}
