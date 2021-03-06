import 'package:cupizz_app/src/base/base.dart';

class UserCard extends StatelessWidget {
  final Function? onPressed;
  final SimpleUser simpleUser;
  final bool showHobbies;
  final double radius;

  const UserCard({
    Key? key,
    this.onPressed,
    required this.simpleUser,
    this.showHobbies = true,
    this.radius = 15,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed as void Function()?,
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
              child: Hero(
            tag: simpleUser.cover?.id ?? '',
            child: CustomNetworkImage(
              simpleUser.cover?.url ?? simpleUser.avatar?.url ?? '',
              borderRadius: BorderRadius.circular(radius),
            ),
          )),
          Positioned(
            bottom: 0,
            child: Container(
              height: 200,
              width: context.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.colorScheme.background.withOpacity(0),
                    context.colorScheme.background.withOpacity(0),
                    context.colorScheme.background.withOpacity(0.03),
                    context.colorScheme.background.withOpacity(0.07),
                    context.colorScheme.background.withOpacity(0.1),
                    context.colorScheme.background.withOpacity(0.3),
                    context.colorScheme.background.withOpacity(0.5),
                    context.colorScheme.background.withOpacity(0.7),
                    context.colorScheme.background.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CustomNetworkImage(
                          simpleUser.avatar?.thumbnail ?? '',
                          isAvatar: true),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 5,
                            crossAxisAlignment: WrapCrossAlignment.end,
                            children: [
                              Text(
                                simpleUser.displayName!,
                                style: context.textTheme.subtitle1!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.colorScheme.primary,
                                ),
                              ),
                              if (simpleUser.age != null)
                                Text(
                                  simpleUser.age.toString(),
                                  style: context.textTheme.caption,
                                ),
                            ],
                          ),
                          if (simpleUser.introduction.isExistAndNotEmpty)
                            Text(
                              simpleUser.introduction!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.caption!.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (showHobbies) ...[
                  Divider(color: Colors.grey[300]),
                  _HobbyList(
                    data: simpleUser.getSameHobbies(context) ?? [],
                  )
                ]
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _HobbyList extends StatelessWidget {
  final List<HobbyWithIsSelect> data;
  const _HobbyList({Key? key, this.data = const []}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
            style: context.textTheme.bodyText1,
            children: data
                .asMap()
                .map(
                  (i, e) => MapEntry(
                      i,
                      TextSpan(
                        text: e.hobby.value != null
                            ? '${e.hobby.value}${i < data.length - 1 ? ', ' : ''}'
                            : '',
                        style: TextStyle(
                          color: e.isSelected
                              ? context.colorScheme.primary
                              : context.colorScheme.onBackground,
                        ),
                      )),
                )
                .values
                .toList()));
  }
}
