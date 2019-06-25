# et-tladp

## Table of contents
* [Introduction](#Introduction)
* [Key features](#Key-features)
* [Description](#Description)
  * [The fixation filter](#The-fixation-filter)
  * [Required files](#Required-files)
* [App installation](#App-installation)
* [Application user guide](#Application-user-guide)
  * [EyeTrackEditTasks](#EyeTrackEditTasks)
  * [EyeTrackRunTask](#EyeTrackRunTask)
  * [EyeTrackLibraryEdit](#EyeTrackLibraryEdit)
* [Limitations](#Limitations)
  * [To-do list](#To-do-list)
  * [Notes](#Notes)
* [Software used](#Software-used)

## Introduction
The *Eye Tracking Tasks Library and Data Processing* (et-tladp) project includes 3 MATLAB app files used for the creation of a tasks library and the processing of eye tracking data. They can be run through MATLAB or compiled using MATLAB Compiler. The tasks library contains all the relevant information about a task, its associated images and areas of interest (AOIs) within each image. This is then referenced during data processing, allowing for the application of a spatial filter to detect AOI hits. The data processing app *EyeTrackRunTask* has been written specifically to process data output from Birkbeck's [Task Engine](https://sites.google.com/site/taskenginedoc/) using a Tobii X60 eye tracker. Task Engine uses [Tobii SDK](demo%20files/Tobii%20SDK%20Documentation.pdf). Currently *EyeTrackRunTask* can only be used with these data outputs.

The apps were designed to be standalone desktop applications, removing the need for users to have any coding experience or MATLAB installed. As such, they have been designed with specific users and data in mind. The *EyeTrackEditTasks* and *EyeTrackLibraryEdit* apps may be used for anyone wishing to build a tasks library of their own or simply get AOI coordinates for images.

## Key features 

#### Tasks library
* Load and save images to new task
* Draw AOIs (rectangle, ellipse, freehand shapes)
* Tree view to display all tasks, images and AOIs
* Editing existing tasks

#### Data Processing
* Parse data into fixation and saccade events
* Interpolate missing data
* Merge fixations close in time and angle
* Discard short fixations
* Eye selection
* Select summary tables or output eye events alongside raw data

## Description

### The fixation filter
The user can choose to parse the data into fixations and saccades using the fixation filter or analyse unparsed (*raw*) data. The fixation filter design is based on Tobii's [I-VT Fixation Filter](https://www.tobiipro.com/siteassets/tobii-pro/learn-and-support/analyze/how-do-we-classify-eye-movements/tobii-pro-i-vt-fixation-filter.pdf).

As well as identifying fixations and saccades, the user can select which eye to analyse, interpolate data, merge adjacent fixations and discard short fixations, using adjustable parameters. See [here](https://www.tobiipro.com/siteassets/tobii-pro/learn-and-support/analyze/how-do-we-classify-eye-movements/determining-the-tobii-pro-i-vt-fixation-filters-default-values.pdf) for details on choosing parameter values.

<img src="demo%20files/fixFilter.png" alt="fixFilter" height="60%" width="60%">

### Required files
There are three required files in order for the applications to work.

#### *EyeTrackTasksLib.mat*
This library stores all the information about each task, image and area of interest as well as the screen information on which they are displayed. A single task containing a single image (stored online) has been added to the library for demonstration.

#### *monitors.mat*
This is a struct containing information about the eye tracker display size, used to calculate resized image dimensions. Multiple monitors may be stored (perhaps for portable eye trackers) but only one monitor can be assigned to each task.

#### *LibLocation.txt*
MATLAB Compiler does not allow for the specification of directories in which to store required files. This project was designed to be used over a shared network, with multiple users accessing and editing the same tasks library. To remove the need for the apps to continually prompt the users for a file path to the library, this text file contains the location of *EyeTrackTasksLib* and *monitors* and is scanned at application start-up. For example, if the library and monitors files are stored on the user's desktop:

<img src="demo%20files/LibLocation.png" alt="LibLocation" height="50%" width="40%">

The *LibLocation.txt* file itself should be stored in the root of the installation directory (or parent directory if app is not deployed) so that it may be accessed by a relative file path.

## App installation
The apps folder contains the MATLAB app files. They may be compiled to an executable using MATLAB Compiler. Once installed, download the *EyeTrackTasksLib* and *monitors* files and change the file path in the *LibLocation.txt* file to their download directory. Store the *LibLocation.txt* file in the root of the installation directory, for example *C:\Program Files\EyeTrackEditTasks*.

## Application user guide

### EyeTrackEditTasks

##### Viewing existing tasks
Existing tasks and associated images and AOIs are viewed in the first tree along with a table containing AOI dimensions

<img src="demo%20files/viewingExistingTask.png" alt="viewingExistingTask" height="70%" width="70%">

##### Creating new tasks
A new task can be added, a display monitor assigned and images loaded to the task. The task type dropdown refers to whether the images are static or gaze contingent (e.g. gap overlap). Images may be loaded singularly or from a directory. The image ID can be edited if required.

<img src="demo%20files/addNewTask.png" alt="addNewTask" height="70%" width="70%">

#### Adding AOIs
AOIs can be added by drawing or by manually entering pixel coordinates. Manual entry can only be used for rectangular AOIs. Select a task and image. To draw an AOI, select task, image and shape and then click *Load Image*. To enter manually, change the AOI entry method and enter details in the table. Clicking *Display New AOIs* will show all AOIs entered. The AOIs won't be committed to the library until they are saved.

##### Drawing AOI example
Clicking *New AOI* will turn on Drawing mode. Drag the shape and resize if necessary. Once you're happy with it, clicking *Save AOI* will prompt for a name for the AOI. Multiple shapes can be drawn by clicking *New AOI*

##### Drawing a rectangular AOI 'eyes'
<img src="demo%20files/drawAoiDemo.gif" alt="drawAoiDemo" height="90%" width="90%">

### EyeTrackRunTask
This app is designed to process data output from Task Engine but could be customised to handle other data. The fixation filter parameters are selected, images and AOIs, subjects and finally summary table outputs.

### EyeTrackLibraryEdit
This app allows the user to edit names of tasks, images and AOIs already saved to the tasks library.

## Limitations
* *EyeTrackRunTask* app currently only works with data output from Task Engine. This only affects the way in which it searches for valid data directories so may be easily customised to suit.
* There is capability for spatial filtering but not currently an option for temporal filtering
* Data processing is only capable of handling static images or gaze contingent (gap overlap) trials, again specific to Task Engine outputs
* Some of the app components may appear stretched on certain displays.

### To-do list
* Ensure all code is annotated with function and class descriptors
* Add capability to add a new monitor via the app (although this can be done by simply editing the *monitors.mat* struct)
* Add capability in *EyeTrackEditTasks* to copy AOIs from one image to another
* Add a 'Total Fixation Count' option as an output summary table
* The way the error logs are written is in the process of being changed and needs to be finished
* Include a temporal filter to allow the user to define a window in which to analyse the data
* Edit the app function that resizes the window based on different display size/resolutions so that components are displayed correctly

### Notes
* The demo image is stored on GitHub which means load times can be slow. It is best to create a new task with a local image using *EyeTrackEditTasks* and delete the demo task 'Task Example' using *EyeTrackLibraryEdit*
* If the apps are being run through MATLAB, it will look for the *LibLocation.txt* file in its parent folder. When the app is deployed it looks for the root installation folder
* The *EyeTrackFixationFilter* class can be used for any data by editing the eye position and gaze vector variable properties.  
* Eye tracker remote time (microseconds) is expected as input

## Software used
* MATLAB R2018b
* MATLAB App Designer
* MATLAB Compiler v7.0
* MATLAB Image Processing Toolbox v10.3
* [RunLength](https://uk.mathworks.com/matlabcentral/fileexchange/41813-runlength) from MATLAB File Exchange
