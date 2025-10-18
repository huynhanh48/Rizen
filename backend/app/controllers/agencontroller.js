import path from "path";
import fs from "fs";
import slugify from "slugify";
import {
  answerGemmi,
  embeddingImg,
  searchEmbeddingText,
  embeddingText,
  searchEmbeddingImg,
  learningSeft,
  scaffoldModal,
} from "../agent/embedding.js";
import vector from "../models/vector.js";
import chat from "../models/chat.js";
import { Chats } from "@google/genai";

class AgentController {
  // api/agent
  // description  API  Upload Img or Text
  async index(req, res, next) {
    const file = req.file;
    console.log(file);
    const { caption, label } = req.body;
    if (file) {
      const ext = path.extname(file.originalname);
      const newFilePath = file.path + ext;
      fs.renameSync(file.path, newFilePath);

      const embedding = await embeddingImg({ filepath: newFilePath });
      let formatcaption = caption
        .replace(/\n+/g, " ")
        .replace(/\s+/g, " ")
        .trim();
      await vector.create({
        imgId: newFilePath,
        caption: formatcaption,
        embedding,
        label,
      });

      return res.status(200).json({ message: "successfull" });
    } else {
      const textResult = await embeddingText({ caption });
      await vector.create({
        imgId: "",
        caption: caption,
        embedding: textResult,
        label,
      });
      return res.status(200).json({ message: "successfull" });
    }
    return res.status(400).json({ message: "errorr" });
  }
  //   api/chat
  async chat(req, res, next) {
    try {
      const file = req.file;
      const { question, labelname, username } = req.body;
      console.log("qs,lb,un:", question, labelname, username);

      const slug = slugify(labelname || question, {
        lower: true,
        strict: true,
      });

      let embedding;
      if (file) {
        const ext = path.extname(file.originalname);
        const newFilePath = file.path + ext;
        fs.renameSync(file.path, newFilePath);
        embedding = await searchEmbeddingImg({ filepath: newFilePath });
        fs.unlinkSync(newFilePath);
      } else {
        embedding = await searchEmbeddingText({ question });
      }

      const response = await answerGemmi({
        embedding,
        question,
        userSession: username,
      });

      await learningSeft({ caption: response.answer, question });

      const existChat = await chat.findOne({ slug, username });

      if (existChat) {
        await chat.updateOne(
          { slug, username },
          {
            $push: {
              ListChat: [
                {
                  role: "user",
                  content: question,
                  createdAt: new Date(),
                },
                {
                  role: "model",
                  content: response.answer,
                  createdAt: new Date(),
                },
              ],
            },
            updatedAt: new Date(),
          }
        );
      } else {
        await chat.create({
          name: labelname || question,
          slug,
          username,
          ListChat: [
            { role: "user", content: question },
            { role: "model", content: response.answer },
          ],
        });
      }

      return res.status(200).json({
        message: "successful",
        data: {
          role: "model",
          content: response.answer,
          createdAt: new Date(),
        },
      });
    } catch (err) {
      console.error("Chat handler error:", err);
      return res.status(500).json({ message: "query failed", error: err });
    }
  }
  //  get-api/chat

  //get  collection  chat  in chats  api/agent/chat/collection
  async collection(req, res, next) {
    const { username } = req.query;
    console.log("username:", username);

    try {
      const collection = await chat.aggregate([
        {
          $match: { username: username },
        },
        {
          $group: {
            _id: "$slug",
            name: { $first: "$name" },
            username: { $first: "$username" },
          },
        },
        {
          $sort: { _id: -1 },
        },
        {
          $project: {
            _id: 0,
            slug: "$_id",
            name: 1,
            username: 1,
          },
        },
      ]);

      console.log("collection:", collection);
      return res.status(200).json({
        message: "successful",
        collection,
      });
    } catch (error) {
      console.error("Error in collection:", error);
      return res.status(400).json({
        message: "query failed!",
        error: error.message,
      });
    }
  }

  //post    add collection  chat  in chats  api/agent/chat/collecton/add
  async addcollection(req, res, next) {
    const { username, label } = req.body;
    console.log(username, label);
    if (username && label) {
      await chat.create({
        username,
        name: label,
      });
      return res.status(200).json({
        message: "successful",
      });
    }

    return res.status(400).json({
      message: "error",
    });
  }
  //get    api/agent/chat/collecton/get?username=anhvo?slug=abc
  async getChats(req, res, next) {
    const { username, slug } = req.query;
    if (username && slug) {
      const Chats = await chat.aggregate([
        {
          $match: {
            username: username,
            slug: slug,
          },
        },
        {
          $group: {
            _id: "$ListChat",
          },
        },
        {
          $unwind: "$_id", // tách mảng ListChat ra từng phần tử
        },
        {
          $project: {
            Chats: "_id",
          },
        },
        { $replaceRoot: { newRoot: "$_id" } },
      ]);
      if (Chats) {
        return res.status(200).json({
          message: "successful",
          Chats,
        });
      }
      return res.status(400).json({ message: "error !" });
    }
    return res.status(400).json("username && slug invalid !");
  }
}
export default new AgentController();
