import user from "../models/user.js";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { convertDate, randomCode, sendEmail } from "../service/email.js";

class AuthenticationController {
  // POST /api/authentication/register
  async index(req, res, next) {
    const { username, email, password } = req.body;
    if (!username || !email || !password) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    try {
      const emailExists = await user.findOne({ "profile.email": email });

      if (!emailExists) {
        const passwordHash = await bcrypt.hash(password, 10);

        const userCreate = await user.create({
          profile: { email },
          state: { code: randomCode() },
          username,
          passwordHash,
        });
        await sendEmail(email, userCreate.state.code, "Mã xác thực email");
        console.log("da gui email ------- : --------- ", email);
        return res.status(200).json({ message: "successful", data: { email } });
      }

      return res.status(400).json({ message: "Email already in database" });
    } catch (error) {
      console.error(error);
      return res.status(500).json({ message: "Server error", error });
    }
  }
  // POST /api/authentication/verify
  async verifyUser(req, res, next) {
    const { code, email } = req.body;
    if (!code || !email) {
      return res.status(400).json({ message: "code and email do not exist" });
    }
    try {
      const getUser = await user.findOne({
        "profile.email": email,
        "state.expire": { $gt: new Date() },
      });
      console.log("user verify  expire : ", convertDate(getUser.state.expire));

      if (getUser && getUser.state.code == code) {
        await getUser.updateOne({
          $set: {
            "state.isVerification": true,
            "state.code": null,
          },
        });
        return res.status(200).json({ message: "successful", data: { email } });
      }

      return res.status(400).json({
        message: "code invalid ",
        data: { email, code },
      });
    } catch (error) {
      return res.status(400).json({
        message: "code was  expired  or  email invalid ",
        data: { email, error },
      });
    }
  }
  // POST  /api/authentication/resetcode
  async resetCode(req, res, next) {
    const { email } = req.body;
    try {
      if (email) {
        console.log("co email", email);
        const getUser = await user.findOne({
          "profile.email": email,
        });
        if (getUser) {
          const code = randomCode();
          console.log("co user : ", getUser);

          const userUpdate = await getUser.updateOne({
            $where: {
              "state.code": null,
            },
            $set: {
              "state.code": code,
              "state.expire": new Date(Date.now() + 3 * 60 * 1000),
            },
          });
          console.log(" da cap nhat", userUpdate);
          await sendEmail(email, code, "Mã xác thực mới");
          console.log(" da gui email");
          return res
            .status(200)
            .json({ message: "successful", data: { email, code } });
        }
      }
    } catch (error) {
      return res
        .status(400)
        .json({ message: "error was happened when send", email, error });
    }
  }
  // POST  /api/authentication/resetpassword
  async resetPassword(req, res, next) {
    const { email } = req.body;
    try {
      if (email) {
        const getUser = await user.findOne({
          "profile.email": email,
          // "state.isResetpassword": false,
        });
        await getUser
          .updateOne({
            $set: {
              "state.isResetpassword": true,
              "state.code": randomCode(),
            },
          })
          .then((value) => {
            return res
              .status(200)
              .json({ message: "successful", data: { email } });
          });
      }
    } catch (error) {
      return res.status(400).json({ message: "email is invalid", error });
    }
  }
  // POST  /api/authentication/changepassword
  async changePassword(req, res, next) {
    const { email, password } = req.body;
    try {
      const getUser = await user.findOne({
        "profile.email": email,
        "state.isResetpassword": true,
      });
      if (getUser) {
        const passwordHash = await bcrypt.hash(password, 10);
        await getUser
          .updateOne({
            $set: {
              passwordHash: passwordHash,
              "profile.isResetpassword": false,
              "state.code": null,
            },
          })
          .then((value) => {
            return res.status(200).json({
              message: "successful",
              data: {
                email,
              },
            });
          });
      }
    } catch (error) {
      return res.status(200).json({
        message: "error when  reset password",
        data: {
          email,
          error,
        },
      });
    }
  }
  // POST  /api/authentication/login
  async login(req, res, next) {
    const { email, password } = req.body;
    if (!email || !password) {
      res.status(400).json({
        message: "Email Or Password not valid",
      });
    }
    try {
      const getUser = await user.findOne({
        "profile.email": email,
        "state.isVerification": true,
      });
      if (getUser && (await bcrypt.compare(password, getUser.passwordHash))) {
        return res.status(200).json({
          message: "successful",
          data: {
            email: email,
            password: password,
            username: getUser.username,
          },
        });
      }
      return res
        .status(400)
        .json({ message: "Invalid email or password or user isn't verify" });
    } catch (error) {
      return res.status(500).json({ message: "Server error", error });
    }
  }
}

export default new AuthenticationController();
