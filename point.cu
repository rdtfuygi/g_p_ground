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

__host__ __device__ point::point(double λ��[2])
{
	locat[0] = λ��[0];
	locat[1] = λ��[1];
}

__host__ __device__ double& point::operator[](int i)
{
	return locat[i & 1];
}

__host__ __device__ double point::operator[](int i) const
{
	return locat[i & 1];
}

void point::print(cv::InputOutputArray ͼ��, double ����, const cv::Scalar& ��ɫ, int ��ϸ) const
{
	int �� = ͼ��.rows(), �� = ͼ��.cols();
	int ԭ��_x = �� / 2, ԭ��_y = �� / 2;

	int �Ŵ� = 2 * (�� > �� ? �� : ��);

	cv::Point ��(locat[0] * ���� + ԭ��_x, -locat[1] * ���� + ԭ��_y);

	cv::circle(ͼ��, ��, ��ϸ, ��ɫ, -1);
}
