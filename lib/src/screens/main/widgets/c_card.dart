part of '../home_screen.dart';

enum SwipDirection {
  Left,
  Right,
}

class SwipInfo {
  final int cardIndex;
  final SwipDirection direction;

  SwipInfo(
    this.cardIndex,
    this.direction,
  );
}

typedef ForwardCallback(int index, SwipInfo info);
typedef UpdateCallBack(DragStartDetails details);
typedef BackCallback(int index);
typedef EndCallback();

class CCardController {
  _CCardState _state;

  void _bindState(_CCardState state) {
    this._state = state;
  }

  int get index => _state?._frontCardIndex ?? 0;

  forward({SwipDirection direction = SwipDirection.Right}) {
    final SwipInfo swipInfo = SwipInfo(_state._frontCardIndex, direction);
    _state._swipInfoList.add(swipInfo);
    _state._runChangeOrderAnimation();
  }

  back() {
    _state._runReverseOrderAnimation();
  }

  reset() {
    _state._reset();
  }

  void dispose() {
    _state = null;
  }
}

class CCard extends StatefulWidget {
  final EdgeInsetsGeometry padding;

  final Size size;

  final List<Widget> cards;

  final ForwardCallback onForward;

  final BackCallback onBack;

  final EndCallback onEnd;

  final VoidCallback onSwipeLeft;

  final VoidCallback onSwipeRight;

  final CCardController controller;

  CCard({
    @required this.cards,
    this.controller,
    this.onForward,
    this.onBack,
    this.onEnd,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.size = const Size(380, 400),
    this.padding = EdgeInsets.zero,
  })  : assert(cards != null),
        assert(cards.length > 0);

  @override
  _CCardState createState() => _CCardState();
}

class _CCardState extends State<CCard> with TickerProviderStateMixin {
  final List<Widget> _cards = [];

  final List<SwipInfo> _swipInfoList = [];

  Alignment _frontCardAlignment = CardAlignments.front;

  AnimationController _cardChangeController;

  AnimationController _cardReverseController;

  Animation<Alignment> _reboundAnimation;

  AnimationController _reboundController;

  int _frontCardIndex = 0;
  double _frontCardRotation = 0.0;
  double xOffset = 100;
  double left = -100;
  double right = -100;
  double limit = 10;

  Widget _frontCard(BoxConstraints constraints) {
    Widget child = _frontCardIndex < _cards.length
        ? _cards[_frontCardIndex]
        : const SizedBox.shrink();
    bool forward = _cardChangeController.status == AnimationStatus.forward;
    bool reverse = _cardReverseController.status == AnimationStatus.forward;

    Widget rotate = Transform.rotate(
      angle: (math.pi / 180.0) * _frontCardRotation,
      child: SizedBox.fromSize(
        size: CardSizes.front(constraints),
        child: Padding(
          padding: widget.padding,
          child: Stack(
            children: <Widget>[
              Positioned.fill(child: child),
              if (widget.cards.length != 0)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _frontCardAlignment.x > 0
                            ? context.colorScheme.primary.withOpacity(
                                _frontCardAlignment.x.abs() / (limit * 2))
                            : Colors.grey.withOpacity(
                                _frontCardAlignment.x.abs() / (limit * 2)),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );

    if (reverse) {
      return Align(
        alignment: CardReverseAnimations.frontCardShowAnimation(
          _cardReverseController,
          CardAlignments.front,
          _swipInfoList[_frontCardIndex],
        ).value,
        child: rotate,
      );
    } else if (forward) {
      return Align(
        alignment: CardAnimations.frontCardDisappearAnimation(
          _cardChangeController,
          _frontCardAlignment,
          _swipInfoList[_frontCardIndex],
        ).value,
        child: rotate,
      );
    } else {
      return Align(
        alignment: _frontCardAlignment,
        child: rotate,
      );
    }
  }

  Widget _middleCard(BoxConstraints constraints) {
    Widget child = _frontCardIndex < _cards.length - 1
        ? Padding(padding: widget.padding, child: _cards[_frontCardIndex + 1])
        : const SizedBox.shrink();
    bool forward = _cardChangeController.status == AnimationStatus.forward;
    bool reverse = _cardReverseController.status == AnimationStatus.forward;

    if (reverse) {
      return Align(
        alignment: CardReverseAnimations.middleCardAlignmentAnimation(
          _cardReverseController,
        ).value,
        child: SizedBox.fromSize(
          size: CardReverseAnimations.middleCardSizeAnimation(
            _cardReverseController,
            constraints,
          ).value,
          child: child,
        ),
      );
    } else if (forward) {
      return Align(
        alignment: CardAnimations.middleCardAlignmentAnimation(
          _cardChangeController,
        ).value,
        child: SizedBox.fromSize(
          size: CardAnimations.middleCardSizeAnimation(
            _cardChangeController,
            constraints,
          ).value,
          child: child,
        ),
      );
    } else {
      return Align(
        alignment: CardAlignments.middle,
        child: SizedBox.fromSize(
          size: CardSizes.middle(constraints),
          child: child,
        ),
      );
    }
  }

  Widget _backCard(BoxConstraints constraints) {
    Widget child = _frontCardIndex < _cards.length - 2
        ? Padding(padding: widget.padding, child: _cards[_frontCardIndex + 2])
        : Container();
    bool forward = _cardChangeController.status == AnimationStatus.forward;
    bool reverse = _cardReverseController.status == AnimationStatus.forward;

    if (reverse) {
      return Align(
        alignment: CardReverseAnimations.backCardAlignmentAnimation(
          _cardReverseController,
        ).value,
        child: SizedBox.fromSize(
          size: CardReverseAnimations.backCardSizeAnimation(
            _cardReverseController,
            constraints,
          ).value,
          child: child,
        ),
      );
    } else if (forward) {
      return Align(
        alignment: CardAnimations.backCardAlignmentAnimation(
          _cardChangeController,
        ).value,
        child: SizedBox.fromSize(
          size: CardAnimations.backCardSizeAnimation(
            _cardChangeController,
            constraints,
          ).value,
          child: child,
        ),
      );
    } else {
      return Align(
        alignment: CardAlignments.back,
        child: SizedBox.fromSize(
          size: CardSizes.back(constraints),
          child: child,
        ),
      );
    }
  }

  bool _isAnimating() {
    return _cardChangeController.status == AnimationStatus.forward ||
        _cardReverseController.status == AnimationStatus.forward;
  }

  void _runReboundAnimation(Offset pixelsPerSecond, Size size) {
    _reboundAnimation = _reboundController.drive(
      AlignmentTween(
        begin: _frontCardAlignment,
        end: CardAlignments.front,
      ),
    );

    final double unitsPerSecondX = pixelsPerSecond.dx / size.width;
    final double unitsPerSecondY = pixelsPerSecond.dy / size.height;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;
    const spring = SpringDescription(mass: 30, stiffness: 1, damping: 1);
    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);

    _reboundController.animateWith(simulation);
    _return();
  }

  void _runChangeOrderAnimation() {
    if (_isAnimating()) {
      return;
    }

    if (_frontCardIndex >= _cards.length) {
      return;
    }

    _cardChangeController.reset();
    _cardChangeController.forward();
  }

  void _runReverseOrderAnimation() {
    if (_isAnimating()) {
      return;
    }

    if (_frontCardIndex == 0) {
      _swipInfoList.clear();
      return;
    }

    _cardReverseController.reset();
    _cardReverseController.forward();
  }

  void _forwardCallback() {
    _frontCardIndex++;
    _return();
    if (widget.onForward != null && widget.onForward is Function) {
      widget.onForward(
        _frontCardIndex,
        _swipInfoList[_frontCardIndex - 1],
      );
    }

    if (widget.onEnd != null &&
        widget.onEnd is Function &&
        _frontCardIndex >= _cards.length) {
      widget.onEnd();
    }
  }

  void _backCallback() {
    _return();
    if (widget.onBack != null && widget.onBack is Function) {
      widget.onBack(_frontCardIndex);
    }
  }

  void _return() {
    _frontCardRotation = 0.0;
    _frontCardAlignment = CardAlignments.front;
    setState(() {});
  }

  void _reset() {
    _cards.clear();
    _cards.addAll(widget.cards);
    _swipInfoList.clear();
    _frontCardIndex = 0;
    _return();
  }

  void _stop() {
    _reboundController.stop();
    _cardChangeController.stop();
    _cardReverseController.stop();
  }

  void _updateFrontCardAlignment(DragUpdateDetails details, Size size) {
    final double speed = 10.0;

    _frontCardAlignment += Alignment(
      details.delta.dx / (size.width / 2) * speed,
      details.delta.dy / (size.height / 2) * speed,
    );

    _frontCardRotation = _frontCardAlignment.x;
    setState(() {});
  }

  void _judgeRunAnimation(DragEndDetails details, Size size) {
    final bool isSwipLeft = _frontCardAlignment.x < -limit;
    final bool isSwipRight = _frontCardAlignment.x > limit;

    Timer.periodic(Duration(milliseconds: 1), (timer) {
      setState(() {
        left = math.max(-xOffset, left - 1);
        right = math.max(-xOffset, right - 1);
      });
      if (left == -xOffset && right == -xOffset) {
        timer.cancel();
      }
    });

    if (isSwipLeft || isSwipRight) {
      _runChangeOrderAnimation();
      if (isSwipLeft) {
        _swipInfoList.add(SwipInfo(_frontCardIndex, SwipDirection.Left));
        widget.onSwipeLeft?.call();
      } else {
        _swipInfoList.add(SwipInfo(_frontCardIndex, SwipDirection.Right));
        widget.onSwipeRight?.call();
      }
    } else {
      _runReboundAnimation(details.velocity.pixelsPerSecond, size);
    }
  }

  @override
  void initState() {
    super.initState();

    _cards.addAll(widget.cards);

    if (widget.controller != null && widget.controller is CCardController) {
      widget.controller._bindState(this);
    }

    _cardChangeController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _forwardCallback();
        }
      });

    _cardReverseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.forward) {
          _frontCardIndex--;
        } else if (status == AnimationStatus.completed) {
          _backCallback();
        }
      });

    _reboundController = AnimationController(vsync: this)
      ..addListener(() {
        setState(() {
          _frontCardAlignment = _reboundAnimation.value;
        });
      });
  }

  @override
  void dispose() {
    _cardReverseController.dispose();
    _cardChangeController.dispose();
    _reboundController.dispose();
    widget.controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: widget.size,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final Size size = MediaQuery.of(context).size;

          return Stack(
            children: <Widget>[
              _backCard(constraints),
              _middleCard(constraints),
              _frontCard(constraints),
              if (_cardChangeController.status != AnimationStatus.forward)
                SizedBox.expand(
                  child: GestureDetector(
                    onPanDown: (DragDownDetails details) {
                      _stop();
                    },
                    onPanUpdate: (DragUpdateDetails details) {
                      _updateFrontCardAlignment(details, size);
                      if (_frontCardAlignment.x < 0) {
                        setState(() {
                          left = -xOffset +
                              xOffset *
                                  math.min(
                                    1.0,
                                    _frontCardAlignment.x.abs() / limit,
                                  );
                          right = -xOffset;
                        });
                      } else if (_frontCardAlignment.x > 0) {
                        setState(() {
                          right = -xOffset +
                              xOffset *
                                  math.min(
                                    1.0,
                                    _frontCardAlignment.x.abs() / limit,
                                  );
                          left = -xOffset;
                        });
                      }
                    },
                    onPanEnd: (DragEndDetails details) {
                      _judgeRunAnimation(details, size);
                    },
                  ),
                ),
              Positioned(
                left: left,
                top: 0,
                bottom: 0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: SvgPicture.asset(Assets.icons.dislikeUser,
                        color: Colors.black54),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(15),
                          topRight: Radius.circular(15)),
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.9],
                        colors: [
                          context.colorScheme.secondaryVariant,
                          context.colorScheme.secondary,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: right,
                top: 0,
                bottom: 0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                      padding: EdgeInsets.all(10),
                      child: SvgPicture.asset(Assets.icons.likeUser,
                          color: Colors.white.withOpacity(0.3)),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.topLeft,
                            stops: [0.1, 0.9],
                            colors: [
                              context.colorScheme.primaryVariant,
                              context.colorScheme.primary,
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              topLeft: Radius.circular(15))),
                      width: 100,
                      height: 100),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class CardSizes {
  static Size front(BoxConstraints constraints) {
    return Size(constraints.maxWidth * 0.9, constraints.maxHeight * 0.9);
  }

  static Size middle(BoxConstraints constraints) {
    return Size(constraints.maxWidth * 0.85, constraints.maxHeight * 0.9);
  }

  static Size back(BoxConstraints constraints) {
    return Size(constraints.maxWidth * 0.8, constraints.maxHeight * 0.9);
  }
}

class CardAlignments {
  static Alignment front = Alignment(0.0, 0.5);
  static Alignment middle = Alignment(0, 0.0);
  static Alignment back = Alignment(0.0, -0.5);
}

class CardAnimations {
  static Animation<Alignment> frontCardDisappearAnimation(
    AnimationController parent,
    Alignment beginAlignment,
    SwipInfo info,
  ) {
    return AlignmentTween(
      begin: beginAlignment,
      end: Alignment(
        info.direction == SwipDirection.Left
            ? beginAlignment.x - 30.0
            : beginAlignment.x + 30.0,
        0.0,
      ),
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
  }

  static Animation<Alignment> middleCardAlignmentAnimation(
    AnimationController parent,
  ) {
    return AlignmentTween(
      begin: CardAlignments.middle,
      end: CardAlignments.front,
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.2, 0.5, curve: Curves.easeIn),
      ),
    );
  }

  static Animation<Size> middleCardSizeAnimation(
    AnimationController parent,
    BoxConstraints constraints,
  ) {
    return SizeTween(
      begin: CardSizes.middle(constraints),
      end: CardSizes.front(constraints),
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.2, 0.5, curve: Curves.easeIn),
      ),
    );
  }

  static Animation<double> middleCardScaleAnimation(
    AnimationController parent,
    BoxConstraints constraints,
  ) {
    return Tween<double>(
      begin: CardSizes.middle(constraints).width / constraints.maxWidth,
      end: CardSizes.front(constraints).width / constraints.maxWidth,
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.2, 0.5, curve: Curves.easeIn),
      ),
    );
  }

  static Animation<Alignment> backCardAlignmentAnimation(
    AnimationController parent,
  ) {
    return AlignmentTween(
      begin: CardAlignments.back,
      end: CardAlignments.middle,
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );
  }

  static Animation<Size> backCardSizeAnimation(
    AnimationController parent,
    BoxConstraints constraints,
  ) {
    return SizeTween(
      begin: CardSizes.back(constraints),
      end: CardSizes.middle(constraints),
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );
  }
}

class CardReverseAnimations {
  static Animation<Alignment> frontCardShowAnimation(
    AnimationController parent,
    Alignment endAlignment,
    SwipInfo info,
  ) {
    return AlignmentTween(
      begin: Alignment(
        info.direction == SwipDirection.Left
            ? endAlignment.x - 30.0
            : endAlignment.x + 30.0,
        0.0,
      ),
      end: endAlignment,
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
  }

  static Animation<Alignment> middleCardAlignmentAnimation(
    AnimationController parent,
  ) {
    return AlignmentTween(
      begin: CardAlignments.front,
      end: CardAlignments.middle,
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.2, 0.5, curve: Curves.easeIn),
      ),
    );
  }

  static Animation<Size> middleCardSizeAnimation(
    AnimationController parent,
    BoxConstraints constraints,
  ) {
    return SizeTween(
      begin: CardSizes.front(constraints),
      end: CardSizes.middle(constraints),
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.2, 0.5, curve: Curves.easeIn),
      ),
    );
  }

  static Animation<double> middleCardScaleAnimation(
    AnimationController parent,
    BoxConstraints constraints,
  ) {
    return Tween(
      begin: 1,
      end: 0.8,
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.2, 0.5, curve: Curves.easeIn),
      ),
    );
  }

  static Animation<Alignment> backCardAlignmentAnimation(
    AnimationController parent,
  ) {
    return AlignmentTween(
      begin: CardAlignments.middle,
      end: CardAlignments.back,
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );
  }

  static Animation<Size> backCardSizeAnimation(
    AnimationController parent,
    BoxConstraints constraints,
  ) {
    return SizeTween(
      begin: CardSizes.middle(constraints),
      end: CardSizes.back(constraints),
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );
  }
}
