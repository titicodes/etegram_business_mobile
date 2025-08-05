import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../locator.dart';
import '../utils/widget_extension.dart';
import 'base_vm.dart';

// class BaseView<T extends BaseViewModel> extends StatefulWidget {
//   final Widget Function(BuildContext, T, Widget?)? builder;
//   final Function(T)? onModelReady;
//   final Function(T)? onDisposeModel;
//   final bool notDefaultLoading;
//
//   const BaseView({
//     super.key,
//     this.builder,
//     this.onModelReady,
//     this.onDisposeModel,
//     this.notDefaultLoading = false,
//   });
//
//   @override
//   State<BaseView<T>> createState() => _BaseViewState<T>();
// }
//
// class _BaseViewState<T extends BaseViewModel> extends State<BaseView<T>> {
//   T model = locator<T>();
//
//   @override
//   void initState() {
//     super.initState();
//     print('BaseView: Initializing for ${T.toString()}, model instance: ${model.hashCode}');
//     if (widget.onModelReady != null) {
//       widget.onModelReady!(model);
//     }
//   }
//
//   @override
//   void dispose() {
//     print('BaseView: Disposing for ${T.toString()}, model instance: ${model.hashCode}');
//     if (widget.onDisposeModel != null && !locator.isRegistered<T>(instance: model)) {
//       widget.onDisposeModel!(model);
//     }
//     // Do not dispose the model; let get_it handle singleton lifecycle
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider<T>.value(
//       value: model, // Use the singleton instance
//       child: Consumer<T>(
//         builder: (context, model, child) {
//           print('BaseView: Building for ${T.toString()}, model instance: ${model.hashCode}');
//           return Scaffold(
//             body: Stack(
//               children: [
//                 Column(
//                   children: [
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
//                         child: widget.builder!.call(context, model, child),
//                       ),
//                     ),
//                   ],
//                 ),
//                 widget.notDefaultLoading
//                     ? const SizedBox.shrink()
//                     : model.isLoading.value
//                     ? Container(
//                   height: height(context),
//                   width: width(context),
//                   alignment: Alignment.center,
//                   color: Colors.white10,
//                   child: const SmallLoader(),
//                 )
//                     : const SizedBox.shrink(),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

class BaseView<T extends BaseViewModel> extends StatefulWidget {
  final Widget Function(BuildContext, T, Widget?)? builder;
  final Function(T)? onModelReady;
  final Function(T)? onDisposeModel;
  final bool notDefaultLoading;

  const BaseView({
    super.key,
    this.builder,
    this.onModelReady,
    this.onDisposeModel,
    this.notDefaultLoading = false,
  });

  @override
  State<BaseView<T>> createState() => _BaseViewState<T>();
}

class _BaseViewState<T extends BaseViewModel> extends State<BaseView<T>> {
  T model = locator<T>();

  @override
  void initState() {
    super.initState();
    print(
        'BaseView: Initializing for ${T.toString()}, model instance: ${model.hashCode}');
    if (widget.onModelReady != null) {
      widget.onModelReady!(model);
    }
  }

  @override
  void didUpdateWidget(BaseView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!locator.isRegistered<T>(instance: model)) {
      print('BaseView: Reinitializing model for ${T.toString()}');
      model = locator<T>();
      if (widget.onModelReady != null) {
        widget.onModelReady!(model);
      }
    }
  }

  @override
  void dispose() {
    print(
        'BaseView: Disposing for ${T.toString()}, model instance: ${model.hashCode}');
    if (widget.onDisposeModel != null &&
        !locator.isRegistered<T>(instance: model)) {
      widget.onDisposeModel!(model);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>.value(
      value: model,
      child: Consumer<T>(
        builder: (context, model, child) {
          print(
              'BaseView: Building for ${T.toString()}, model instance: ${model.hashCode}');
          return Stack(
            children: [
              widget.builder!(context, model, child),
              if (!widget.notDefaultLoading && model.isLoading.value)
                Container(
                  height: height(context),
                  width: width(context),
                  alignment: Alignment.center,
                  color: Colors.white10,
                  child: const SmallLoader(),
                ),
            ],
          );
        },
      ),
    );
  }
}

class ForceBaseView<T extends BaseViewModel> extends StatefulWidget {
  final bool notDefaultLoading;
  final Widget Function(BuildContext context, T model, Widget? child)? builder;
  final Function(T)? onModelReady;
  final Function(T)? onDisposeModel;

  const ForceBaseView(
      {Key? key,
      this.builder,
      this.onModelReady,
      this.onDisposeModel,
      this.notDefaultLoading = false})
      : super(key: key);

  @override
  _ForceBaseViewState<T> createState() => _ForceBaseViewState<T>();
}

class _ForceBaseViewState<T extends BaseViewModel>
    extends State<ForceBaseView<T>> {
  T model = locator<T>();

  @override
  void initState() {
    super.initState();
    if (widget.onModelReady != null) {
      widget.onModelReady!(model);
    }
  }

  @override
  void dispose() {
    if (widget.onDisposeModel != null &&
        !locator.isRegistered<T>(instance: model)) {
      widget.onDisposeModel!(model);
    }
    if (!locator.isRegistered<T>(instance: model)) {
      model.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>(
      create: (_) => model,
      child: Consumer<T>(
        builder: (_, model, __) => Scaffold(
          body: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      child: widget.builder!.call(_, model, __),
                    ),
                  ),
                ],
              ),
              widget.notDefaultLoading
                  ? 0.0.sbH
                  : model.isLoading.value
                      ? Container(
                          height: height(context),
                          width: width(context),
                          alignment: Alignment.center,
                          color: Colors.white10,
                          child: Container(
                            height: 70,
                            width: 70,
                            color: Colors.black12.withOpacity(.15),
                            child: const Center(
                              child: SpinKitRing(
                                color: Colors.white,
                                size: 45,
                              ),
                            ),
                          ),
                        )
                      : 0.sp.sbH,
            ],
          ),
        ),
      ),
    );
  }
}

class SmallLoader extends StatelessWidget {
  const SmallLoader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      const ModalBarrier(color: Colors.transparent),
      Container(
        height: 70,
        width: 70,
        color: Colors.black12.withOpacity(.15),
        child: const Center(
            child: SpinKitRing(
          color: Colors.white,
          size: 45,
        )),
      )
    ]);
  }
}

class OtherView<T extends BaseViewModel> extends StatefulWidget {
  final bool notDefaultLoading;
  final Widget Function(BuildContext context, T model, Widget? child)? builder;
  final Function(T)? onModelReady;
  final Function(T)? onDisposeModel;

  const OtherView(
      {Key? key,
      this.builder,
      this.onModelReady,
      this.onDisposeModel,
      this.notDefaultLoading = false})
      : super(key: key);

  @override
  _OtherViewState<T> createState() => _OtherViewState<T>();
}

class _OtherViewState<T extends BaseViewModel> extends State<OtherView<T>> {
  T model = locator<T>();

  @override
  void initState() {
    super.initState();
    if (widget.onModelReady != null) {
      widget.onModelReady!(model);
    }
  }

  @override
  void dispose() {
    if (widget.onDisposeModel != null) {
      widget.onDisposeModel!(model);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>(
      create: (_) => model,
      child: Consumer<T>(
        builder: (_, model, __) => widget.builder!.call(_, model, __),
      ),
    );
  }
}

class PopView<T extends BaseViewModel> extends StatefulWidget {
  final bool notDefaultLoading;
  final Widget Function(BuildContext context, T model, Widget? child)? builder;
  final Function(T)? onModelReady;
  final Function(T)? onDisposeModel;

  const PopView(
      {Key? key,
      this.builder,
      this.onModelReady,
      this.onDisposeModel,
      this.notDefaultLoading = false})
      : super(key: key);

  @override
  _PopViewState<T> createState() => _PopViewState<T>();
}

class _PopViewState<T extends BaseViewModel> extends State<PopView<T>> {
  T model = locator<T>();

  @override
  void initState() {
    super.initState();
    if (widget.onModelReady != null) {
      widget.onModelReady!(model);
    }
  }

  @override
  void dispose() {
    if (widget.onDisposeModel != null) {
      widget.onDisposeModel!(model);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>(
      create: (_) => model,
      child: Consumer<T>(
        builder: (_, model, __) => Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                Expanded(child: widget.builder!.call(_, model, __)),
              ],
            ),
            model.isLoading.value
                ? Column(
                    children: [
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          color: Colors.white10,
                          child: Container(
                            height: 70,
                            width: 70,
                            color: Colors.black12.withOpacity(.15),
                            child: const Center(
                                child: SpinKitRing(
                              color: Colors.white,
                              size: 45,
                            )),
                          ),
                        ),
                      ),
                    ],
                  )
                : 0.0.sbH,
          ],
        ),
      ),
    );
  }
}
