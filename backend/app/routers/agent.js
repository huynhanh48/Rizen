import express from "express";
import agent from "../controllers/agencontroller.js";
const route = express.Router();
import multer from "multer";

const upload = multer({ dest: "vector/" });

route.post("/", upload.single("file"), agent.index);

export default route;
