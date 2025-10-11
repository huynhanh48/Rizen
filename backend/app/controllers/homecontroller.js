class HomeController{
    index(req,res,next){
        res.send("home")
    }
}
export  default  new HomeController()