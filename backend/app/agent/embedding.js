import fs from "fs";
import path from "path";
import {
  GoogleGenAI,
  createUserContent,
  createPartFromUri,
} from "@google/genai";
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
import chat from "../models/chat.js";

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

async function searchEmbeddingImg({ filepath, topk = 1, limit = 0.9 }) {
  const source = await embeddingImg({ filepath });
  const vectors = await vector.find({});
  if (vectors) {
    const slice = vectors
      .map((value) => {
        const s = similarity(source, value.embedding);
        return s >= limit
          ? {
              similarity: s,
              caption: value.caption,
              label: value.label,
              imgId: value.imgId,
            }
          : null;
      })
      .filter((v) => v !== null)
      .sort((a, b) => b.similarity - a.similarity)
      .slice(0, topk); //desc
    console.log(slice);
    return slice; // [{similarity,caption,label,imgId}]
  } else {
    return [];
  }
}
async function searchEmbeddingText({ question, topk = 1, limit = 0.94 }) {
  const source = await embeddingText({ caption: question });
  const vectors = await vector.find({});
  if (vectors) {
    const slice = vectors
      .map((value) => {
        const s = similarity(source, value.embedding);
        return s >= limit
          ? { similarity: s, caption: value.caption, label: value.label }
          : null;
      })
      .filter((v) => v !== null)
      .sort((a, b) => b.similarity - a.similarity)
      .slice(0, topk); //desc
    console.log(slice);
    return slice; // [{similarity,caption,label}]
  } else {
    return [];
  }
}

async function answerGemmi({
  embedding,
  question,
  userSession,
  allowFilePath = false,
  fileSource = "",
  labelname = "",
}) {
  const references = embedding
    .filter((item) => item && (item.label || item.caption))
    .map((item) => {
      const labelText = item.label
        ? `Mẫu nến: ${item.label}`
        : "Tài liệu được cung cấp";
      const captionText = item.caption ? `Mô tả: ${item.caption}` : "";
      return `${labelText}\n${captionText}`;
    })
    .join("\n\n");

  let filepath1, filepath2, uploaded1, uploaded2;

  if (allowFilePath && fileSource) {
    filepath1 = embedding?.[0]?.imgId;
    filepath2 = fileSource;

    console.log("debug-upload:\nfilepath1,2:", filepath1, filepath2);
    console.log(references);

    uploaded1 = await ai.files.upload({
      file: filepath1,
    });
    uploaded2 = await ai.files.upload({
      file: filepath2,
    });
  }

  const prompt = `
Câu hỏi từ người dùng: ${question}

Bạn là **chuyên gia phân tích thị trường chứng khoán Việt Nam**, có nhiều năm kinh nghiệm trong việc đọc biểu đồ nến, nhận diện mô hình giá và dự đoán xu hướng.

Bạn đang hoạt động trong vai trò **một Agent hỗ trợ phân tích cho người dùng khác**, vì vậy hãy diễn đạt tự nhiên, rõ ràng, như một chuyên gia thật đang trò chuyện — không cần nói rằng bạn là AI.

${
  references
    ? `Dữ liệu hoặc nhận định đã tham khảo từ các biểu đồ 1, mô hình hoặc nguồn tương tự trước đây:\n${references}\n\n`
    : "Hiện không có dữ liệu hoặc biểu đồ tham khảo trước."
}

${
  allowFilePath && filepath1 && filepath2
    ? `Hệ thống đã cung cấp hai biểu đồ:
- Biểu đồ tham khảo (được trích xuất từ dữ liệu trước) là ảnh 1
- Biểu đồ hiện tại của người dùng cần được phân tích là ảnh 2
- Biểu đồ tham khảo (đã được hệ thống phân tích trước).
- Biểu đồ hiện tại của người dùng (đang cần đánh giá xu hướng).

Dựa trên biểu đồ hiện tại và biểu đồ tham khảo, hãy:
1. Nhận định xu hướng chính của biểu đồ hiện tại.
2. So sánh điểm tương đồng hoặc khác biệt với biểu đồ tham khảo (nếu có).
3. Lưu ý với dữ liệu tham khảo từ ảnh 1 và dữ liệu trước đây của  phần dữ liệu tham khảo để nhận định về ảnh 2.
4. Dựa vào các yếu tố kỹ thuật như hình dạng nến, khối lượng, hỗ trợ - kháng cự, tín hiệu đảo chiều, vùng tích lũy hoặc phá vỡ để đưa ra nhận định chi tiết.
5. Kết hợp thông tin trong phần tham khảo để củng cố dự báo.`
    : `Hãy dựa vào nội dung câu hỏi và dữ liệu tham khảo (nếu có) để đưa ra phân tích chi tiết, như một chuyên gia đang tư vấn trực tiếp.`
}

Yêu cầu cách trình bày:
- Viết tự nhiên, thân thiện, dễ hiểu nhưng vẫn thể hiện chiều sâu chuyên môn.
- Không nhắc đến “AI”, “Agent”, hay “ảnh 1/ảnh 2”.
- Khi có dữ liệu hình ảnh, hãy diễn giải như bạn đang nhìn thấy hai biểu đồ: một là biểu đồ cũ để so sánh, một là biểu đồ hiện tại cần phân tích.
- Cung cấp dự đoán ngắn hạn (tăng / giảm / đi ngang) và giải thích bằng các dẫn chứng cụ thể.

Mục tiêu:
- Tạo ra nhận định thực tế, có lập luận kỹ thuật, giúp người đọc hiểu và tin tưởng vào logic phân tích.
`;

  const history = await chat.findOne({
    username: userSession,
    slug: labelname,
  });
  console.log("usersesssion ,labelname", userSession, labelname);
  // Convert sang format contents
  const contents =
    history.ListChat?.map((item) => ({
      role: item.role === "model" ? "model" : "user",
      parts: [{ text: item.content }],
    })) ?? [];

  contents.push({
    role: "user",
    parts: [{ text: prompt }],
  });
  if (allowFilePath && uploaded1 && uploaded2) {
    contents[0].parts.push(
      {
        fileData: {
          fileUri: uploaded1.uri,
          mimeType: uploaded1.mimeType,
        },
      },
      {
        fileData: {
          fileUri: uploaded2.uri,
          mimeType: uploaded2.mimeType,
        },
      }
    );
  }
  const response = await ai.models.generateContent({
    model: "gemini-2.5-flash",
    contents,
    generationConfig: {
      temperature: 0.7,
      maxOutputTokens: 2048,
      metadata: { userSession, timestamp: new Date().toISOString() },
    },
  });

  const text =
    response.output?.[0]?.content?.[0]?.text ||
    response.text ||
    "Không có phản hồi từ model.";

  return {
    question,
    answer: text.trim(),
    imgId: filepath1,
  };
}

async function learningSeft({ question, caption, file = false }) {
  if (!caption || !question) return false;
  try {
    const textToEmbed = file ? caption : question;
    const embedding = await embeddingText({
      caption: textToEmbed,
    }); // question

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
