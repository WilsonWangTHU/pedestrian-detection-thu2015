//#include "ccv.h"
#include <sys/time.h>
#include <ctype.h>
extern "C" { 
#include "ccv.h" 
}

#include <opencv/cv.h>   
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
using namespace cv;
using namespace std;

namespace patch {
	template < typename T > std::string to_string( const T& n ) {
		std::ostringstream stm ;
		stm << n ;
		return stm.str() ;
	}
}

static unsigned int get_current_time(void) {
	struct timeval tv;
	gettimeofday(&tv, NULL);
	return tv.tv_sec * 1000 + tv.tv_usec / 1000;
}

int main(int argc, char** argv) {
	string cache_root = "/home/user/ccv/data/cache";
	string source = "/home/user/ccv/data/seq04-img-left/image_00000078_0.png";

	/* initialize the ccv states */
	ccv_enable_default_cache();
	ccv_dpm_mixture_model_t* model = ccv_dpm_read_mixture_model(argv[1]);
	cout<<source<<endl;

	/* set the pedestrian detection parameters */
	ccv_dpm_param_t myparameters;
	myparameters.threshold = 0.4;
	myparameters.interval = 8;
	myparameters.min_neighbors = 1;
	myparameters.flags = 0;

	Mat plot_result = imread(source);
	/* made smaller images */
	for (int ixRoi = 0; ixRoi < 3; ixRoi ++) {
		for (int iyRoi = 0; iyRoi < 3; iyRoi ++) {
			ccv_dense_matrix_t* image = 0;
			int dx = ixRoi * plot_result.cols / 3;
			int dy = iyRoi * plot_result.rows / 3;

			Mat srcROI(plot_result, Rect(dx, dy, plot_result.cols / 3, plot_result.rows / 3));  
			imwrite(cache_root + "/" + patch::to_string(iyRoi) + patch::to_string(ixRoi) + "cache.png", srcROI);

			/* read the image, ccv_image for detection, and opencv Mat for recording */
			ccv_read((cache_root + "/" + patch::to_string(iyRoi) +
						patch::to_string(ixRoi) + "cache.png").c_str(),
						&image, CCV_IO_ANY_FILE);
			if (image == 0) cerr<<"The reading of dataset failed!"<<endl;
			cout<<"Image succussfully read"<<endl;

			/* processing the image one by one */
			unsigned int elapsed_time = get_current_time();
			ccv_array_t* seq = ccv_dpm_detect_objects(image, &model, 1, myparameters);
			elapsed_time = get_current_time() - elapsed_time;
			cout<<"Using "<<elapsed_time<<"ms on detecting the image"<<endl;

			if (seq != NULL) { 
				/* the detection has something to say */
				for (int i = 0; i < seq->rnum; i++) {
					ccv_root_comp_t* comp = (ccv_root_comp_t*)ccv_array_get(seq, i); /* get the ith number */
					rectangle(plot_result, 
							cv::Point(int(comp->rect.x) + dx, int(comp->rect.y) + dy),
							cv::Point(int(comp->rect.x + comp->rect.width), int(comp->rect.y + comp->rect.height)),
							cvScalar(0, 0, 255), 2, 8, 0);
				}
				ccv_array_free(seq); /* release the sequence */
			}

			/* free the images */
			ccv_matrix_free(image);
			imwrite("/home/user/ccv/test.jpg", plot_result);

		}
	}
	ccv_drain_cache();
	ccv_dpm_mixture_model_free(model);
	plot_result.release();
	return 0;
}
