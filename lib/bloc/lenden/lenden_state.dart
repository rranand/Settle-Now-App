part of 'lenden_bloc.dart';

@immutable
sealed class LendenState {
  final bool hasData;

  const LendenState({this.hasData = false});
}

final class LendenInitial extends LendenState {
  const LendenInitial() : super(hasData: false);
}

final class LendenLoading extends LendenState {
  const LendenLoading() : super(hasData: false);
}

final class LendenFetchSuccess extends LendenState {
  final List<LendenModel> data;

  const LendenFetchSuccess(this.data) : super(hasData: true);
}

final class LendenFailure extends LendenState {
  final String error;

  const LendenFailure(this.error) : super(hasData: false);
}
