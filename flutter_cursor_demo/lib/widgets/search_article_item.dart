import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_cursor_demo/models/article.dart';
import 'package:flutter_cursor_demo/routes/app_routes.dart';

class SearchArticleItem extends StatelessWidget {
  final Article article;
  
  const SearchArticleItem({
    Key? key, 
    required this.article,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: InkWell(
        onTap: () => _onTap(context),
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.title ?? '',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),
              if (article.desc != null && article.desc!.isNotEmpty)
                Text(
                  article.desc!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.person, size: 16.sp, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Text(
                    article.author != null && article.author!.isNotEmpty
                        ? article.author!
                        : (article.shareUser ?? ''),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.access_time, size: 16.sp, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Text(
                    article.niceDate ?? '',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                children: [
                  if (article.superChapterName != null)
                    _buildTag(article.superChapterName!),
                  if (article.chapterName != null)
                    _buildTag(article.chapterName!),
                  ...article.tags.map((tag) => _buildTag(tag.name ?? '')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          color: Colors.blue,
        ),
      ),
    );
  }
  
  void _onTap(BuildContext context) {
    String url = article.link ?? '';
    if (!url.startsWith('http')) {
      url = 'https://www.wanandroid.com$url';
    }
    
    final String uri = Uri(
      path: AppRoutes.articleDetail,
      queryParameters: {
        'id': article.id.toString(),
        'title': article.title ?? '',
        'url': url,
      },
    ).toString();
    context.push(uri);
  }
} 