# Pedestrian Detection with DPM
Created by Tingwu Wang at Sense Time, Beijing and also with Tsinghua University.

It is a course projects, and sorry we have only a linux port one.

### Citing and based-ons
This pedestrian detection is based on the work of DPM and libccv.
If you want to cite the original work, please cite

	@article{girshick15fastrcnn,
		Author = {Ross Girshick},
		Title = {Fast R-CNN},
		Journal = {arXiv preprint arXiv:1504.08083},
		Year = {2015}
	}
	@misc{libccv,
		author       = "Liu Liu",
		title        = "C-based/Cached/Core Computer Vision Library, A Modern Computer Vision Library",
		howpublished = "https://github.com/liuliu/ccv"
	}

### License
This pedestrian detector is under the MIT License (refer to the LICENSE file for details).


### Requirement, software
1. The libccv dependency.
```Shell
-lm -lcblas -latlas -lpng -ljpeg -lfftw3 -lfftw3f
-lpthread -llinear -lavcodec -lavformat -lswscale
-lgsl -lgslcblas -lcuda -lcudart -lcublas -L/usr/local/cuda/lib64
```
The cuda, cblas, atlas is what you really need to get. Other packages, you either already have it in Ubuntu, or could easily install using a sudo trick.
2. OpenCV library with 2.6+
3. g++ with 4.6 or earlier

### Requirements, hardware
A GPU that support CUDA-7, or CUDA-6, earlier versions are your own adventures, cause I don't know what will happen.

### Requirements, Data
The data is a big issue. Check out the $PEDESTRIAN/data/whats in the data directory.png
It lists all the data I used to run the projects.
Take a look in the source file $PEDESTRIAN/pedestrian/, download what is necessary.

### install
1. make sure you download all the lib you need.
2. make the ccv library by 
 ```shell
 cd lib
 ./configure && make
 ```
3. download the data you need, check out the
 ```shell
 pedestrian-detection-thu2015/data/whats in the data directory.png
 ```

4. Using the g++ to compile the source code.
 ```shell
 cd pedestrian-detection-thu2015/pedestrian/
 g++ ...
 ```
Remember to add the ccv dependency in /lib/.dep

and the ccv lib you just make in the step 2

and the OpenCV lib of course.
5. The results is stored in the /data/results (or change the path if you want)
