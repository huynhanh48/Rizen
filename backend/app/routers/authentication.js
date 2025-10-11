import express from "express";
import AuthenticationController from "../controllers/authenticationcontroller.js";

const route = express.Router();

route.post("/register", AuthenticationController.index);
route.post("/verify", AuthenticationController.verifyUser);
route.post("/resetcode", AuthenticationController.resetCode);
route.post("/resetpassword", AuthenticationController.resetPassword);
route.post("/changepassword", AuthenticationController.changePassword);
route.post("/login", AuthenticationController.login);

export default route;
