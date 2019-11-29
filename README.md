# RPi_CV2
OpenCV 4 &amp; Raspberry Pi 4 Install Script

After going through [Adrian Rosebrock](https://www.pyimagesearch.com/author/adrian/)'s various tutorials on OpenCV (all of which are great) I found myself spending hours (over days) trying to erase and setup new Raspberry Pi's in order to try something new.  Adrian has a great tutorial [here](https://www.pyimagesearch.com/2019/09/16/install-opencv-4-on-raspberry-pi-4-and-raspbian-buster/) that walks through the setup of [OpenCV 4.0.0](https://github.com/opencv/opencv/tree/4.0.0) on a Raspberry Pi 4 using [Raspbian Buster](https://www.raspberrypi.org/downloads/raspbian/) (Release 9/26/19).  

In order to automate the process, this is a project to automate the process so that you can download the repository, run a script and then come back later with everything working.  

## Warning
I'm not a programmer, but enjoy programming.  I've worked to get this repository to work on the various Raspberry Pi 4's I have laying around, the various USB drive's I have laying around and other miscellanious parts.  The goal being to improve the script to handle the various issues that arise.  It is always possible that this script will break with a package upgrade or a hardware change.  I'll endevor to fix things I find - likewise, the scripting is pretty basic and follows very closely to Adrian's tutorial.

##  Hardware

Raspberry Pi 4
microSD card
USB Flash Drive
Image = Raspian Buster (9/26/19)

##  Installation

Follow the standard instructions for buring the Buster image to the microSD card.  Be sure to add a text file named `ssh.txt` to the book image.

Insert the microSD card, the USB flash drive, ethernet cable and the power supply into the Raspberry Pi.  

Power it up.

SSH into the Raspberry Pi as user pi.

From the user pi home directory (where you should be after your SSH) execute the following.
