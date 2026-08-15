import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/constant/constant_core.dart';

import 'package:settlenow/cubit/cubit_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class RoomTransactionScreen extends StatefulWidget {
  final String roomID;
  final TextEditingController searchController;

  const RoomTransactionScreen({
    super.key,
    required this.roomID,
    required this.searchController,
  });

  @override
  State<RoomTransactionScreen> createState() => _RoomTransactionScreenState();
}

class _RoomTransactionScreenState extends State<RoomTransactionScreen> {
  UserModel _loggedInUser = UserModel.empty();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;

      final oldState = context.read<RoomBloc>().state;
      if (!(oldState is RoomFetchSuccess && oldState.id == widget.roomID)) {
        context.read<RoomBloc>().add(
          RoomFetch(id: widget.roomID, isFreshFetch: false),
        );
      }
    }
  }

  Widget transactionCardDisplay(List<RoomTransactionModel> data) {
    bool isWide = MediaQuery.of(context).size.width > UiConstant.maxWidth;
    int noOfCardsToBeShown = (data.length / 2).toInt() + data.length % 2;

    return SliverList.builder(
      itemCount: isWide ? noOfCardsToBeShown : data.length,
      itemBuilder: (BuildContext context, int index) {
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RoomTransactionCard(
                  roomID: widget.roomID,
                  data: data[2 * index],
                  loggedInUser: _loggedInUser,
                ),
              ),
              Expanded(
                child:
                    (index == noOfCardsToBeShown - 1 && data.length % 2 > 0)
                        ? SizedBox()
                        : RoomTransactionCard(
                          roomID: widget.roomID,
                          data: data[2 * index + 1],
                          loggedInUser: _loggedInUser,
                        ),
              ),
            ],
          );
        } else {
          return RoomTransactionCard(
            roomID: widget.roomID,
            data: data[index],
            loggedInUser: _loggedInUser,
          );
        }
      },
    );
  }

  String getName(String createdBy) {
    return UserResolver.instance.resolve(createdBy).name;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoomBloc, RoomState>(
      builder: (context, state) {
        List<RoomTransactionModel> data = [];
        if (state is RoomFetchSuccess) {
          data = state.dataList;

          final filterState = context.read<FilterCubit>().state;
          if (!filterState.isFilterApplied) {
            context.read<FilterCubit>().updateState(
              FilterState(id: state.id, data: data),
              _loggedInUser.id,
              TransactionType.room,
            );
          }

          if (data.isEmpty) {
            return SliverFillRemaining(
              child: noRecordFoundWidget("No Transaction Found", context),
            );
          }

          return BlocBuilder<FilterCubit, FilterState>(
            builder: (context, filterState) {
              return ValueListenableBuilder<TextEditingValue>(
                valueListenable: widget.searchController,
                builder: (context, _, _) {
                  List<RoomTransactionModel> searchedData =
                      filterState.data.cast<RoomTransactionModel>();

                  searchedData = FilterSort.filteredSearchText(
                    widget.searchController.text,
                    searchedData,
                    (transData) =>
                        "${transData.description} ${transData.amount} ${transData.category} ${getName(transData.createdBy)}",
                  );

                  if (searchedData.isEmpty) {
                    return SliverFillRemaining(
                      child: noRecordFoundWidget(
                        ApiConstant.noMatchingRecords,
                        context,
                      ),
                    );
                  }
                  return transactionCardDisplay(searchedData);
                },
              );
            },
          );
        } else {
          return transactionCardDisplay(
            List.filled(11, RoomTransactionModel.empty()),
          );
        }
      },
      listener: (BuildContext context, RoomState state) {
        if (state is RoomFailure) {
          showNormalSnackBar(context, state.error);
        }
      },
    );
  }
}
