import 'package:cupizz_app/src/base/base.dart';

const kIsMyPost = 'MY_POST';

class PostPageController extends GetxController {
  final Debouncer _searchDebouncer = Debouncer(delay: 1.seconds);
  final Debouncer _likeDebouncer = Debouncer(delay: 1.seconds);

  final _posts = Rx<List<Post>>([]);
  List<Post> get posts => _posts.value;
  final _isLastPage = false.obs;
  bool get isLastPage => _isLastPage.value;
  final _currentPage = 1.obs;
  int get currentPage => _currentPage.value;
  final _selectedCategory = Rx<PostCategory?>(null);
  PostCategory? get selectedCategory => _selectedCategory.value;
  final _isMyPost = false.obs;
  bool get isMyPost => _isMyPost.value;
  final _keyword = Rx<String?>(null);
  String? get keyword => _keyword.value;
  final _isIncognitoComment = true.obs;
  bool get isIncognitoComment => _isIncognitoComment.value;
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  PostPageController() {
    _loading(_reload, enableLoading: posts.isExistAndNotEmpty);
  }

  Future onRefresh() => _reload();

  Future loadMore() async {
    if (isLastPage) return;
    await _reload(currentPage + 1);
  }

  Future selectCategory(PostCategory? category) async {
    if (category?.id == selectedCategory?.id) return;
    if (category?.id == kIsMyPost) {
      _isMyPost.value = !isMyPost;
    } else {
      _selectedCategory.value = category;
    }
    await _loading(_reload);
  }

  void search(String keyword) {
    if (this.keyword != keyword) {
      _searchDebouncer.debounce(() {
        _search(keyword);
      });
    }
  }

  Future clearSearch() => _search('');

  void changeIsIncognitoComment() {
    _isIncognitoComment.value = !isIncognitoComment;
  }

  Future commentPost(Post post, String content) async {
    final index = posts.indexWhere((e) => e.id == post.id);
    await trycatch(() async {
      final comment = await Get.find<PostService>().commentPost(
        post.id,
        content,
        isIncognito: isIncognitoComment,
      );
      posts[index].comments!.insert(0, comment);
      posts[index].commentCount = (posts[index].commentCount ?? 0) + 1;
      _posts.value = posts;
      update();
    });
  }

  Future loadmoreComments(Post post) async {
    if (post.commentCount == null ||
        post.comments == null ||
        post.commentCount! <= post.comments!.length) return;
    final index = posts.indexWhere((e) => e.id == post.id);
    await trycatch(() async {
      final lastComment = post.comments!.last;
      final comments = await Get.find<PostService>()
          .getComments(post.id, commentCursorId: lastComment.id!);
      posts[index].comments!.addAll(comments);
      _posts.value = posts;
    });
  }

  Future likePost(Post post, [LikeType? type]) async {
    final index = posts.indexWhere((e) => e.id == post.id);
    final oldLikeType = post.myLikedPostType;
    if (index >= 0) {
      posts[index].myLikedPostType = type ?? LikeType.love;
      posts[index].likeCount = (posts[index].likeCount ?? 0) + 1;
    }
    _posts.value = posts;
    update();

    _likeDebouncer.debounce(() async {
      try {
        // final data =
        await Get.find<PostService>().likePost(post.id, type: type);
        // model.posts[index] = data;
        // model.update(posts: model.posts);
      } catch (e) {
        if (index >= 0) {
          posts[index].myLikedPostType = oldLikeType;
          posts[index].likeCount = (posts[index].likeCount ?? 0) - 1;
        }
        _posts.value = posts;
        update();
        await Fluttertoast.showToast(msg: e.toString());
        rethrow;
      }
    });
  }

  Future unlikePost(Post post) async {
    final index = posts.indexWhere((e) => e.id == post.id);
    final oldLikeType = post.myLikedPostType;
    if (index >= 0) {
      posts[index].myLikedPostType = null;
      posts[index].likeCount = (posts[index].likeCount ?? 0) - 1;
    }
    _posts.value = posts;
    update();

    _likeDebouncer.debounce(() async {
      try {
        // final data =
        await Get.find<PostService>().unlikePost(post.id);
        // model.posts[index] = data;
        // model.update(posts: model.posts);
      } catch (e) {
        if (index >= 0) {
          posts[index].myLikedPostType = oldLikeType;
          posts[index].likeCount = posts[index].likeCount ?? 0 + 1;
        }
        _posts.value = posts;
        update();
        await Fluttertoast.showToast(msg: e.toString());
        rethrow;
      }
    });
  }

  void insertPost(Post post) {
    final index = posts.indexWhere((e) => e.id == post.id);
    if (index > 0) return;
    posts.insert(0, post);
    _posts.value = posts;
  }

  Future _search(String keyword) async {
    _keyword.value = keyword;
    await _loading(_reload);
  }

  Future _reload([int page = 1]) async {
    await trycatch(() async {
      final postsRes = await Get.find<PostService>().getPosts(
        page: page,
        categoryId: selectedCategory?.id ?? '',
        keyword: keyword,
        isMyPost: isMyPost,
      );
      _posts.value = page == 1
          ? postsRes.data ?? []
          : [...posts, ...(postsRes.data ?? [])];
      _currentPage.value = page;
      _isLastPage.value = postsRes.isLastPage ?? isLastPage;
    });
  }

  Future _loading(Function func,
      {bool throwError = false, bool enableLoading = true}) async {
    if (enableLoading) {
      _isLoading.value = true;
    }
    try {
      await func();
    } catch (e) {
      unawaited(Fluttertoast.showToast(msg: e.toString()));
      if (throwError) rethrow;
    } finally {
      if (enableLoading) {
        _isLoading.value = false;
      }
    }
  }
}
