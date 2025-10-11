import express from "express";
import modal from "../controllers/modalcontroller.js";

const route = express.Router();

route.post("/", modal.index);

export default route;
