// VIBE_.cpp  
// ------------------------------------------------------------------ -  
// Reference: your-main-file-sequential.c and mexopencv-master/BackgroundSubtractorMOG2_.cpp  
// Authors : LSS  
// Date : 26 / 04 / 2017  
// Last modified : 28 / 04 / 2017  
// ------------------------------------------------------------------ -  
  
#include "mex.h"  
#include "matrix.h" // for the mxArray  
#include <map>  
#include <cstdint>  
#include <vector>  
#include <string>  
  
#include "vibe-background-sequential.h"  
#include "vibe-background-sequential.cpp"  
  
  
  
  
using namespace std;  
  
  
class VIBE  
{  
private:  
    vibeModel_Sequential_t *model;  
    bool bfirstFrame;  
public:  
    VIBE()  
    {  
        model = (vibeModel_Sequential_t*)libvibeModel_Sequential_New();  
        bfirstFrame = true;  
    };  
  
    VIBE(const VIBE & vibe)  
    {  
        model = (vibeModel_Sequential_t*)libvibeModel_Sequential_New();  
  
        /* Default parameters values. */  
        model->numberOfSamples = vibe.model->numberOfSamples;  
        model->matchingThreshold = vibe.model->matchingThreshold;  
        model->matchingNumber = vibe.model->matchingNumber;  
        model->updateFactor = vibe.model->updateFactor;  
  
        /* Storage for the history. */  
        model->historyImage = vibe.model->historyImage;  
        model->historyBuffer = vibe.model->historyBuffer;  
        model->lastHistoryImageSwapped = vibe.model->lastHistoryImageSwapped;  
  
        /* Buffers with random values. */  
        model->jump = vibe.model->jump;  
        model->neighbor = vibe.model->neighbor;  
        model->position = vibe.model->position;  
  
  
        bfirstFrame = true;  
    };  
  
    ~VIBE()  
    {  
        libvibeModel_Sequential_Free(model);  
    };  
  
      
    VIBE & operator=(const VIBE & vibe)  
    {  
        if (this == &vibe)  
            return *this;  
  
        /* Default parameters values. */  
        model->numberOfSamples = vibe.model->numberOfSamples;  
        model->matchingThreshold = vibe.model->matchingThreshold;  
        model->matchingNumber = vibe.model->matchingNumber;  
        model->updateFactor = vibe.model->updateFactor;  
  
        /* Storage for the history. */  
        model->historyImage = vibe.model->historyImage;  
        model->historyBuffer = vibe.model->historyBuffer;  
        model->lastHistoryImageSwapped = vibe.model->lastHistoryImageSwapped;  
  
        /* Buffers with random values. */  
        model->jump = vibe.model->jump;  
        model->neighbor = vibe.model->neighbor;  
        model->position = vibe.model->position;  
  
  
        bfirstFrame = true;  
  
        return *this;  
  
    };  
  
  
    void GetfrImageC3R(uint8_t * image_data, uint8_t * frimg, int width, int height) // image_data is stored as RGBRGBRGB... or BGRBGRBGR... Three consecutives bytes per pixel thus.  
    {  
        if (bfirstFrame)  
        {  
            libvibeModel_Sequential_AllocInit_8u_C3R(model, image_data, width, height);  
            bfirstFrame = false;  
        }  
        else  
        {  
            libvibeModel_Sequential_Segmentation_8u_C3R(model, image_data, frimg);  
            libvibeModel_Sequential_Update_8u_C3R(model, image_data, frimg);  
        }  
  
    }  
  
};  
  
  
  
/// Last object id to allocate  
int last_id = 0;  
/// Object container  
map<int, VIBE> obj_;  
  
  
void mexFunction(int nlhs, mxArray *plhs[],  
                 int nrhs, const mxArray *prhs[])  
{  
    // Checking number of arguments  
    if (nrhs<2 || nlhs>1)  
        mexErrMsgIdAndTxt("VIBE : error", "Wrong number of arguments");  
  
    int id = 0;  
    string method;  
    if (nrhs > 1 && mxIsNumeric(prhs[0]) && mxIsChar(prhs[1]))  
    {  
        id = mxGetScalar(prhs[0]);  
        method = mxArrayToString(prhs[1]);  
    }  
    else  
        mexErrMsgIdAndTxt("VIBE : error", "Invalid arguments");  
  
  
    if (method == "new")  
    {  
        obj_[last_id] = VIBE(); // 调用了两次默认构造函数，和一次赋值函数  
        plhs[0] = mxCreateDoubleScalar(last_id++);  
        return;  
    }  
  
    VIBE& obj = obj_[id];  
    if (method == "delete")  
    {  
        if (nrhs != 2 || nlhs != 0)  
            mexErrMsgIdAndTxt("VIBE : error", "Output not assigned");  
        obj_.erase(id);  
    }  
    else if (method == "GetfrImageC3R")  
    {  
        if (nrhs != 3 || nlhs != 1)  
            mexErrMsgIdAndTxt("VIBE : error", "Wrong number of arguments");  
  
        if (!mxIsClass(prhs[2], "uint8"))  
            mexErrMsgIdAndTxt("VIBE : error", "Only image arrays of the uint8 class are allowed");  
  
  
        uint8_t* imMatlab = (uint8_t*)mxGetPr(prhs[2]);  
        int nrDims = (int)mxGetNumberOfDimensions(prhs[2]);  
        if (nrDims !=  3)  
        {  
            mexErrMsgIdAndTxt("VIBE : error", "The input image should be RGB");  
            return;  
        }  
  
        int width = (mxGetDimensions(prhs[2]))[0];  
        int height = (mxGetDimensions(prhs[2]))[1];  
  
  
        uint8_t *image_data = NULL;  
        image_data = (uint8_t*)mxMalloc((3 * width) * height);  
        for (int i = 0; i < width; i++) // image_data is stored should as RGBRGBRGB  
        {  
            for (int j = 0; j < height; j++)  
            {  
                image_data[j * 3 * width + i*3] = imMatlab[j*width + i];  
                image_data[j * 3 * width + i*3 + 1] = imMatlab[width*height + j*width + i];  
                image_data[j * 3 * width + i*3 + 2] = imMatlab[2*width*height + j*width + i];  
            }  
        }  
  
        plhs[0] = mxCreateNumericMatrix(width, height, mxUINT8_CLASS, mxREAL);  
        uint8_t * frimg = (uint8_t *) mxGetPr(plhs[0]);  
        memset(frimg, 0, sizeof(uint8_t)*width*height);  
        obj.GetfrImageC3R(image_data, frimg, width, height);  
  
  
        mxFree(image_data);  
  
    }else  
        mexErrMsgIdAndTxt("VIBE : error", "Unrecognized operation");  
  
  
    return;  
}  