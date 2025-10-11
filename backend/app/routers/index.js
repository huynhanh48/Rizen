import home from "./home.js";
import authentication from "./authentication.js";
import fileupload from "./fileupload.js";
import modal from "./modal.js";
import agent from "./agent.js";

const RunApp = function (app) {
  app.use("/api/authentication", authentication);
  app.use("/api/modal", modal);
  app.use("/api/agent", agent);
  app.use("/api/fileupload", fileupload);
  app.use("/api", home);
};

export default RunApp;
