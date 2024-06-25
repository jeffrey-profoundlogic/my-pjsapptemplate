const fs = require("fs");
const path = require("path");
const os = require('os');
const platform = os.platform();

let ENVTYPE = (process.env.ENVTYPE || "DEVELOPER").toUpperCase();

module.exports = getConfig();

function getConfig() {
  let config = getDefaultConfig();
  process.env.instanceName = process.env.instanceName || ENVTYPE;

  // Account for starting up Specific Developer named environments
  if (ENVTYPE.match(/^PL_/i)) ENVTYPE = "PLDEV";

  switch (ENVTYPE) {
    case "DEVELOPER":
      config.port = 8081;
      config.errorScreen.type = "development-advanced";

      config.userdataDirectory = path.resolve(__dirname, "../userdata");
      config.modulesDirectory = path.resolve(__dirname, "../modules");
      // config.connectorCredentials = path.resolve(__dirname, "../creds/test_connector.creds");
      // config.profounduiLibrary = "PUIDEV";
      // config.connectorLibrary = "PJSDEV";
      // config.htmlTemplate = "start_dev.html";  // if file doesn't exist, it will fall back to using the built-in DEV file
      // config.connectorURL = "https://qeiwebdev.elektrisola-usa.com:18085/";

      delete config.sslOptions;
      delete config.designer;
      break;
    // case "PROD":
    //   config.port = 18089;
    //   config.connectorURL = "https://qeiweb.elektrisola-usa.com:18089/";
    //   process.env.PROD = true;
    //   config.errorScreen.type = "production";
    //   config.connectorCredentials = path.resolve(__dirname, "../creds/prod_connector.creds");
    //   config.profounduiLibrary = "PUIPROD";
    //   config.connectorLibrary = "PJSPROD";

    //   const prodibmi = config.databaseConnections.find(i => i.driver === "IBMi");
    //   if (prodibmi) prodibmi.driverOptions.database = "RDB_EI";
    //   break;

    // case "PREPROD":
    //   config.port = 18089;
    //   config.connectorURL = "https://qeiwebdev.elektrisola-usa.com:18089/";
    //   config.connectorCredentials = path.resolve(__dirname, "../creds/test_connector.creds");
    //   config.profounduiLibrary = "PUIPREPROD";
    //   config.connectorLibrary = "PJSPREPROD";
    //   process.env.PROD = true;
    //   config.errorScreen.type = "production";
    //   break;

    // case "QA":
    //   config.port = 18087;
    //   config.connectorURL = "https://qeiwebdev.elektrisola-usa.com:18087/";
    //   config.connectorCredentials = path.resolve(__dirname, "../creds/test_connector.creds");
    //   config.profounduiLibrary = "PUIQA";
    //   config.connectorLibrary = "PJSQA";
    //   break;

    // case "DEV":
    //   config.port = 18085;
    //   config.connectorURL = "https://qeiwebdev.elektrisola-usa.com:18085/";
    //   config.connectorCredentials = path.resolve(__dirname, "../creds/test_connector.creds");
    //   config.profounduiLibrary = "PUIDEV";
    //   config.connectorLibrary = "PJSDEV";
    //   break;

    // case "PLDEV":
    //   config.port = 8081;
    //   config.errorScreen.type = "development-advanced";
    //   config.userdataDirectory = path.resolve(__dirname, "../userdata");
    //   config.modulesDirectory = path.resolve(__dirname, "../modules");
    //   config.connectorCredentials = path.resolve(__dirname, "../creds/test_connector.creds");
    //   config.basicAuthCredentials = path.resolve(__dirname, "../creds/optimize.creds"),
    //   config.profounduiLibrary = "PUITRFMDEV";
    //   config.connectorLibrary = "PJSTRFMDEV";
    //   config.htmlTemplate = "start_dev.html";  // if file doesn't exist, it will fall back to using the built-in DEV file
    //   config.connectorURL = "https://qeiwebdev.elektrisola-usa.com:18061/";

    //   delete config.sslOptions;
    //   delete config.designer;
    //   break;

    // case "TRFM-DEV":
    //   config.port = 18061;
    //   config.errorScreen.type = "development-advanced";
    //   config.connectorURL = "https://qeiwebdev.elektrisola-usa.com:18061/";
    //   config.connectorCredentials = path.resolve(__dirname, "../creds/test_connector.creds");
    //   config.profounduiLibrary = "PUITRFMDEV";
    //   config.connectorLibrary = "PJSTRFMDEV";
    //   break;

    //   case "TRFM-LOG":
    //     config.port = 18069;
    //     config.errorScreen.type = "development-advanced";
    //     config.connectorURL = "https://qeiwebdev.elektrisola-usa.com:18069/";
    //     config.connectorCredentials = path.resolve(__dirname, "../creds/test_connector.creds");
    //     config.profounduiLibrary = "PUITRFMLOG";
    //     config.connectorLibrary = "PJSTRFMLOG";
    //     break;

    // case "TRFM-CICD":
    //   config.port = 18067;
    //   config.errorScreen.type = "development-advanced";
    //   config.connectorURL = "https://qeiwebdev.elektrisola-usa.com:18067/";
    //   config.connectorCredentials = path.resolve(__dirname, "../creds/test_connector.creds");
    //   config.profounduiLibrary = "PUITRFMCID";
    //   config.connectorLibrary = "PJSTRFMCID";
    //   break;

    // case "TRFM-QA":
    //   config.port = 18063;
    //   config.errorScreen.type = "development-advanced";
    //   config.connectorURL = "https://qeiwebdev.elektrisola-usa.com:18063/";
    //   config.connectorCredentials = path.resolve(__dirname, "../creds/test_connector.creds");
    //   config.profounduiLibrary = "PUITRFMQA";
    //   config.connectorLibrary = "PJSTRFMQA";
    //   break;

    // case "TRFM-UAT":
    //   config.port = 18065;
    //   config.connectorURL = "https://qeiwebdev.elektrisola-usa.com:18065/";
    //   config.connectorCredentials = path.resolve(__dirname, "../creds/test_connector.creds");
    //   config.profounduiLibrary = "PUITRFMUAT";
    //   config.connectorLibrary = "PJSTRFMUAT";
    //   break;

  }

  // config.encryptionKey = fs.readFileSync(path.resolve(__dirname, "../creds/ekey"));

  return config;
}

function getDefaultConfig() {
  return {
    pathlist: [
      "pjssamples"
    ],
    "initialModules": {
      "/hello": "pjssamples/hello",
      "/hello2": "pjssamples/hello2",
      "/connect4": "pjssamples/connect4",
      "/upload": "pjssamples/upload"
    },
    "databaseConnections": [
      {
        "name": "default",
        "default": true,
        "driver": "IBMi",
        "driverOptions": {
          "SQL_ATTR_COMMIT": "SQL_TXN_NO_COMMIT"
        }
      }
    ],

    errorScreen: {
      type: "development",
      editor: "vscode"
    },

    workWithSessions: { enabled: true },

    // mailTransport: {
    //   host: "Notesrvr",
    //   port: 25,
    //   secure: false,
    //   tls: {
    //     rejectUnauthorized: false
    //   }
    // },

    // pjscallKeys: [
    //   "Sl9y/m7OijipWr1NQb9I+dlwBrjn4L8zQBP0Rig4AGM="
    // ],

    timeout: 3600,                  // Timeout 60 Minutes
    pjscallSocketTimeout: 3610000,  // Timeout 61 Minutes
    defaultMode: "case-sensitive",
    gitSupport: false,
    designer: false,

    connectorIPFilter: function (ip) { return true; },
    showIBMiParmDefn: true,
    modulesDirectory: "./modules",
    userdataDirectory: "./userdata",

  };
}

// module.exports = {
//   "port": 8081,
//   "pathlist": [
//     "pjssamples"
//   ],
//   "initialModules": {
//     "/hello": "pjssamples/hello",
//     "/hello2": "pjssamples/hello2",
//     "/connect4": "pjssamples/connect4",
//     "/upload": "pjssamples/upload"
//   },
//   "databaseConnections": [
//     {
//       "name": "default",
//       "default": true,
//       "driver": "IBMi",
//       "driverOptions": {
//         "SQL_ATTR_COMMIT": "SQL_TXN_NO_COMMIT"
//       }
//     }
//   ],
//   "timeout": 3600,
//   "defaultMode": "case-sensitive"
// }
