import mongoose, { plugin } from "mongoose";
import slug from "mongoose-slug-generator";

mongoose.plugin(slug);

const { Schema } = mongoose;
const Messagechema = new Schema(
  {
    role: { type: String, default: "user" },
    content: { type: String },
    img:{type:String ,default:null}
  },
  { timestamps: true }
);

const Chatchema = new Schema(
  {
    name: { type: String, required: true },
    slug: { type: String, slug: "name" },
    username: { type: String },
    ListChat: { type: [Messagechema] },
  },
  { timestamps: true }
);

export default mongoose.model("Chats", Chatchema);
