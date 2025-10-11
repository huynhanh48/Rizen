import mongoose, { plugin } from "mongoose";
import slug from "mongoose-slug-generator";

mongoose.plugin(slug);

const { Schema } = mongoose;

const MonthSchema = new Schema(
  {
    month: { type: Schema.Types.Mixed, required: true }, // number 1-12 hoặc "total"
    usd: { type: Number, default: 0 },
    ton: { type: Number, default: 0 },
  },
  { _id: false } // không cần _id cho mỗi tháng
);

const ProductSchema = new Schema(
  {
    name: { type: String, required: true }, // tên sản phẩm
    slug: { type: String, slug: "name" },
    year: { type: Number, required: true }, // năm
    data: { type: [MonthSchema], default: [] }, // danh sách tháng
  },
  { timestamps: true }
);

export default mongoose.model("Product", ProductSchema);
