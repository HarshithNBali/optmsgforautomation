// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_method_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaymentMethodState {

 bool get isLoading; bool get showNoData; List<Map<String, dynamic>> get cardData;
/// Create a copy of PaymentMethodState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentMethodStateCopyWith<PaymentMethodState> get copyWith => _$PaymentMethodStateCopyWithImpl<PaymentMethodState>(this as PaymentMethodState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentMethodState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.showNoData, showNoData) || other.showNoData == showNoData)&&const DeepCollectionEquality().equals(other.cardData, cardData));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,showNoData,const DeepCollectionEquality().hash(cardData));

@override
String toString() {
  return 'PaymentMethodState(isLoading: $isLoading, showNoData: $showNoData, cardData: $cardData)';
}


}

/// @nodoc
abstract mixin class $PaymentMethodStateCopyWith<$Res>  {
  factory $PaymentMethodStateCopyWith(PaymentMethodState value, $Res Function(PaymentMethodState) _then) = _$PaymentMethodStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, bool showNoData, List<Map<String, dynamic>> cardData
});




}
/// @nodoc
class _$PaymentMethodStateCopyWithImpl<$Res>
    implements $PaymentMethodStateCopyWith<$Res> {
  _$PaymentMethodStateCopyWithImpl(this._self, this._then);

  final PaymentMethodState _self;
  final $Res Function(PaymentMethodState) _then;

/// Create a copy of PaymentMethodState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? showNoData = null,Object? cardData = null,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,showNoData: null == showNoData ? _self.showNoData : showNoData // ignore: cast_nullable_to_non_nullable
as bool,cardData: null == cardData ? _self.cardData : cardData // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentMethodState].
extension PaymentMethodStatePatterns on PaymentMethodState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentMethodState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentMethodState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentMethodState value)  $default,){
final _that = this;
switch (_that) {
case _PaymentMethodState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentMethodState value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentMethodState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  bool showNoData,  List<Map<String, dynamic>> cardData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentMethodState() when $default != null:
return $default(_that.isLoading,_that.showNoData,_that.cardData);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  bool showNoData,  List<Map<String, dynamic>> cardData)  $default,) {final _that = this;
switch (_that) {
case _PaymentMethodState():
return $default(_that.isLoading,_that.showNoData,_that.cardData);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  bool showNoData,  List<Map<String, dynamic>> cardData)?  $default,) {final _that = this;
switch (_that) {
case _PaymentMethodState() when $default != null:
return $default(_that.isLoading,_that.showNoData,_that.cardData);case _:
  return null;

}
}

}

/// @nodoc


class _PaymentMethodState implements PaymentMethodState {
  const _PaymentMethodState({this.isLoading = false, this.showNoData = false, final  List<Map<String, dynamic>> cardData = const []}): _cardData = cardData;
  

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool showNoData;
 final  List<Map<String, dynamic>> _cardData;
@override@JsonKey() List<Map<String, dynamic>> get cardData {
  if (_cardData is EqualUnmodifiableListView) return _cardData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cardData);
}


/// Create a copy of PaymentMethodState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentMethodStateCopyWith<_PaymentMethodState> get copyWith => __$PaymentMethodStateCopyWithImpl<_PaymentMethodState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentMethodState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.showNoData, showNoData) || other.showNoData == showNoData)&&const DeepCollectionEquality().equals(other._cardData, _cardData));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,showNoData,const DeepCollectionEquality().hash(_cardData));

@override
String toString() {
  return 'PaymentMethodState(isLoading: $isLoading, showNoData: $showNoData, cardData: $cardData)';
}


}

/// @nodoc
abstract mixin class _$PaymentMethodStateCopyWith<$Res> implements $PaymentMethodStateCopyWith<$Res> {
  factory _$PaymentMethodStateCopyWith(_PaymentMethodState value, $Res Function(_PaymentMethodState) _then) = __$PaymentMethodStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, bool showNoData, List<Map<String, dynamic>> cardData
});




}
/// @nodoc
class __$PaymentMethodStateCopyWithImpl<$Res>
    implements _$PaymentMethodStateCopyWith<$Res> {
  __$PaymentMethodStateCopyWithImpl(this._self, this._then);

  final _PaymentMethodState _self;
  final $Res Function(_PaymentMethodState) _then;

/// Create a copy of PaymentMethodState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? showNoData = null,Object? cardData = null,}) {
  return _then(_PaymentMethodState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,showNoData: null == showNoData ? _self.showNoData : showNoData // ignore: cast_nullable_to_non_nullable
as bool,cardData: null == cardData ? _self._cardData : cardData // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}


}

// dart format on
