part of '../home_screen.dart';

class OptionsDrawerController extends ChangeNotifier {
  bool _isMenuOpen = false;

  void openMenu() {
    if (!_isMenuOpen) {
      _isMenuOpen = true;
      notifyListeners();
    }
  }

  void closeMenu() {
    if (_isMenuOpen) {
      _isMenuOpen = false;
      notifyListeners();
    }
  }
}

class OptionsDrawer extends StatefulWidget {
  final double sidebarSize;
  final OptionsDrawerController controller;

  const OptionsDrawer({
    Key key,
    this.sidebarSize = 300,
    this.controller,
  }) : super(key: key);

  @override
  _OptionsDrawerState createState() => _OptionsDrawerState();
}

class _OptionsDrawerState extends State<OptionsDrawer> {
  OptionsDrawerController controller;
  bool isMenuOpen = false;
  Offset _offset = Offset(0, 0);

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? OptionsDrawerController();

    controller.addListener(() {
      setState(() {
        isMenuOpen = controller._isMenuOpen;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedPositioned(
      duration: Duration(milliseconds: 1500),
      right: isMenuOpen ? 0 : -widget.sidebarSize,
      top: 0,
      curve: Curves.elasticOut,
      child: SizedBox(
        width: widget.sidebarSize,
        child: GestureDetector(
          onPanUpdate: (details) {
            if (details.localPosition.dx <= widget.sidebarSize) {
              setState(() {
                _offset = details.localPosition;
              });
            }

            if (details.localPosition.dx > widget.sidebarSize - 20 &&
                details.delta.distanceSquared > 2) {
              setState(() {
                isMenuOpen = true;
              });
            }
          },
          onPanEnd: (details) {
            setState(() {
              _offset = Offset(0, 0);
            });
          },
          child: Stack(
            children: <Widget>[
              CustomPaint(
                size: Size(widget.sidebarSize, size.height),
                painter: _DrawerPainter(offset: _offset),
              ),
              _buildBody()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTitle(),
            const SizedBox(height: 10),
            _buildGender(),
            _buildHobbies(),
            _buildDistance(),
            _buildAge(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          Strings.drawer.filter,
          style:
              context.textTheme.headline6.copyWith(fontWeight: FontWeight.bold),
        ),
        InkWell(
          enableFeedback: true,
          child: Icon(
            Icons.arrow_right_alt,
            color: context.colorScheme.onBackground,
            size: 30,
          ),
          onTap: () {
            controller.closeMenu();
          },
        ),
      ],
    );
  }

  Widget _buildGender() {
    return _buildItem(
      title: Strings.drawer.whoAreYouLookingFor,
      body: Row(
        children: [
          Expanded(child: _buildOptionButton(title: Strings.common.man)),
          const SizedBox(width: 10),
          Expanded(
              child: _buildOptionButton(
            title: Strings.common.woman,
            isSelected: true,
          )),
        ],
      ),
    );
  }

  Widget _buildHobbies() {
    return _buildItem(
      title: Strings.common.hobbies,
      actions:
          Text(Strings.drawer.upTo5Pieces, style: context.textTheme.caption),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 10,
            children: ['Đá banh', 'Đá bóng', 'Đá lông nheo', 'Đá gà', 'Đập đá']
                .map(
                  (e) => _buildOptionButton(title: e, isSelected: true),
                )
                .toList(),
          ),
          OutlineButton(
            onPressed: () {},
            borderSide: BorderSide(width: 1, color: Colors.grey[500]),
            highlightColor: context.colorScheme.primary.withOpacity(0.5),
            child: Text(Strings.drawer.chooseOtherHoddies),
          )
        ],
      ),
    );
  }

  Widget _buildDistance() {
    return _buildItem(
      title: Strings.common.distance,
      actions: Row(
        children: [
          Icon(
            Icons.room,
            size: 12,
            color: Colors.grey[500],
          ),
          const SizedBox(width: 5),
          Text('5 km', style: context.textTheme.caption),
        ],
      ),
      body: FlutterSlider(
        values: [300],
        max: 1000,
        min: 0,
        trackBar: FlutterSliderTrackBar(
          activeTrackBar: BoxDecoration(color: context.colorScheme.primary),
        ),
        handler: HeartSliderHandler(context),
        tooltip: CustomSliderTooltip(context, unit: 'km'),
        onDragging: (handlerIndex, lowerValue, upperValue) {},
      ),
    );
  }

  Widget _buildAge() {
    return _buildItem(
      title: Strings.common.age,
      actions: Text('18 - 23 tuổi', style: context.textTheme.caption),
      body: FlutterSlider(
        values: [18, 23],
        max: 60,
        min: 18,
        rangeSlider: true,
        minimumDistance: 1,
        trackBar: FlutterSliderTrackBar(
          activeTrackBar: BoxDecoration(color: context.colorScheme.primary),
        ),
        handlerWidth: 18,
        handlerHeight: 18,
        handler: HeartSliderHandler(context, iconSize: 14),
        rightHandler: HeartSliderHandler(context, iconSize: 14),
        tooltip: CustomSliderTooltip(context, unit: 'tuổi'),
        onDragging: (handlerIndex, lowerValue, upperValue) {},
      ),
    );
  }

  Widget _buildItem({
    @required String title,
    Widget actions,
    Widget body,
    bool showBottomSeparator = true,
  }) {
    return Column(
      children: [
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: context.textTheme.bodyText1
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            if (actions != null) actions
          ],
        ),
        if (body != null) ...[const SizedBox(height: 10), body],
        const SizedBox(height: 15),
        if (showBottomSeparator) Divider(color: Colors.grey[500])
      ],
    );
  }

  Widget _buildOptionButton({
    @required String title,
    bool isSelected = false,
    Function onPressed,
  }) {
    final child = Text(title,
        style: context.textTheme.button.copyWith(
            color: !isSelected
                ? Colors.grey[500]
                : context.colorScheme.onPrimary));
    return isSelected
        ? RaisedButton(
            onPressed: () => onPressed?.call(),
            color: isSelected
                ? context.colorScheme.primary
                : context.colorScheme.onPrimary,
            child: child,
          )
        : OutlineButton(
            onPressed: () => onPressed?.call(),
            borderSide: BorderSide(width: 1, color: Colors.grey[500]),
            highlightColor: context.colorScheme.primary.withOpacity(0.5),
            child: child,
          );
  }
}

class _DrawerPainter extends CustomPainter {
  final Offset offset;
  final Color color;

  _DrawerPainter({this.offset, this.color = Colors.white});

  double getControlPointX(double width) {
    if (offset.dx == 0) {
      return 0;
    } else {
      return offset.dx > width ? -offset.dx : -75;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2.0);
    Path path = Path();
    path.moveTo(size.width * 2, 0);
    path.lineTo(0, -50);
    path.quadraticBezierTo(
        getControlPointX(size.width), offset.dy, 0, size.height);
    path.lineTo(size.width * 2, size.height + 50);
    path.close();

    canvas.drawShadow(path, Colors.grey[900], 2.0, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class HeartSliderHandler extends FlutterSliderHandler {
  HeartSliderHandler(BuildContext context, {double iconSize})
      : super(
          child: Icon(
            Icons.favorite,
            color: context.colorScheme.primary,
            size: iconSize,
          ),
          decoration: BoxDecoration(
            color: context.colorScheme.background,
            border: Border.all(color: context.colorScheme.primary),
            shape: BoxShape.circle,
          ),
        );
}

class CustomSliderTooltip extends FlutterSliderTooltip {
  CustomSliderTooltip(BuildContext context, {String unit = ''})
      : super(
          boxStyle: FlutterSliderTooltipBox(
            decoration: BoxDecoration(
              color: context.colorScheme.primary.withOpacity(.8),
            ),
          ),
          textStyle: context.textTheme.caption
              .copyWith(color: context.colorScheme.onPrimary),
          format: (v) => '${double.tryParse(v)?.round() ?? v} $unit',
        );
}
