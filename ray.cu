#include "geometry.cuh"

__host__ __device__ ray::ray() :line() {}

__host__ __device__ ray::ray(point ��, vector ����) :line(��, ����) {}

__host__ __device__ ray::ray(point ��, double �Ƕ�, bool rad) :line(��, �Ƕ�, rad) {}

__host__ __device__ ray::ray(double ��_1_x, double ��_1_y, double ��_2_x, double ��_2_y) :line(��_1_x, ��_1_y, ��_2_x, ��_2_y) {}

__host__ __device__ ray::ray(point ��_1, point ��_2) :line(��_1, ��_2) {}

