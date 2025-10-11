import mongoose from "mongoose";

const { Schema } = mongoose;

const StateSchema = new Schema(
  {
    code: { type: String },
    isVerification: { type: Boolean, default: false },
    isResetpassword: { type: Boolean, default: false },
    expire: { type: Date, default: () => new Date(Date.now() + 3 * 60 * 1000) },
  },
  { timestamps: true }
);

const ProfileSchema = new Schema(
  {
    phoneNumber: { type: String },
    email: { type: String },
    role: { type: String, default: "member" },
    gender: { type: Boolean, default: false },
  },
  { timestamps: true }
);

const UserSchema = new Schema(
  {
    username: { type: String },
    passwordHash: { type: String },
    state: StateSchema,
    profile: ProfileSchema,
  },
  { timestamps: true }
);

export default mongoose.model("User", UserSchema);
