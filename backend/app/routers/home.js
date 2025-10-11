import express  from "express"
import homecontroller from "../controllers/homecontroller.js";
const  route =  express.Router();

route.get("/", homecontroller.index);

export  default  route 
