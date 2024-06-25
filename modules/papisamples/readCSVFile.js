"use strict";
/**
 * A utility function to read a CSV file and output its contents in a pre-determined format.
 */
const fs = require("fs"); // filestream module
const readline = require("readline"); // line-by-line reading module

/**
 * Read a file line by line and output an object with its contents, with each field as properties of the object.
 * @param {String} filename
 * @param {Number} rowID
 * @returns {Object}
 */
async function fileRead(filename, rowID = 0) {
  let fLength = 0;
  const lData = [];
  let lTemp = null;
  // Start a file stream to read the file line-by-line
  const fstream = fs.createReadStream(filename);
  const linereader = readline.createInterface({
    input: fstream,
    crlfDelay: Infinity // used to identify all \r\n entries in the file as single line breaks
  });

  // Start reading the lines of the file
  for await (const line of linereader) {
    fLength++;
    if (rowID == 0) { // read the whole file, parse each line into arrays
      lTemp = line.split(",");
      lData.push({ ID: lTemp[0], Name: lTemp[1], Price: lTemp[2], Quantity: lTemp[3] });
    }
    else if (fLength == rowID) {
      lTemp = line.split(",");
      lData.push({ ID: lTemp[0], Name: lTemp[1], Price: lTemp[2], Quantity: lTemp[3] });
    }
  };

  return { length: fLength, data: lData };
}

/**
 * Read a file line by line, changing the specified line, and then write the data back to the file.
 * Return a message indicating which row was updated.
 * The original file is changed.
 * @param {String} filename
 * @param {Number} rowID
 * @returns {String}
 */
async function fileUpdate(filename, rowID, data) {
  let fLength = 0;
  // Start a file stream to read the file line-by-line
  const fstream = fs.createReadStream(filename);
  const linereader = readline.createInterface({
    input: fstream,
    crlfDelay: Infinity // used to identify all \r\n entries in the file as single line breaks
  });

  let strUpdated = "";

  // Start reading the lines of the file
  for await (const line of linereader) {
    fLength++;
    if (fLength == rowID) {
      strUpdated += fLength + "," + data + "\n"; // update the specific line if found
    }
    else strUpdated += line + "\n";
  };
  linereader.close();
  fstream.close();

  // remove the last entry of \n
  strUpdated = strUpdated.substring(0, strUpdated.length - 1);

  const message = await new Promise((resolve, reject) => {
    // rewrite the file with the updated data
    fs.writeFile(filename, strUpdated, (err) => {
      if (err) reject(err);
      else resolve("Row ID: " + iID + "\nData Updated: " + data);
    });
  });

  return message;
}

/**
 * Read a file line by line and build a string with the file contents, with the line specified by rowID removed.
 * Write the new string to the file, overwriting the original file.
 * Return a message indicating which row was deleted.
 * @param {String} filename
 * @param {Number} rowID
 * @returns {String}
 */
async function lineDelete(filename, rowID) {
  let iCol = 0;
  let fLength = 0;
  let strUpdated = "";
  let strTemp = "";
  // Start a file stream to read the file line-by-line
  const fstream = fs.createReadStream(filename);
  const linereader = readline.createInterface({
    input: fstream,
    crlfDelay: Infinity // used to identify all \r\n entries in the file as single line breaks
  });

  // Start reading the lines of the file
  for await (const line of linereader) {
    fLength++;
    if (fLength < rowID) { // Copy the line as is if it's not the row ID requested
      strUpdated += line + "\n";
    }
    else if (fLength > rowID) { // Update the first column to reflect the correct line
      iCol = line.indexOf(","); // find first occurence of , as the first column
      strTemp = line.substring(iCol, line.length); // move the , and the data to temp string
      strUpdated += (fLength - 1) + strTemp + "\n"; // add the line and its updated column number
    }
  };
  linereader.close();
  fstream.close();

  // remove the last entry of \n
  strUpdated = strUpdated.substring(0, strUpdated.length - 1);

  // Write the strUpdated string to the file at filename:
  const message = new Promise((resolve, reject) => {
    fs.writeFile(filename, strUpdated, (err) => {
      if (err) reject(err);
      else resolve("Row " + rowID + " deleted.");
    });
  });

  return message;
}

exports.fileRead = fileRead;
exports.fileUpdate = fileUpdate;
exports.lineDelete = lineDelete;
