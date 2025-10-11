function GetProducts(req, res, next) {
  const { sort, column } = req.query;
  if (sort && column) {
    req.session.optsSort = {
      type: sort,
      column: column,
    };
  } else {
    req.session.optsSort = {
      type: "desc",
      column: "usd",
    };
  }
  console.log("------------middleware------------", req.session.optsSort);
  next();
}

export default GetProducts;
