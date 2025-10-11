import fs from "fs";
import { GoogleGenAI } from "@google/genai";
import dotenv from "dotenv";
import similarity from "compute-cosine-similarity";
dotenv.config();
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

const ai = new GoogleGenAI({ apiKey: GEMINI_API_KEY });

import {
  AutoProcessor,
  CLIPVisionModelWithProjection,
  RawImage,
  AutoTokenizer,
  CLIPTextModelWithProjection,
} from "@xenova/transformers";

import vector from "../models/vector.js";

async function embeddingText({ caption }) {
  const tokenizer = await AutoTokenizer.from_pretrained(
    "Xenova/clip-vit-base-patch16"
  );
  const text_model = await CLIPTextModelWithProjection.from_pretrained(
    "Xenova/clip-vit-base-patch16"
  );
  const texts = [caption];
  const text_inputs = tokenizer(texts, { padding: true, truncation: true });

  // Compute embeddings
  const { text_embeds } = await text_model(text_inputs);
  const vectorArray = Array.from(text_embeds.data);
  return vectorArray;
}
async function embeddingImg({ filepath }) {
  // Load processor and vision model
  const processor = await AutoProcessor.from_pretrained(
    "Xenova/clip-vit-base-patch16"
  );
  const vision_model = await CLIPVisionModelWithProjection.from_pretrained(
    "Xenova/clip-vit-base-patch16"
  );

  // Read image and run processor
  const image = await RawImage.read(filepath);
  const image_inputs = await processor(image);

  // Compute embeddings
  const { image_embeds } = await vision_model(image_inputs);
  const vectorArray = Array.from(image_embeds.data);
  return vectorArray;
  // Tensor {
  //   dims: [ 1, 512 ],
  //   type: 'float32',
  //   data: Float32Array(512) [ ... ],
  //   size: 512
  // }
}

async function searchEmbeddingImg({ filepath, topk = 3 }) {
  const source = await embeddingImg({ filepath });
  const vectors = await vector.find({});
  if (vectors) {
    const slice = vectors
      .map((value) => {
        const s = similarity(source, value.embedding);
        return { similarity: s, caption: value.caption, label: value.label };
      })
      .sort((a, b) => b.similarity - a.similarity)
      .slice(0, topk); //desc
    console.log(slice);
    return slice; // [{similarity,caption,label}]
  } else {
    return [];
  }
}
async function searchEmbeddingText({ question, topk = 3 }) {
  const source = await embeddingText({ caption: question });
  const vectors = await vector.find({});
  if (vectors) {
    const slice = vectors
      .map((value) => {
        const s = similarity(source, value.embedding);
        return { similarity: s, caption: value.caption, label: value.label };
      })
      .sort((a, b) => b.similarity - a.similarity)
      .slice(0, topk); //desc
    console.log(slice);
    return slice; // [{similarity,caption,label}]
  } else {
    return [];
  }
}

async function answerGemmi({ embedding, question, modal = ai }) {
  const references = embedding
    .map((item) => {
      return `label : ${item.label} referenceInfor : ${item.caption}`;
    })
    .join("\n");
  const prompt = `
      Bạn là trợ lý ảo chuyên gia phân tích thị trường chứng khoán Việt Nam.
      Tôi đã cung cấp các mẫu nến tìm được từ ảnh mà tôi gửi, bao gồm thông tin sau:
      ${references}

      Nhiệm vụ của bạn:
      1. Dựa trên các mẫu nến này, phân tích xu hướng và rủi ro của cổ phiếu AAA (CTCP Nhựa An Phát Xanh - An Phat Bioplastics).
      2. Kết hợp với dữ liệu thị trường hiện tại (giá, biến động) nếu có thể.
      3. Đưa ra nhận định chi tiết, bao gồm:
        - Dự báo tăng/giảm ngắn hạn
        - Các mức hỗ trợ/kháng cự quan trọng
        - Rủi ro cần lưu ý
      4. Trình bày kết quả súc tích, dễ hiểu và chuyên gia.

      Câu hỏi cần trả lời: ${question}
      `;

  const response = await ai.models.generateContent({
    model: "gemini-2.0-flash-001",
    contents: prompt,
  });
  return { question: prompt, answer: response.text };
}

async function learningSeft({ question, caption }) {
  if (!caption || !question) return false;
  try {
    const embedding = await embeddingText({ caption });

    const update = await vector.create({
      imgId: "",
      caption,
      label: question,
      embedding,
      study: true,
    });
    return true;
  } catch (err) {
    console.error("learningSeft error:", err);
    return false;
  }
}

async function scaffoldModal({ filepath, myQuestion, onfilepath = false }) {
  try {
    let result;
    if (onfilepath) {
      result = await searchEmbeddingImg({ filepath, topk: 2 });
    } else {
      result = await searchEmbeddingText({ question: myQuestion, topk: 3 });
    }

    const { answer } = await answerGemmi({
      embedding: result,
      question: myQuestion,
    });
    const check = await learningSeft({ question: myQuestion, caption: answer });

    console.log("LearningSeft result:", check);
    return answer;
  } catch (err) {
    console.error("scaffoldModal error:", err);
    return null;
  }
}

export {
  embeddingImg,
  searchEmbeddingImg,
  searchEmbeddingText,
  answerGemmi,
  embeddingText,
  learningSeft,
  scaffoldModal,
};
