import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/cubit/cubit_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class RoomAnalysisScreen extends StatefulWidget {
  final String roomID;
  const RoomAnalysisScreen({super.key, required this.roomID});

  @override
  State<RoomAnalysisScreen> createState() => _RoomAnalysisScreenState();
}

class _RoomAnalysisScreenState extends State<RoomAnalysisScreen> {
  final List<String> graphTitle = ["Expense By Category", "Expense By User"];
  final ValueNotifier _selectedGraphIndex = ValueNotifier(0);

  Widget expenseByCategoryGraph(List<CategoryAmountModel> data) {
    return ExpenseByCategoryChart(data: data);
  }

  Widget expenseByUserGraph() {
    final state = context.read<RoomUserCubit>().state;
    List<RoomUserModel> data = [];
    if (state is RoomUserSuccess) {
      data = state.data;
    }

    return ExpenseByUserChart(data: data);
  }

  Widget _graphController(int index, List<CategoryAmountModel> data) {
    switch (index) {
      case 0:
        return expenseByCategoryGraph(data);
      case 1:
        return expenseByUserGraph();
      default:
        return SizedBox.shrink();
    }
  }

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      final oldState = context.read<RoomCategoryWiseTotalAmountCubit>().state;
      if (!(oldState is RoomCategoryWiseTotalAmountSuccess &&
          oldState.id == widget.roomID)) {
        context.read<RoomCategoryWiseTotalAmountCubit>().fetchData(
          widget.roomID,
        );
      }
    }
  }

  void _blocListenerHandler(
    BuildContext context,
    RoomCategoryWiseTotalAmountState state,
  ) {
    if (state is RoomCategoryWiseTotalAmountFailure) {
      showNormalSnackBar(context, state.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      RoomCategoryWiseTotalAmountCubit,
      RoomCategoryWiseTotalAmountState
    >(
      listener: _blocListenerHandler,
      builder: (context, state) {
        if (state is RoomCategoryWiseTotalAmountLoading) {
          return SliverFillRemaining(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(strokeWidth: 2.5),
                Padding(
                  padding: EdgeInsets.only(top: UiConstant.spaceBetweenCard),
                  child: Text(
                    "Loading...",
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                ),
              ],
            ),
          );
        }

        List<CategoryAmountModel> data = [];
        if (state is RoomCategoryWiseTotalAmountSuccess) {
          data = state.dataList;
        }

        if (data.isEmpty) {
          return SliverFillRemaining(
            child: freshMessageWidget(
              FreshScreenMessageConstant.noChartDataForRoom,
            ),
          );
        }
        return ValueListenableBuilder(
          valueListenable: _selectedGraphIndex,
          builder: (context, _, _) {
            return SliverList(
              delegate: SliverChildListDelegate([
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: UiConstant.spaceBetweenCard,
                    children: List.generate(
                      graphTitle.length,
                      (index) => InkWell(
                        borderRadius: BorderRadius.circular(60),
                        onTap: () => _selectedGraphIndex.value = index,
                        child: Chip(
                          label: Text(
                            graphTitle[index],
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color,
                            ),
                          ),
                          side: BorderSide(
                            color:
                                index == _selectedGraphIndex.value
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context)
                                        .textSelectionTheme
                                        .cursorColor!
                                        .withAlpha(50),
                          ),
                          labelStyle:
                              index == _selectedGraphIndex.value
                                  ? TextStyle()
                                  : null,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: UiConstant.spaceBetweenSection),
                _graphController(_selectedGraphIndex.value, data),
              ]),
            );
          },
        );
      },
    );
  }
}
