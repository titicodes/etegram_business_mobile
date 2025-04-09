import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../locator.dart';
import '../utils/widget_extension.dart';
import 'base_vm.dart';

class BaseView<T extends BaseViewModel> extends StatefulWidget {
  final bool notDefaultLoading;
  final Widget Function(
      BuildContext context, T model, Widget? child)? builder;
  final Function(T)? onModelReady;
  final Function(T)? onDisposeModel;

  const BaseView(
      {Key? key, this.builder, this.onModelReady, this.onDisposeModel, this.notDefaultLoading=false})
      : super(key: key);

  @override
  _BaseViewState<T> createState() => _BaseViewState<T>();
}

class _BaseViewState<T extends BaseViewModel> extends State<BaseView<T>> {
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
          builder: (_, model, __) => Scaffold(
            body: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                          onTap: ()=> FocusManager.instance.primaryFocus?.unfocus(),
                          child: widget.builder!.call(_, model, __)
                      ),
                    ),
                  ],
                ),
                widget.notDefaultLoading? 0.0.sbH : model.isLoading?
                Container(
                    height: height(context),
                    width: width(context),
                    alignment: Alignment.center,
                    color: Colors.white10,
                    child: const SmallLoader()
                )
                    :
                const SizedBox(),
              ],
              //widget.builder!,
            ),
          ),
        )
    );
  }
}



class ForceBaseView<T extends BaseViewModel> extends StatefulWidget {
  final bool notDefaultLoading;
  final Widget Function(
      BuildContext context, T model, Widget? child)? builder;
  final Function(T)? onModelReady;
  final Function(T)? onDisposeModel;

  const ForceBaseView(
      {Key? key, this.builder, this.onModelReady, this.onDisposeModel, this.notDefaultLoading=false})
      : super(key: key);

  @override
  _ForceBaseViewState<T> createState() => _ForceBaseViewState<T>();
}

class _ForceBaseViewState<T extends BaseViewModel> extends State<ForceBaseView<T>> {
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
          builder: (_, model, __) => Scaffold(
            body: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                          onTap: ()=> FocusManager.instance.primaryFocus?.unfocus(),
                          child: widget.builder!.call(_, model, __)
                      ),
                    ),
                  ],
                ),
                widget.notDefaultLoading? 0.0.sbH : model.isLoading?
                Container(
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
                        )),
                  ),
                )
                    : 0.sp.sbH
              ],
              //widget.builder!,
            ),
          ),
        )
    );
  }
}



class SmallLoader extends StatelessWidget {
  const SmallLoader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
        alignment: Alignment.center,
        children: [
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
  final Widget Function(
      BuildContext context, T model, Widget? child)? builder;
  final Function(T)? onModelReady;
  final Function(T)? onDisposeModel;

  const OtherView(
      {Key? key, this.builder, this.onModelReady, this.onDisposeModel, this.notDefaultLoading=false})
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
        builder: (_, model,  __) =>
            widget.builder!.call(_, model, __),
      ),
    );
  }
}

class PopView<T extends BaseViewModel> extends StatefulWidget {
  final bool notDefaultLoading;
  final Widget Function(
      BuildContext context, T model, Widget? child)? builder;
  final Function(T)? onModelReady;
  final Function(T)? onDisposeModel;

  const PopView(
      {Key? key, this.builder, this.onModelReady, this.onDisposeModel, this.notDefaultLoading=false})
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
        builder: (_, model,  __) =>
            Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    Expanded(child: widget.builder!.call(_, model, __)),
                  ],
                ),
                model.isLoading?
                Column(
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
                    :
                0.0.sbH,
              ],
            ),
      ),
    );
  }
}
