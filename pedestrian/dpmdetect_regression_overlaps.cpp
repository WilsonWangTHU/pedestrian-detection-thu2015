extern "C" { 
#include "ccv.h" 
}
#include <sys/time.h>
#include <ctype.h>
#include <opencv/cv.h>   
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <string>
#include <iostream>
#include <sstream>
using namespace cv;
using namespace std;

/* the g++ could not complie the to_string.. why? */
namespace patch {
	template < typename T > std::string to_string( const T& n ) {
		std::ostringstream stm ;
		stm << n ;
		return stm.str() ;
	}
}

//ccv_root_comp_t* comp = (ccv_root_comp_t*)ccv_array_get(seq, i); /* get the ith number */

float get_overlaps(ccv_root_comp_t* a, ccv_root_comp_t* b) {
	if (a == NULL || b == NULL) cerr<<"The boxes is not initialized!"<<endl;

	float sizeA = a->rect.width * a->rect.height;

	float x1 = max(a->rect.x, b->rect.x);
	float x2 = min(a->rect.x + a->rect.width, b->rect.x + b->rect.width);
	float y1 = max(a->rect.y, b->rect.y);
	float y2 = min(a->rect.y + a->rect.height, b->rect.y + b->rect.height);

	float overlaps = (x2 - x1) * (y2 - y1);
	if (x2 <= x1 || y2 <= y1) overlaps = 0;
	return overlaps / sizeA;
}


const int codingtype = 1196444237;
const int fps = 10;
const int imageStart = 100;
const int imageEnd = 450;

static unsigned int get_current_time(void) {
	struct timeval tv;
	gettimeofday(&tv, NULL);
	return tv.tv_sec * 1000 + tv.tv_usec / 1000;
}

int main(int argc, char** argv) {
	/* the input and output dir */
	string input_dir = "/home/user/ccv/data/sunny_day-img-left";

	/* initialize the ccv states */
	ccv_enable_default_cache();
	ccv_dpm_mixture_model_t* model = ccv_dpm_read_mixture_model(argv[1]);

	/* set the pedestrian detection parameters */
	ccv_dpm_param_t myparameters;
	myparameters.threshold = 0.4;
	myparameters.interval = 8;
	myparameters.min_neighbors = 1;
	myparameters.flags = 0;

	/* debug */
	string source = "/home/user/ccv/demo1.avi";
	VideoCapture inputVideo(source);              // Open input
	if (!inputVideo.isOpened()) {
		cout  << "Could not open the input video: " << source << endl;
		return -1;
	}
	int ex = static_cast<int>(inputVideo.get(CV_CAP_PROP_FOURCC));     // Get Codec Type- Int form
	cout<<"The coding is "<<ex<<endl;
	cout<<"The fps is "<<inputVideo.get(CV_CAP_PROP_FPS)<<endl;

	/* initialize the video writer */
	Mat getSize = imread(input_dir + "/image_00000100_0.png");
	Size videoSize = getSize.size();
	getSize.release();
	VideoWriter outputVideo;
	outputVideo.open("/home/user/ccv/data/output/eth2_reg_overlaps.avi", ex, fps, videoSize, true);
	if (!outputVideo.isOpened()) {
		cout<<"Could not open the output video"<<endl;
		return false;
	}


	/* process one by one */
	for (int iImage = imageStart; iImage <= imageEnd; iImage++) {

		/* read the image, ccv_image for detection, and opencv Mat for recording */
		string imageTail;
		if (iImage < 10) imageTail = "0000000" + patch::to_string(iImage);
		else if (iImage < 100) imageTail = "000000" + patch::to_string(iImage);
		else imageTail = "00000" + patch::to_string(iImage);
		string image_name = input_dir + "/image_" + imageTail + "_0.png";

		ccv_dense_matrix_t* image = 0;
		ccv_read(image_name.c_str(), &image, CCV_IO_ANY_FILE);
		Mat plot_result = imread(image_name);
		if (image == 0) cerr<<"The reading of dataset failed!"<<endl;
		cout<<"Image succussfully read"<<endl;

		/* processing the image one by one */
		unsigned int elapsed_time = get_current_time();
		ccv_array_t* seq = ccv_dpm_detect_objects(image, &model, 1, myparameters);
		elapsed_time = get_current_time() - elapsed_time;
		cout<<"Using "<<elapsed_time<<"ms on detecting the "<<iImage<<"th image"<<endl;

		if (seq != NULL) { 
			/* get the overlaps */
			bool* flag = new bool[seq->rnum];
			for (int i = 0; i < seq->rnum; i++) flag[i] = true;
			for (int i = 0; i < seq->rnum; i++) {
				for (int j = 0; i < seq->rnum; i++) {
					/* a bigger area */
					ccv_root_comp_t* comp1 = (ccv_root_comp_t*)ccv_array_get(seq, i); /* get the ith number */
					ccv_root_comp_t* comp2 = (ccv_root_comp_t*)ccv_array_get(seq, j); /* get the jth number */
					float dx1 = comp1->rect.x - comp2->rect.x;
					float dx2 = comp1->rect.x + comp1->rect.width - comp2->rect.x + comp2->rect.width;
					if (abs(dx1) / comp1->rect.width < 0.2 && abs(dx2) / comp2->rect.width < 0.2 &&
							abs(dx1) / comp2->rect.width < 0.2 && abs(dx2) / comp1->rect.width < 0.2 &&
							get_overlaps(comp1, comp2) > 0.5) {
						rectangle(plot_result, 
								cv::Point(int(min(comp1->rect.x, comp2->rect.x)), int(min(comp1->rect.y, comp2->rect.y))),
								cv::Point(int(max(comp1->rect.x + comp1->rect.width, comp2->rect.x + comp2->rect.width)), 
										int(max(comp1->rect.y + comp1->rect.height, comp2->rect.y + comp2->rect.height))),
								cvScalar(255, 0, 0), 2, 8, 0);
					}

				}
			}
			/* the detection has something to say */
			for (int i = 0; i < seq->rnum; i++) {
				ccv_root_comp_t* comp = (ccv_root_comp_t*)ccv_array_get(seq, i); /* get the ith number */
				/* a simple regression trick */
				float predHeight = ((float)videoSize.height / 2 - comp->rect.y) * 2 + 10;
				if (predHeight - comp->rect.height > predHeight * 0.5) {
					rectangle(plot_result, 
							cv::Point(int(comp->rect.x), int(comp->rect.y)),
							cv::Point(int(comp->rect.x + comp->rect.width), int(comp->rect.y + comp->rect.height)),
							cvScalar(0, 0, 255), 2, 8, 0);
				} else{
					rectangle(plot_result, 
							cv::Point(int(comp->rect.x), int(comp->rect.y)),
							cv::Point(int(comp->rect.x + comp->rect.width), int(comp->rect.y + comp->rect.height)),
							cvScalar(0, 255, 0), 2, 8, 0);
				}
			}
			ccv_array_free(seq); /* release the sequence */
		}
		outputVideo << plot_result;

		/* free the images */
		ccv_matrix_free(image);
		plot_result.release();
	}


	outputVideo.release();
	ccv_drain_cache();
	ccv_dpm_mixture_model_free(model);
	return 0;
}
