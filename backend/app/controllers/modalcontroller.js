import MLR from "ml-regression-multivariate-linear";

function buildModel(data) {
  // data là array gồm {month, year, usd, ton}
  const x = data.map((e) => [e.month, e.year]); // input: month + year
  const y = data.map((e) => [e.usd, e.ton]); // output: usd, ton
  const mlr = new MLR(x, y);
  return { mlr, cleanData: data };
}

async function prediction({ mlr, lastMonthData, count = 3 }) {
  const values = [];

  // lastMonthData = {month, year} => dự đoán các tháng tiếp theo
  let { month: lastMonth, year: lastYear } = lastMonthData;

  for (let i = 1; i <= count; i++) {
    let nextMonth = lastMonth + i;
    let nextYear = lastYear;

    // nếu vượt quá tháng 12, tăng năm
    if (nextMonth > 12) {
      nextMonth = nextMonth % 12;
      nextYear += 1;
    }

    const pred = mlr.predict([nextMonth, nextYear]); // phải truyền month+year

    if (isNaN(pred[0]) || isNaN(pred[1])) {
      console.error(
        "Prediction returned NaN at month:",
        nextMonth,
        nextYear,
        pred
      );
      continue;
    }

    values.push({
      month: nextMonth,
      year: nextYear,
      usd: Math.round(pred[0]),
      ton: Math.round(pred[1]),
    });
  }

  return values;
}

class ModalController {
  // POST /api/modal
  async index(req, res) {
    try {
      const { data } = req.body;
      if (!Array.isArray(data) || data.length === 0) {
        return res
          .status(400)
          .json({ error: "data must be a non-empty array" });
      }

      const { mlr, cleanData } = buildModel(data);
      console.log(cleanData)
      const lastMonthData = cleanData[cleanData.length - 1]; // lấy tháng cuối cùng để dự đoán tiếp

      const predictions = await prediction({ mlr, lastMonthData, count: 3 });

      res.status(200).json({ success: true, predictions });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
}

export default new ModalController();
