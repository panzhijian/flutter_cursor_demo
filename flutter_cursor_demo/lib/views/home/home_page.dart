import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_cursor_demo/models/banner.dart';
import 'package:flutter_cursor_demo/models/article.dart';
import 'package:flutter_cursor_demo/viewmodels/home_viewmodel.dart';
import 'package:flutter_cursor_demo/widgets/article_item.dart';
import 'package:flutter_cursor_demo/routes/app_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  late HomeViewModel _viewModel;
  final EasyRefreshController _refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );
  bool _isInitialized = false;
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    _viewModel = context.read<HomeViewModel>();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _init();
      _isInitialized = true;
    }
  }
  
  Future<void> _init() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.initData();
    });
  }
  
  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter_Cursor_Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              context.push(AppRoutes.search);
            },
          ),
        ],
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (viewModel.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    viewModel.errorMessage,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: _init,
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }
          
          return EasyRefresh.builder(
            controller: _refreshController,
            header: const ClassicHeader(
              dragText: '下拉刷新',
              armedText: '释放刷新',
              readyText: '正在刷新...',
              processingText: '正在刷新...',
              processedText: '刷新完成',
              failedText: '刷新失败',
              messageText: '最后更新于 %T',
              showMessage: true,
            ),
            footer: const ClassicFooter(
              dragText: '上拉加载',
              armedText: '释放加载',
              readyText: '正在加载...',
              processingText: '正在加载...',
              processedText: '加载完成',
              failedText: '加载失败',
              noMoreText: '没有更多数据',
              messageText: '最后更新于 %T',
              showMessage: true,
            ),
            onRefresh: () async {
              try {
                await viewModel.refreshData();
                if (viewModel.hasError) {
                  _refreshController.finishRefresh(IndicatorResult.fail);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(viewModel.errorMessage)),
                  );
                } else {
                  _refreshController.finishRefresh(IndicatorResult.success);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('刷新成功')),
                  );
                }
              } catch (e) {
                _refreshController.finishRefresh(IndicatorResult.fail);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('刷新失败: $e')),
                );
              }
            },
            onLoad: () async {
              try {
                if (!viewModel.hasMore) {
                  _refreshController.finishLoad(IndicatorResult.noMore);
                  return;
                }
                
                await viewModel.loadMoreArticles();
                if (viewModel.hasError) {
                  _refreshController.finishLoad(IndicatorResult.fail);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(viewModel.errorMessage)),
                  );
                } else if (!viewModel.hasMore) {
                  _refreshController.finishLoad(IndicatorResult.noMore);
                } else {
                  _refreshController.finishLoad(IndicatorResult.success);
                }
              } catch (e) {
                _refreshController.finishLoad(IndicatorResult.fail);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('加载更多失败: $e')),
                );
              }
            },
            childBuilder: (context, physics) {
              return CustomScrollView(
                physics: physics,
                slivers: [
                  // 轮播图
                  if (viewModel.banners.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _buildBanner(viewModel.banners),
                    ),
                  
                  // 文章列表
                  if (viewModel.articles.isEmpty)
                    const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text('暂无数据'),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final article = viewModel.articles[index];
                          return ArticleItem(article: article);
                        },
                        childCount: viewModel.articles.length,
                      ),
                    ),
                  
                  // 加载更多指示器预留空间
                  SliverToBoxAdapter(
                    child: SizedBox(height: 20.h),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
  
  Widget _buildBanner(List<BannerItem> banners) {
    return Container(
      margin: EdgeInsets.only(top: 16.h, bottom: 16.h),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 180.h,
          aspectRatio: 16/9,
          viewportFraction: 0.8,
          initialPage: 0,
          enableInfiniteScroll: true,
          reverse: false,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 3),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: true,
          scrollDirection: Axis.horizontal,
        ),
        items: banners.map((banner) {
          return Builder(
            builder: (BuildContext context) {
              return GestureDetector(
                onTap: () {
                  if (banner.url != null && banner.url!.isNotEmpty) {
                    final String uri = Uri(
                      path: AppRoutes.articleDetail,
                      queryParameters: {
                        'id': banner.id.toString(),
                        'title': banner.title ?? '',
                        'url': banner.url ?? '',
                      },
                    ).toString();
                    context.push(uri);
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: banner.imagePath ?? '',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 8.h,
                              horizontal: 16.w,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                            child: Text(
                              banner.title ?? '',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
} 