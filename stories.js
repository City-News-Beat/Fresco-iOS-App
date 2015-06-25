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

window.tabBar().buttons()[1].tap();
target.delay(1.5);

captureLocalizedScreenshot("1-stories-page-1");

//window.logElementTree();

var tableLength = window.tableViews()[0].cells().length;

window.tableViews()[0].cells()[tableLength - 1].scrollToVisible();
target.delay(1.5);
captureLocalizedScreenshot("2-stories-pages-2");

target.delay(1.5);

window.tableViews()[0].cells()[tableLength - 1].scrollToVisible();
target.delay(1.5);
captureLocalizedScreenshot("2-stories-pages-2");


/*window.tableViews()[0].scrollDown();
target.delay(0.5);
window.tableViews()[0].scrollDown();
target.delay(3.5);
window.tableViews()[0].scrollDown();
target.delay(0.5);
captureLocalizedScreenshot("3-stories-pages-3");*/


