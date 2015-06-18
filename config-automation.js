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

captureLocalizedScreenshot("onboard1");

window.buttons()[0].tap();
target.delay(0.5);

captureLocalizedScreenshot("onboard2");

window.buttons()[0].tap();
target.delay(0.5);

captureLocalizedScreenshot("onboard3");

window.buttons()[0].tap();
target.delay(0.5);

captureLocalizedScreenshot("initialFirstRun");

target.delay(0.5);
window.buttons()[4].tap();
target.delay(2.5);

captureLocalizedScreenshot("highlights");

window.tabBar().buttons()[1].tap();
target.delay(2.5);

captureLocalizedScreenshot("stories");

window.tabBar().buttons()[3].tap();
target.delay(4.5);

captureLocalizedScreenshot("assignments");
