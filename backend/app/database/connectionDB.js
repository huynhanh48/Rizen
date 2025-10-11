import mongoose from "mongoose";
async function ConnectionDB() {
  await mongoose
    .connect(
      "mongodb+srv://Cluster31759:90GSm46zPvsmtdr3@cluster31759.8iy6ono.mongodb.net/mobileapp?retryWrites=true&w=majority&appName=Cluster31759",
      {
        useNewUrlParser: true,
        useUnifiedTopology: true,
      }
    )
    .then(() => console.log("Connected!"));
}
export default ConnectionDB;
