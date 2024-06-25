// Server-side program to provide the interface to the APISample.json Rich
// Display File user interface.

const path = require("path");
const fileRead = require("./readCSVFile").fileRead;

async function f_APISample() {
  // Setup an object named "display" that has built in methods for reading and writing from
  // the screen; i.e. accepting requests from the browser and sending responses.
  pjs.defineDisplay("display", "APISample.json");

  let records = {};

  // A field object whose properties correspond to fields defined on the display. Gets values
  // from the user's interactions with the display.
  const fields = {
    exit: false,
    tbURL: "/run/papisamples/wsapi/apisample"
  };

  // Keep the program running until the user clicks the Exit button.
  while (!fields.exit) {
    // Display any information from the POST operation once.
    if (typeof fields.postMessage === "string" && fields.postMessage.length > 0) {
      fields.message = fields.postMessage;
      fields.postMessage = "";
    }
    else {
      fields.message = "";
    }

    if (typeof fields.postResults === "string" && fields.postResults.length > 0) {
      fields.tbResults = fields.postResults;
      fields.postResults = "";
    }
    else {
      fields.tbResults = "";
    }

    // Read the CSV file and display the results in the grid.
    try {
      const fHScsv = path.join(__dirname, "hobbyshop.csv");
      records = await fileRead(fHScsv);
      display.grHobbyShop.replaceRecords(records.data);
    }
    catch (err) {
      console.log(err);
    }

    // run the main screen
    display.mainscreen.execute(fields);
  }
}

exports.default = f_APISample;
