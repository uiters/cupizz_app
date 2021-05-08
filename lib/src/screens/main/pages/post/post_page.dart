library post_page;

import 'package:cupizz_app/src/base/base.dart';
import 'package:flutter/material.dart' hide Router;

import 'post_page.controller.dart';

class PostPage extends StatefulWidget {
  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage>
    with LoadmoreMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Get.put(PostPageController());
  }

  @override
  void onLoadMore() {
    Get.find<PostPageController>().loadMore();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final controller = Get.find<PostPageController>();
    return PrimaryScaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.onRefresh,
          child: Obx(
            () => CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverAppBar(
                  title: _SearchBox(),
                  floating: true,
                  backgroundColor: context.colorScheme.background,
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(50),
                    child: ListCategories(),
                  ),
                ),
                if (controller.isLoading)
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                    (context, index) => PostCard(),
                    childCount: 3,
                  ))
                else
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                    (context, index) => FadeIn(
                      delay: (100 * (index + 1)).milliseconds,
                      child: PostCard(
                        post: controller.posts.getAt(index),
                      ),
                    ),
                    childCount: controller.posts.length +
                        (!controller.isLastPage ? 1 : 0),
                  ))
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: HeroKeys.createPost,
        backgroundColor: context.colorScheme.primary,
        onPressed: () {
          Get.toNamed(Routes.createPost);
        },
        child: Icon(
          Icons.add,
          color: context.colorScheme.onPrimary,
        ),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostPageController>();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 5,
      shadowColor: context.colorScheme.onBackground,
      color: context.colorScheme.background,
      child: TextFormField(
        initialValue: controller.keyword ?? '',
        onChanged: controller.search,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm confession',
          prefixIcon: Icon(Icons.search, color: context.colorScheme.onSurface),
          hintStyle: TextStyle(
            color: context.colorScheme.onSurface,
            fontSize: 16,
          ),
          border: InputBorder.none,
        ),
      ),
      // child: InkWell(
      //   onTap: () {},
      //   child: Row(
      //     children: <Widget>[
      //       IconButton(
      //         icon: Icon(Icons.search, color: context.colorScheme.onSurface),
      //         onPressed: null,
      //       ),
      //       const SizedBox(width: 4),
      //       Text(
      //         'Tìm kiếm bài viết',
      //         style: TextStyle(
      //           color: context.colorScheme.onSurface,
      //           fontSize: 16,
      //         ),
      //         textAlign: TextAlign.start,
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}

class ListCategories extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostPageController>();
    return Container(
      width: MediaQuery.of(context).size.width,
      child: MomentumBuilder(
          controllers: [SystemController],
          builder: (context, snapshot) {
            final systemModel = snapshot<SystemModel>()!;
            if (!systemModel.postCategories.isExistAndNotEmpty) {
              systemModel.controller.getPostCategories();
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              physics: BouncingScrollPhysics(),
              child: Obx(
                () => Row(
                  children: <PostCategory>[
                    PostCategory(value: 'Tất cả'),
                    PostCategory(
                      id: kIsMyPost,
                      value: 'Của tôi',
                      color: context.colorScheme.secondary,
                    ),
                    ...(systemModel.postCategories ?? [])
                  ]
                      .mapIndexed(((e, i) => _buildItem(
                          context,
                          e,
                          i,
                          e.id == kIsMyPost && controller.isMyPost ||
                              controller.selectedCategory?.id == e.id)))
                      .toList(),
                ),
              ),
            );
          }),
    );
  }

  Widget _buildItem(BuildContext context, PostCategory data, int index,
      [bool isSelected = false]) {
    final color = data.color != context.colorScheme.background
        ? data.color
        : context.colorScheme.onBackground;
    return data.value.isExistAndNotEmpty
        ? AnimatedContainer(
            duration: 500.milliseconds,
            margin: EdgeInsets.only(left: index != 0 ? 10 : 0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(90),
                border: Border.all(color: color),
                color: color.withOpacity(isSelected ? 0.2 : 0.0)),
            child: InkWell(
              onTap: () {
                Get.find<PostPageController>().selectCategory(data);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Text(
                  data.value,
                  style: context.textTheme.bodyText1!.copyWith(color: color),
                ),
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
