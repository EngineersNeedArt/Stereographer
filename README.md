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

The difficulty of course is how to later share and display the stereo images without requiring the camera and its fancy screen. With no 3D television or VR headset of my own, I prefer to print the images out in pairs to mimic the stereoscopic images on cards you often see in antique stores. While an old fashioned stereoscope is also an unusual device to have sitting around, they're quite a bit more affordable than the aforementioned 3D televisions or VR headsets. And who doesn't like the novelty of stereoscopic vacation photos?

### Stereoscopic Images

There's not anything magical about the old stereoscopic images. The cards are precisely 7 inches wide and 3 1/2 inches tall. Both images on the card (left and right) are 3 inches by 3 inches square. To create a modern version you need merely extract the left and right image pairs from the MPO file and composite them at the correct scale and position.

<p align="center">
<img width="800" src="https://github.com/EngineersNeedArt/Stereographer/blob/f1b5a393c7fc3da519610bf1de3af8da894ae456/Images/stereocard.jpg">
</p>

One way to do this by hand is to use <a href="https://exiftool.org">exiftool</a> and run a couple of commands that will pull the left image and the right image out of the MPO file. Next you can create a 7" by 3 1/2" document in your paint program of choice (probably go with a minimum of 300 dpi) and place your image pairs in the manner described. You can make a nice mask on a separate layer that has a pair of 3-inch square holes cut out (with perhaps a fancy arch over each image to give it a vintage look) to reveal the images. Be sure you scale the image pairs the same amount, keep them aligned vertically and more or less in sync horizontally. The resulting document you can print to a photo-quality ink jet printer and then cut out and mount to card stock.

### Stereographer

Needless to say, this application automates the steps above.

You feed it an MPO file and it extracts the image pairs itself internally.

When I discovered that CGImage didn't give me the image pairs, I first tried embedding exiftool in the app and calling it to write the images to a temp directory. After struggling with that a bit I instead switched to a technique I found on StackOverflow: manually looking for JPEG tags and then passing the relevant bytes to NSImage (NSImage(data: )). For my MPO files I found six JPEGs embedded — four of them were thumbnails. So a pixel-size check winnowed it down to the left and right images (fortunately in the expected order).

It then displays the left and right images in the ContentView of a window.

The final stereoscopic image has two square images but the images coming off the camera are 3:2 aspect ratio. (For better or worse, you can assume landscape mode always — physically rotating a stereo camera 90 degrees is a fail.) This means that part of your photos are going to be cropped out. For this reason I have a Pan control allowing you to slide both left and right photos until you like the square framing. (Also for this reason you should be mindful when you take the photos to keep your subject within an imaginary square in the center of the image.)

Additionally I added a Separation slider because I found that on a few occasions I wanted to pan the left and right images independently — closer or further apart. Generally you can leave it at the center tick.

Finally I have a text field that allows you to enter a title or description to display on the final image. I duplicate the description for both left and right images so that you can read it when viewing the final image in a stereoscopic viewer. (In fact I experimented with making the text appear to float a bit in front of the final image.)

The final image is displayed actual size on your display and I have found I can view them in stereo by placing a stereoscope up to the display of my laptop. For me I am fortunate that without my reading glasses the image needs to be at the end of the full length of my stereoscope. Therefore I can simply place the end of it against the display and it is in focus.

Clicking the export button will export a JPEG of the final image at high quality and at 450 DPI. If you want to do some post editing you can easily bring this composite image into the photo editing app of your choice and then print to a photo-quality printer.

<p align="center">
<img width="256" src="https://github.com/EngineersNeedArt/Stereographer/blob/6d2e36ca56ec94be0063d87ca0557ca6e721aaa6/Stereographer/Assets.xcassets/AppIcon.appiconset/Stereographer%20Icon%20(512)%201.png">
</p>
