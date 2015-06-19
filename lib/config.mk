CC := gcc
AR := ar
NVCC := nvcc
CUDA_OBJS := cuda/cwc_convnet.o cuda/cwc_convnet_helper.o cuda/convnet/cwc_convnet_convolutional.o cuda/convnet/cwc_convnet_rnorm.o cuda/convnet/cwc_convnet_pool.o cuda/convnet/cwc_convnet_full_connect.o
DEFINE_MACROS := -D HAVE_CBLAS -D HAVE_LIBPNG -D HAVE_LIBJPEG -D HAVE_FFTW3 -D HAVE_LIBLINEAR -D HAVE_AVCODEC -D HAVE_AVFORMAT -D HAVE_SWSCALE -D HAVE_SSE2 -D HAVE_GSL -D HAVE_CUDA
prefix := /usr/local
exec_prefix := ${prefix}
CFLAGS :=  -msse2 $(DEFINE_MACROS) -I${prefix}/include
NVFLAGS := --use_fast_math -arch=sm_30 $(DEFINE_MACROS)
LDFLAGS :=  -L${exec_prefix}/lib -lm -lcblas -latlas -lpng -ljpeg -lfftw3 -lfftw3f -lpthread -llinear -lavcodec -lavformat -lswscale -lgsl -lgslcblas -lcuda -lcudart -lcublas -L/usr/local/cuda/lib64
