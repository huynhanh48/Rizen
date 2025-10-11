import path from "path";
import fs from "fs";
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

class AgentController {
  // api/agent
  async index(req, res, next) {
    const file = req.file;
    const { caption, label } = req.body;
    if (!file) {
      const ext = path.extname(file.originalname);
      const newFilePath = file.path + ext;
      fs.renameSync(file.path, newFilePath);

      const embedding = await searchEmbeddingImg({ filepath: newFilePath });
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
      const ext = path.extname(file.originalname);
      const newFilePath = file.path + ext;
      fs.renameSync(file.path, newFilePath);
      const myQuestion =
        "hãy đưa ra phân tích đánh giá với mã cổ phiếu với mã AAA ,CTCP Nhựa An Phát Xanh - An Phat Bioplastics";
      const answer = await scaffoldModal({
        filepath: newFilePath,
        myQuestion,
        onfilepath: true, // vì bạn đang dùng file hình
      });
      console.log(answer);
      return res.status(200).json({ message: "successfull" });
    }
    return res.status(400).json({ message: "errorr" });
  }
}
export default new AgentController();
