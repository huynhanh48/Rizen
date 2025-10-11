import express from "express";
import fileupload from "../controllers/fileupload.js";
import multer from "multer";
import GetProducts from "../middleware/getproducts.js";

const upload = multer({ dest: "uploads/" });

const route = express.Router();

route.get("/products/getname", fileupload.getProductName);
route.get("/products", GetProducts, fileupload.getProducts);
route.post("/upfile", upload.single("excel"), fileupload.index);

export default route;
