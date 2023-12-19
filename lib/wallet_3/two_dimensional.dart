import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const double itemHeight = 50.0;
const double itemWidth = 150.0;

class MyAppTwoDimentional extends StatelessWidget {
  const MyAppTwoDimentional({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        // Mouse dragging enabled for this demo
        dragDevices: PointerDeviceKind.values.toSet(),
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: TwoDimensionalGridView(
        diagonalDragBehavior: DiagonalDragBehavior.free,
        delegate: TwoDimensionalChildBuilderDelegate(
          maxXIndex: 365,
          maxYIndex: 100,
          builder: (BuildContext context, ChildVicinity vicinity) {
            return Container(
              color: vicinity.xIndex.isEven && vicinity.yIndex.isEven
                  ? Colors.amber
                  : (vicinity.xIndex.isOdd && vicinity.yIndex.isOdd
                      ? Colors.purple
                      : null),
              height: itemHeight,
              width: itemWidth,
              child: Center(
                child:
                    Text('Row ${vicinity.yIndex}: Column ${vicinity.xIndex}'),
              ),
            );
          },
        ),
      ),
    );
  }
}

class TwoDimensionalGridView extends TwoDimensionalScrollView {
  const TwoDimensionalGridView({
    super.key,
    super.primary,
    super.mainAxis = Axis.vertical,
    super.verticalDetails = const ScrollableDetails.vertical(),
    super.horizontalDetails = const ScrollableDetails.horizontal(),
    required TwoDimensionalChildBuilderDelegate delegate,
    super.cacheExtent,
    super.diagonalDragBehavior = DiagonalDragBehavior.none,
    super.dragStartBehavior = DragStartBehavior.start,
    super.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    super.clipBehavior = Clip.hardEdge,
  }) : super(delegate: delegate);

  @override
  Widget buildViewport(
    BuildContext context,
    ViewportOffset verticalOffset,
    ViewportOffset horizontalOffset,
  ) {
    return TwoDimensionalGridViewport(
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalDetails.direction,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalDetails.direction,
      mainAxis: mainAxis,
      delegate: delegate as TwoDimensionalChildBuilderDelegate,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
    );
  }
}

class TwoDimensionalGridViewport extends TwoDimensionalViewport {
  const TwoDimensionalGridViewport({
    Key? key,
    required verticalOffset,
    required verticalAxisDirection,
    required horizontalOffset,
    required horizontalAxisDirection,
    required TwoDimensionalChildBuilderDelegate delegate,
    required mainAxis,
    cacheExtent,
    Clip clipBehavior = Clip.hardEdge,
  }) : super(
          key: key,
          verticalOffset: verticalOffset,
          verticalAxisDirection: verticalAxisDirection,
          horizontalOffset: horizontalOffset,
          horizontalAxisDirection: horizontalAxisDirection,
          delegate: delegate,
          mainAxis: mainAxis,
          cacheExtent: cacheExtent,
          clipBehavior: clipBehavior,
        );

  @override
  RenderTwoDimensionalViewport createRenderObject(BuildContext context) {
    return RenderTwoDimensionalGridViewport(
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalAxisDirection,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalAxisDirection,
      mainAxis: mainAxis,
      delegate: delegate as TwoDimensionalChildBuilderDelegate,
      childManager: context as TwoDimensionalChildManager,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTwoDimensionalGridViewport renderObject,
  ) {
    renderObject
      ..horizontalOffset = horizontalOffset
      ..horizontalAxisDirection = horizontalAxisDirection
      ..verticalOffset = verticalOffset
      ..verticalAxisDirection = verticalAxisDirection
      ..mainAxis = mainAxis
      ..delegate = delegate
      ..cacheExtent = cacheExtent
      ..clipBehavior = clipBehavior;
  }
}

class RenderTwoDimensionalGridViewport extends RenderTwoDimensionalViewport {
  RenderTwoDimensionalGridViewport({
    required horizontalOffset,
    required horizontalAxisDirection,
    required verticalOffset,
    required verticalAxisDirection,
    required TwoDimensionalChildBuilderDelegate delegate,
    required mainAxis,
    required childManager,
    cacheExtent,
    Clip clipBehavior = Clip.hardEdge,
  }) : super(
          horizontalOffset: horizontalOffset,
          horizontalAxisDirection: horizontalAxisDirection,
          verticalOffset: verticalOffset,
          verticalAxisDirection: verticalAxisDirection,
          delegate: delegate,
          mainAxis: mainAxis,
          childManager: childManager,
          cacheExtent: cacheExtent,
          clipBehavior: clipBehavior,
        );

  @override
  void layoutChildSequence() {
    final double horizontalPixels = horizontalOffset.pixels;
    final double verticalPixels = verticalOffset.pixels;
    final double viewportWidth = viewportDimension.width + cacheExtent;
    final double viewportHeight = viewportDimension.height + cacheExtent;
    final TwoDimensionalChildBuilderDelegate builderDelegate =
        delegate as TwoDimensionalChildBuilderDelegate;

    final int maxRowIndex = builderDelegate.maxYIndex!;
    final int maxColumnIndex = builderDelegate.maxXIndex!;

    final int leadingColumn = (horizontalPixels / itemWidth).floor();
    final int leadingRow = (verticalPixels / itemHeight).floor();
    final int trailingColumn =
        ((horizontalPixels + viewportWidth) / itemWidth).ceil();
    final int trailingRow =
        ((verticalPixels + viewportHeight) / itemHeight).ceil();

    double xLayoutOffset =
        (leadingColumn * itemWidth) - horizontalOffset.pixels;
    for (int column = leadingColumn; column <= trailingColumn; column++) {
      double yLayoutOffset = (leadingRow * itemHeight) - verticalOffset.pixels;
      for (int row = leadingRow; row <= trailingRow; row++) {
        final ChildVicinity vicinity =
            ChildVicinity(xIndex: column, yIndex: row);
        final RenderBox child = buildOrObtainChildFor(vicinity)!;
        child.layout(constraints.loosen());

        // Subclasses only need to set the normalized layout offset. The super
        // class adjusts for reversed axes.
        parentDataOf(child).layoutOffset = Offset(xLayoutOffset, yLayoutOffset);
        yLayoutOffset += itemHeight;
      }
      xLayoutOffset += itemWidth;
    }

    // Set the min and max scroll extents for each axis.
    final double verticalExtent = itemHeight * (maxRowIndex + 1);
    verticalOffset.applyContentDimensions(
      0.0,
      clampDouble(
        verticalExtent - viewportDimension.height,
        0.0,
        double.infinity,
      ),
    );
    final double horizontalExtent = itemWidth * (maxColumnIndex + 1);
    horizontalOffset.applyContentDimensions(
      0.0,
      clampDouble(
        horizontalExtent - viewportDimension.width,
        0.0,
        double.infinity,
      ),
    );
    // Super class handles garbage collection too!
  }
}
