// This is an example configuration file to be used with ui-screen-shooter
// It is designed to work with the Hello World International application
// Please copy to config-automation.js and edit for your needs
// See also http://cocoamanifest.net/features/#ui_automation for automation help


// Pull in the special function, captureLocalizedScreenshot(), that names files
// according to device, language, and orientation
#import "capture.js"

// Now, we simply drive the application! For more information, check out my
// resources on UI Automation at http://cocoamanifest.net/features
var target = UIATarget.localTarget();
var window = target.frontMostApp().mainWindow();

/*var email = "zachmayberry+1@gmail.com";
var password = "123";

target.delay(0.5);
window.textFields()[0].setValue(email);
target.delay(1.5);
window.secureTextFields()[0].setValue(password);
target.delay(0.5);

window.buttons()["Log In"].tap();

*/

// Sign Up Data
function getRandomInt(min, max) {
  return Math.floor(Math.random() * (max - min)) + min;
}

window.buttons()[0].tap();
target.delay(1.5);

window.buttons()[0].tap();
target.delay(1.5);

window.buttons()[0].tap();
target.delay(1.5);


window.buttons()[5].tap();

window.tabBar().buttons()[2].tap();
target.delay(1.5);
target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_LANDSCAPELEFT);
target.delay(1.5);

captureLocalizedScreenshot("1-camera-portrait");

target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_LANDSCAPELEFT);
target.delay(1.5);

captureLocalizedScreenshot("2-camera-landscape");

target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_PORTRAIT);

target.delay(2);

window.logElementTree();

window.buttons()[1].tap();
target.delay(1);

captureLocalizedScreenshot("3-picker");
target.delay(1);

window.collectionViews()[0].cells()[0].tap();
target.delay(0.5);
window.collectionViews()[0].cells()[3].tap();
target.delay(0.5);
window.collectionViews()[0].cells()[4].tap();
target.delay(0.2);

captureLocalizedScreenshot("4-picker-selected");

window.toolbar().buttons()[0].tap();
target.delay(1);

captureLocalizedScreenshot("5-gallery-post");



