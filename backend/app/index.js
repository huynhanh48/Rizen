import express from "express";
import morgan from "morgan";
import RunApp from "./routers/index.js";
import ConnectionDB from "./database/connectionDB.js";
import session from "express-session";

const app = express();
const port = 3000;
app.use(express.json());
app.use(morgan("combined"));
app.use(
  session({
    secret: "JtaJxy9AgH",
    saveUninitialized: true,
    resave: false,
  })
);

await ConnectionDB();
RunApp(app);

app.listen(port, () => {
  console.log(`Home : http://localhost:${port}`);
});
