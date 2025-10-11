import xlsx from "xlsx";
import path from "path";
import { STATES } from "mongoose";
import product from "../models/product.js";
class FileUploadController {
  // /api/fileupload/upfile
  async index(req, res, next) {
    try {
      const file = req.file;
      if (!file || file.mimetype != "application/vnd.ms-excel") {
        return res.status(400).json({ message: "file is invalid " });
      }

      // đọc file excel
      const workbook = xlsx.readFile(file.path + path.extname(file.path));
      const getName = workbook.SheetNames[0];
      const getSheet = workbook.Sheets[getName];
      const data = xlsx.utils.sheet_to_json(getSheet);

      // lấy key đầu tiên
      const firstKey = Object.keys(data[0])[0];
      const startIndex = data.findIndex(
        (item) => item[firstKey] === "Nhóm/Mặt hàng chủ yếu"
      );

      let arrayConvert = [];
      if (startIndex !== -1) {
        data.slice(startIndex + 1).forEach((item) => {
          arrayConvert.push(convertItemToMonths(item));
        });
      }

      // xoá các item không có tên sản phẩm
      arrayConvert = arrayConvert.filter((i) => i.name);

      // lưu vào mongo
      // await product.insertMany(arrayConvert);
      for (const item of arrayConvert) {
        await product.create(item);
      }

      return res.status(200).json({
        message: "sucessful",
        count: arrayConvert.length,
      });
    } catch (err) {
      console.error("Upload error:", err);
      return res.status(500).json({ message: "internal error" });
    }
  }
  // /api/fileupload/products/getname?slug=
  async getProductName(req, res, next) {
    const { slug } = req.query;
    const productName = await product.aggregate([
      { $match: { slug: slug } },
      {
        $project: {
          name: 1,
          year: 1,
          slug: 1,
          data: {
            $filter: {
              input: "$data",
              as: "item",
              cond: { $ne: ["$$item.month", "total"] },
            },
          },
        },
      },
    ]);
    const mergedData = [];
    productName.forEach((doc) => {
      doc.data.forEach((d) => {
        mergedData.push({ ...d, year: doc.year });
      });
    });
    const productConvert = {
      message: "successful",
      name: productName[0].name,
      slug: productName[0].slug,
      data: mergedData,
    };
    res.status(200).json(productConvert);
  }
  // /api/fileupload/products
  async getProducts(req, res, next) {
    try {
      const { type, column } = req.session.optsSort;
      const valueSort = type == "desc" ? -1 : 1;
      const products = await product.aggregate([
        {
          $addFields: {
            usdTotal: { $arrayElemAt: ["$data.usd", -1] },
          },
        },
        {
          $sort: {
            usdTotal: -1,
            updatedAt: 1,
            // [`data.${column}`]: valueSort,
          },
        },
        {
          $group: {
            _id: "$slug", // nhóm theo slug
            product: { $last: "$$ROOT" },
          },
        },
        { $replaceRoot: { newRoot: "$product" } },
      ]);
      if (products) {
        console.log(products);
        return res.status(200).json({ message: "successful", data: products });
      }
      return res.status(400).json({ message: "error  when get database " });
    } catch (error) {
      return res
        .status(400)
        .json({ message: "error  when get database ", data: { error } });
    }
  }
}
// Convert one item (one product) into { name, data: [...months..., {month: 'total', ...}] }
// Short comments in English for learning.
function convertItemToMonths(item) {
  // find first key that is not __EMPTY_x
  const nameKey = Object.keys(item).find((k) => !k.startsWith("__EMPTY_"));
  const name = item[nameKey] || "";

  // extract year from the key (search 4-digit number)
  let year = null;
  const yearMatch = nameKey.match(/\d{4}/);
  if (yearMatch) year = parseInt(yearMatch[0], 10);

  const monthsMap = {}; // month -> { month, usd, ton }
  let maxIdx = 0;

  Object.entries(item).forEach(([key, value]) => {
    if (!key.startsWith("__EMPTY")) return; // skip header col

    // handle "__EMPTY" (no suffix) as index 0
    const idx =
      key === "__EMPTY" ? 0 : parseInt(key.replace("__EMPTY_", ""), 10);
    if (Number.isNaN(idx)) return;

    if (idx > maxIdx) maxIdx = idx;

    const month = Math.floor(idx / 2) + 1; // pair => month number
    if (!monthsMap[month]) monthsMap[month] = { month, usd: 0, ton: 0 };

    const num =
      typeof value === "number" && !Number.isNaN(value)
        ? value
        : value
        ? Number(value)
        : 0;

    if (idx % 2 === 0) {
      // even index => USD
      monthsMap[month].ton = Math.round(num);
    } else {
      // odd index => Ton
      monthsMap[month].usd = Math.round(num);
    }
  });

  // detect total month (last pair is total)
  const totalMonth = Math.floor(maxIdx / 2) + 1;

  const data = [];
  for (let m = 1; m < totalMonth; m++) {
    if (monthsMap[m]) data.push(monthsMap[m]);
    else data.push({ month: m, usd: 0, ton: 0 });
  }

  const totalObj = monthsMap[totalMonth] || { usd: 0, ton: 0 };
  const total = { month: "total", usd: totalObj.usd, ton: totalObj.ton };

  data.push(total);

  return { name, year, data };
}

export default new FileUploadController();
