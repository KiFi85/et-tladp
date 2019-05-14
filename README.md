# eyeTrackProject

## Table of contents
* [Introduction](#Introduction)
* [Description](#Description)
  * [Overview](#Overview)
  * [Required files](#Required-files)
* [Installation](#Installation)
  * [First time set-up](#First-time-set-up)


## Introduction

*This README is under construction*

## Description

### Overview

Eye tracking experiments are broken down into *tasks*, each including a batch of images and areas of interest on those images. This project allows for a creation of a library of tasks for associated eye tracking experiments which can then be referenced when processing eye tracking data. The user can choose to parse the data into fixations and saccades using the fixation filter or analyse unparsed (*raw*) data. The fixation filter design is based on Tobii's I-VT Fixation Filter:

[Tobii I-VT Fixation Filter](https://www.tobiipro.com/siteassets/tobii-pro/learn-and-support/analyze/how-do-we-classify-eye-movements/tobii-pro-i-vt-fixation-filter.pdf)

As well as identifying fixations and saccades, the user can select which eye to analyse, interpolate data, merge adjacent fixations and discard short fixations, using adjustable parameters. See [here](https://www.tobiipro.com/siteassets/tobii-pro/learn-and-support/analyze/how-do-we-classify-eye-movements/determining-the-tobii-pro-i-vt-fixation-filters-default-values.pdf) for details on choosing parameter values. The user can then select a number of summary outputs or have the entire data set output with the fixation event details alongside.

### Required files

There are three required files in order for the applications to work.

##### *EyeTrackTasksLib.mat*

This library stores all the information about each task, image and area of interest as well as the screen information on which they are displayed. A single task containing a single image (stored online) has been added to the library for demonstration.

##### *monitors.mat*

This is a struct containing information about the eye tracker display size and is used to calculate resized image dimensions.

##### *LibLocation.txt*

MATLAB Compiler does not allow for the specification of directories in which to store required files. This project was designed to be used over a shared network, with multiple users accessing and editing the same tasks library. To remove the need for the apps to continually prompt the users for a file path to the library, this text file contains the location of *EyeTrackTasksLib* and *monitors* and is scanned at application start-up. For example, if the library and monitors files are stored on the user's desktop:

![LibLocation](demo files/LibLocation.png)

The *LibLocation.txt* file itself is stored in the root of the installation directory so that it may be accessed by a relative file path.

### Classes included

### Applications included

## Installation

The apps folder contains three executables compiled in MATLAB. MATLAB Runtime is required to run these desktop applications and will be downloaded from the web during the first installation.

### First time set-up

The apps require a tasks library to run. MATLAB Compiler doesn't allow specification of installation directories for required files. The apps were designed to allow multiple users to access the same tasks library across a shared network so the apps search for a text file to tell it where to find the tasks library.

## Application user guide


### Editing tasks

![drawAoiDemo](demo files/drawAoiDemo.gif)

### Processing data

### Editing tasks library

## Limitations

## Software used
