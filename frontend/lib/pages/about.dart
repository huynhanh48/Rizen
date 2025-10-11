import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobileapp/model/imghome.dart';

class AboutState extends StatefulWidget {
  const AboutState({super.key});

  @override
  State<AboutState> createState() => _AboutStateState();
}

class _AboutStateState extends State<AboutState> {
  List<ImageHome> svgItems = [
    ImageHome(
      path: "assets/home-1.svg",
      semanticslabel: "image",
      title: "Nền tảng đầu tư All in One, giúp bạn quản lý tài chính",
      subtitle:
          "Đa dạng hóa khoản đầu tư của bạn từ tiền điện tử, NFT, vàng và cổ phiếu trong một ứng dụng",
    ),
    ImageHome(
      path: "assets/home-2.svg",
      semanticslabel: "image",
      title: "Theo dõi giá trên tất cả các khoản đầu tư",
      subtitle:
          "Thiết lập cảnh báo giá tự động để cho bạn biết về biến động giá của một khoản tài sản cụ thể",
    ),
    ImageHome(
      path: "assets/home-3.svg",
      semanticslabel: "image",
      title: "Kéo dài thời gian thanh toán của bạn theo thời gian",
      subtitle:
          "Chia nhỏ thanh toán của bạn theo thời gian, quản lý chi tiêu dễ dàng hơn với các phương thức thanh toán linh hoạt.",
    ),
    ImageHome(
      path: "assets/home-4.svg",
      semanticslabel: "image",
      title: "Tham gia để có cơ hội giành được 100,000 Dollar",
      subtitle:
          "Mỗi lần bạn bè bạn mời mua hoặc bán, bạn sẽ nhận được 0,0020%. Hoa hồng được tính từ giá trị mua hoặc bán",
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CarouselSlider(
                options: CarouselOptions(
                  height: double.infinity,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  viewportFraction: 1,
                ),
                items: svgItems.map((item) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Column(
                        children: [
                          Expanded(
                            child: Container(
                              color: Color.fromRGBO(248, 248, 248, 1),
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),
                                child: item.svg,
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(0),
                              isThreeLine: true,
                              title: Text("${item.title}"),
                              subtitle: Text("${item.subtitle}"),
                              titleTextStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/authentication/login");
                      },
                      child: Text("Get started"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(151, 0, 193, 1),
                        foregroundColor: Colors.white,
                        textStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(20),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      style: ButtonStyle(splashFactory: NoSplash.splashFactory),
                      onPressed: () {},
                      child: Text(
                        "Browse asset",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
