# Stereographer
A tool for generating stereoscopic images (left + right) from MPO files.

<p align="center">
<img src="https://github.com/EngineersNeedArt/Stereographer/blob/572d7ca045f0e21ae5082b7e72b37fa5fec362fd/Images/StereographerScreenshot.jpg">
</p>

### Camera

I have a FUJIFILM Finepix REAL3D W3 stereo digital camera. They came out in 2010, probably when the whole 3D television hype was ramping up. Six years later it was discontinued.

<p align="center">
<img width="400" src="https://github.com/EngineersNeedArt/Stereographer/blob/f1b5a393c7fc3da519610bf1de3af8da894ae456/Images/W3.jpeg">
</p>

It's a decent point-and-shoot camera having two separate lenses and sensors to capture images in left and right pairs. The files that it produces are MPO files — more or less a wrapper that allows multiple JPEG images in one file. A nice feature of the camera is a clever lenticular display on the back of the camera that gives you a decent stereo preview of the photos you capture.

The difficulty of course is how to later share and display the stereo images without requiring the camera and it's fancy screen. With no 3D television or VR headset of my own, I prefer to print the images out in pairs to mimic the stereoscopic images on cards you often see in antique stores. While an old fashioned staereoscope is also an unusual device to have sitting around, they're quite a bit more affordable than the aforementioned 3D televisions or VR headsets. And who doesn't like the novelty of stereoscopic vacation photos?

### Steroscopic Images

There's not anything magical about the old stereoscopic images. They are precisely 7 inches wide and 3 1/2 inches tall. Both images are 3 inches by 3 inches square. To create a modern version you need merely extract the left and right image pairs from the MPO file and composite them at the correct scale and position.

<p align="center">
<img width="800" src="https://github.com/EngineersNeedArt/Stereographer/blob/f1b5a393c7fc3da519610bf1de3af8da894ae456/Images/stereocard.jpg">
</p>

One way to do this by hand is to use <a href="https://exiftool.org">exiftool</a> and run a couple of commands that will pull the left image and the right image out of the MPO file. Next you can create a 7" by 3 1/2" document in your paint program of choice (probably go with a minimum of 300 dpi) and place your image pairs in the manner described. You can make a nice mask on a separate layer that has a pair of 3-inch square holes cut out (with perhaps a fancy arch over each image to give it a vintage look) to reveal the images. Be sure you scale the image pairs the same amount, keep them aligned vertically and more or less in sync horizontally. The resulting document you can print to a photo-quality ink jet printer and then cut out and mount to card stock.

### Sterographer

Needless to say, this application automates the steps above. You feed it an MPO file and it extracts the image pairs itself internally. It then displays the left and right images... To be continued....
