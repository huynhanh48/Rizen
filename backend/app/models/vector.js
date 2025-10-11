import mongoose from "mongoose";

const { Schema } = mongoose;

const vectorDB = new Schema(
  {
    imgId: { type: String },
    label: { type: String },
    caption: { type: String },
    embedding: [Number],
    study: { type: Boolean, default: false },
  },
  { timestamps: true }
);

export default mongoose.model("vector", vectorDB);
