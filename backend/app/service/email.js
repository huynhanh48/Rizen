import nodemailer from "nodemailer";
import dotenv from "dotenv";
import fs from "fs";
import { fileURLToPath } from "url";
import path, { dirname } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
dotenv.config();

// Create a test account or replace with real credentials.
const transporter = nodemailer.createTransport({
  host: "smtp.gmail.com",
  port: 587,
  secure: false, // true for 465, false for other ports
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD,
  },
});

// Wrap in an async IIFE so we can use await.
async function sendEmail(to, code, subject) {
  const { html, subjectTo } = await replaceHtml(to, code, subject, "code.html");
  const info = await transporter.sendMail({
    from: '"Rizen" <anhvo482004@gmail.com>',
    to: `${to}`,
    subject: subjectTo,
    html: html, // HTML body
  });
}
async function replaceHtml(to, code, subject, filename) {
  const filepath = path.join(__dirname, "../", "templates", filename);
  const content = await fs.readFileSync(filepath, "utf-8");
  const html = content.replace("{{code}}", code).replace("{{email}}", to);
  return { html, subjectTo: subject };
}
function randomCode() {
  return Math.floor(1000 + Math.random() * 9000);
}
function convertDate(dateString) {
  const options = {
    timeZone: "Asia/Ho_Chi_Minh",
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
    hour12: false,
  };

  const formatted = new Intl.DateTimeFormat("vi-VN", options).format(
    dateString
  );
  return formatted;
}
export { sendEmail, randomCode, convertDate };
