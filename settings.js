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

// Sign Up Data
function getRandomInt(min, max) {
  return Math.floor(Math.random() * (max - min)) + min;
}

var email = "zachmayberry+" + getRandomInt(100, 999) + "@gmail.com";
var password = "password123";


window.buttons()[0].tap();
target.delay(0.5);


window.buttons()[0].tap();
target.delay(0.5);


window.buttons()[0].tap();
target.delay(0.5);


target.delay(0.5);
window.textFields()[0].setValue(email);
target.delay(1.5);
window.secureTextFields()[0].setValue(password);
target.delay(0.5);


window.buttons()[3].tap();
target.delay(1.0);
window.secureTextFields()[1].setValue(password);


window.buttons()[2].tap();
target.delay(1.5);
window.textFields()[0].setValue("Zachary");
target.delay(1.5);
window.textFields()[1].setValue("Mayberry");


window.buttons()[0].tap();
target.delay(1.5);


window.buttons()["Next"].tap();
target.delay(1.5);


window.buttons()[0].tap();
target.delay(1.5);


window.buttons()[0].tap();
target.delay(1.5);

window.tabBar().buttons()[4].tap();
target.delay(1.5);

window.buttons()[0].tap();
target.delay(1.5);

captureLocalizedScreenshot("settings");
