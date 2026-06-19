import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:your_app_name/src/data/model/model_product.dart';
import 'package:your_app_name/src/utils/configs/application.dart';
import 'package:photo_view/photo_view.dart';

class ImageZoomScreen extends StatefulWidget {
  final List<ImageListModel>? imageList;
  final String pdf;
  final int sourceId;

  const ImageZoomScreen(
      {super.key,
      required this.imageList,
      required this.pdf,
      required this.sourceId});

  @override
  State<ImageZoomScreen> createState() => _ImageZoomScreenState();
}

class _ImageZoomScreenState extends State<ImageZoomScreen> {
  int currentImageIndex = 0;
  final memoryCacheManager = DefaultCacheManager();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SizedBox(
                height: height * 0.8,
                child: widget.pdf != ''
                    ? const PDF().cachedFromUrl(
                        key: const Key("product_zoom"),
                        "${widget.pdf}?cacheKey=${UniqueKey().toString()}",
                        placeholder: (progress) => Center(
                            child: Text(
                          '$progress %',
                          style: const TextStyle(color: Colors.white),
                        )),
                        errorWidget: (error) => Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.black,
                          child: Text(
                            error.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: CarouselSlider(
                              options: CarouselOptions(
                                height: 550.0,
                                viewportFraction: 1.0,
                                enlargeCenterPage: false,
                                enableInfiniteScroll:
                                    widget.imageList!.length > 1,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    currentImageIndex = index;
                                  });
                                },
                              ),
                              items: widget.imageList?.map((imageItem) {
                                    return Builder(
                                      builder: (BuildContext context) {
                                        String imageUrlString = widget
                                                        .sourceId ==
                                                    2 &&
                                                imageItem.logo != null &&
                                                imageItem.logo !=
                                                    'admin/News.jpeg'
                                            ? imageItem.logo!
                                            : (widget.sourceId == 3 || widget.sourceId == 4) &&
                                                    imageItem.logo != null &&
                                                    imageItem.logo != "" &&
                                                    imageItem.logo !=
                                                        'admin/News.jpeg'
                                                ? imageItem.logo!
                                                : "${Application.picturesURL}${imageItem.logo!.isNotEmpty ? imageItem.logo : 'admin/News.jpeg'}";
                                        return Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 5.0),
                                          decoration: const BoxDecoration(
                                            color: Colors.black,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {},
                                            child: PhotoView(
                                              imageProvider:
                                                  NetworkImage(imageUrlString),
                                              minScale: PhotoViewComputedScale
                                                  .contained,
                                              maxScale: PhotoViewComputedScale
                                                      .covered *
                                                  2,
                                              initialScale:
                                                  PhotoViewComputedScale
                                                      .contained,
                                              heroAttributes:
                                                  PhotoViewHeroAttributes(
                                                      tag: imageUrlString),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }).toList() ??
                                  [],
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          if (widget.imageList!.length > 1)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: widget.imageList!.map((url) {
                                int index = widget.imageList!.indexOf(url);
                                return Container(
                                  width: 10.0,
                                  height: 10.0,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 2.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: currentImageIndex == index
                                        ? Colors.blueAccent
                                        : Colors.grey,
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
