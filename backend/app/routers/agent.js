import express from "express";
import agent from "../controllers/agencontroller.js";
const route = express.Router();
import multer from "multer";

const upload = multer({ dest: "vector/" });
const uploadcache = multer({ dest: "cache/" });

route.post("/", upload.single("file"), agent.index);
route.post("/chat", uploadcache.single("file"), agent.chat);
route.post("/chat/collection/add", agent.addcollection);
route.get("/chat/collection", agent.collection);
route.get("/chat/collection/get", agent.getChats);
route.get("/chat/message", agent.chat);

export default route;
