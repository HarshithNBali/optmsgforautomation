// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SubscriptionState {

 Map<String, dynamic> get data; bool get isLoading; bool get isFreeUser;
/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionStateCopyWith<SubscriptionState> get copyWith => _$SubscriptionStateCopyWithImpl<SubscriptionState>(this as SubscriptionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionState&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isFreeUser, isFreeUser) || other.isFreeUser == isFreeUser));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data),isLoading,isFreeUser);

@override
String toString() {
  return 'SubscriptionState(data: $data, isLoading: $isLoading, isFreeUser: $isFreeUser)';
}


}

/// @nodoc
abstract mixin class $SubscriptionStateCopyWith<$Res>  {
  factory $SubscriptionStateCopyWith(SubscriptionState value, $Res Function(SubscriptionState) _then) = _$SubscriptionStateCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic> data, bool isLoading, bool isFreeUser
});




}
/// @nodoc
class _$SubscriptionStateCopyWithImpl<$Res>
    implements $SubscriptionStateCopyWith<$Res> {
  _$SubscriptionStateCopyWithImpl(this._self, this._then);

  final SubscriptionState _self;
  final $Res Function(SubscriptionState) _then;

/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? isLoading = null,Object? isFreeUser = null,}) {
  return _then(_self.copyWith(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isFreeUser: null == isFreeUser ? _self.isFreeUser : isFreeUser // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionState].
extension SubscriptionStatePatterns on SubscriptionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionState value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionState value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, dynamic> data,  bool isLoading,  bool isFreeUser)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionState() when $default != null:
return $default(_that.data,_that.isLoading,_that.isFreeUser);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, dynamic> data,  bool isLoading,  bool isFreeUser)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionState():
return $default(_that.data,_that.isLoading,_that.isFreeUser);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, dynamic> data,  bool isLoading,  bool isFreeUser)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionState() when $default != null:
return $default(_that.data,_that.isLoading,_that.isFreeUser);case _:
  return null;

}
}

}

/// @nodoc


class _SubscriptionState implements SubscriptionState {
  const _SubscriptionState({final  Map<String, dynamic> data = const {}, this.isLoading = false, this.isFreeUser = false}): _data = data;
  

 final  Map<String, dynamic> _data;
@override@JsonKey() Map<String, dynamic> get data {
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_data);
}

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isFreeUser;

/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionStateCopyWith<_SubscriptionState> get copyWith => __$SubscriptionStateCopyWithImpl<_SubscriptionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionState&&const DeepCollectionEquality().equals(other._data, _data)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isFreeUser, isFreeUser) || other.isFreeUser == isFreeUser));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_data),isLoading,isFreeUser);

@override
String toString() {
  return 'SubscriptionState(data: $data, isLoading: $isLoading, isFreeUser: $isFreeUser)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionStateCopyWith<$Res> implements $SubscriptionStateCopyWith<$Res> {
  factory _$SubscriptionStateCopyWith(_SubscriptionState value, $Res Function(_SubscriptionState) _then) = __$SubscriptionStateCopyWithImpl;
@override @useResult
$Res call({
 Map<String, dynamic> data, bool isLoading, bool isFreeUser
});




}
/// @nodoc
class __$SubscriptionStateCopyWithImpl<$Res>
    implements _$SubscriptionStateCopyWith<$Res> {
  __$SubscriptionStateCopyWithImpl(this._self, this._then);

  final _SubscriptionState _self;
  final $Res Function(_SubscriptionState) _then;

/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? isLoading = null,Object? isFreeUser = null,}) {
  return _then(_SubscriptionState(
data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isFreeUser: null == isFreeUser ? _self.isFreeUser : isFreeUser // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
