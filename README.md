# et-tladp

## Table of contents
* [Introduction](#Introduction)
* [Description](#Description)
  * [Overview](#Overview)
  * [Required files](#Required-files)
* [Installation](#Installation)
  * [First time set-up](#First-time-set-up)


## Introduction
The *Eye Tracking Tasks Library and Data Processing* (et-tladp) project includes 3 Windows desktop applications used for the creation of a tasks library and the processing of eye tracking data. The tasks library contains all the relevant information about a task, its associated images and areas of interest (AOIs) within each image. This is then referenced during data processing, allowing for the application of a spatial filter to detect AOI hits. The data processing app *EyeTrackRunTask* has been written specifically to process data output from Birkbeck's [Task Engine](https://sites.google.com/site/taskenginedoc/) using a Tobii X60 eye tracker. Task Engine uses [Tobii analytics SDK](http://developer.tobiipro.com/). Currently *EyeTrackRunTask* can only be used with these data outputs.

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
The user can choose to parse the data into fixations and saccades using the fixation filter or analyse unparsed (*raw*) data. The fixation filter design is based on Tobii's I-VT Fixation Filter:

[Tobii I-VT Fixation Filter](https://www.tobiipro.com/siteassets/tobii-pro/learn-and-support/analyze/how-do-we-classify-eye-movements/tobii-pro-i-vt-fixation-filter.pdf)

As well as identifying fixations and saccades, the user can select which eye to analyse, interpolate data, merge adjacent fixations and discard short fixations, using adjustable parameters. See [here](https://www.tobiipro.com/siteassets/tobii-pro/learn-and-support/analyze/how-do-we-classify-eye-movements/determining-the-tobii-pro-i-vt-fixation-filters-default-values.pdf) for details on choosing parameter values.

![FixFilter](demo%20files/FixFilter.png)


### Required files
There are three required files in order for the applications to work.

#### *EyeTrackTasksLib.mat*
This library stores all the information about each task, image and area of interest as well as the screen information on which they are displayed. A single task containing a single image (stored online) has been added to the library for demonstration.

#### *monitors.mat*
This is a struct containing information about the eye tracker display size and is used to calculate resized image dimensions.

#### *LibLocation.txt*
MATLAB Compiler does not allow for the specification of directories in which to store required files. This project was designed to be used over a shared network, with multiple users accessing and editing the same tasks library. To remove the need for the apps to continually prompt the users for a file path to the library, this text file contains the location of *EyeTrackTasksLib* and *monitors* and is scanned at application start-up. For example, if the library and monitors files are stored on the user's desktop:

![LibLocation](demo%20files/LibLocation.png) <!-- .element height="50%" width="50%" -->

The *LibLocation.txt* file itself should be stored in the root of the installation directory so that it may be accessed by a relative file path.

## App installation
The apps folder contains three executables compiled in MATLAB. MATLAB Runtime is required to run these desktop applications and will be automatically downloaded from the web during the first installation. Download the *EyeTrackTasksLib* and *monitors* files and change the file path in the *LibLocation.txt* file to their download directory. Store the *LibLocation.txt* file in the root of the installation directory, for example *C:\Program Files\EyeTrackEditTasks*.

## Application user guide

### EyeTrackEditTasks

#### Creating new tasks
A new task can be added, a display monitor chosen and images allocated to the task. The task type dropdown refers to whether the images are static or gaze contingent (e.g. gap overlap). The image ID can be edited if required.

![addNewTask](demo%20files/addNewTask.png)

### Adding AOIs
AOIs can be added by drawing or manual entry of pixel coordinates. Manual entry can only be used for rectangular AOIs. Select a task and image. To draw an AOI, select task, image and shape and then click *Load Image*. To enter manually, change the AOI entry method and enter details in the table. Clicking *Display New AOIs* will show all AOIs entered. The AOIs won't be committed to the library until they are saved.

#### Drawing AOI example
Clicking *New AOI* will turn on Drawing mode. Drag the shape and resize if necessary. Once you're happy with it, clicking *Save AOI* will prompt for a name for the AOI. Multiple shapes can be drawn by clicking *New AOI*

##### Drawing a rectangular AOI 'eyes'
![drawAoiDemo](demo%20files/drawAoiDemo.gif)

### EyeTrackRunTask
This app processes the eye tracking data output from Task Engine.

### Editing tasks library

## Limitations

## Software used
