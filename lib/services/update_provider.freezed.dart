// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpdateState {

 bool get isUpdateDialogVisible; bool get isOptionalUpdateDismissed;
/// Create a copy of UpdateState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateStateCopyWith<UpdateState> get copyWith => _$UpdateStateCopyWithImpl<UpdateState>(this as UpdateState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateState&&(identical(other.isUpdateDialogVisible, isUpdateDialogVisible) || other.isUpdateDialogVisible == isUpdateDialogVisible)&&(identical(other.isOptionalUpdateDismissed, isOptionalUpdateDismissed) || other.isOptionalUpdateDismissed == isOptionalUpdateDismissed));
}


@override
int get hashCode => Object.hash(runtimeType,isUpdateDialogVisible,isOptionalUpdateDismissed);

@override
String toString() {
  return 'UpdateState(isUpdateDialogVisible: $isUpdateDialogVisible, isOptionalUpdateDismissed: $isOptionalUpdateDismissed)';
}


}

/// @nodoc
abstract mixin class $UpdateStateCopyWith<$Res>  {
  factory $UpdateStateCopyWith(UpdateState value, $Res Function(UpdateState) _then) = _$UpdateStateCopyWithImpl;
@useResult
$Res call({
 bool isUpdateDialogVisible, bool isOptionalUpdateDismissed
});




}
/// @nodoc
class _$UpdateStateCopyWithImpl<$Res>
    implements $UpdateStateCopyWith<$Res> {
  _$UpdateStateCopyWithImpl(this._self, this._then);

  final UpdateState _self;
  final $Res Function(UpdateState) _then;

/// Create a copy of UpdateState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isUpdateDialogVisible = null,Object? isOptionalUpdateDismissed = null,}) {
  return _then(_self.copyWith(
isUpdateDialogVisible: null == isUpdateDialogVisible ? _self.isUpdateDialogVisible : isUpdateDialogVisible // ignore: cast_nullable_to_non_nullable
as bool,isOptionalUpdateDismissed: null == isOptionalUpdateDismissed ? _self.isOptionalUpdateDismissed : isOptionalUpdateDismissed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateState].
extension UpdateStatePatterns on UpdateState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateState value)  $default,){
final _that = this;
switch (_that) {
case _UpdateState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateState value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isUpdateDialogVisible,  bool isOptionalUpdateDismissed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateState() when $default != null:
return $default(_that.isUpdateDialogVisible,_that.isOptionalUpdateDismissed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isUpdateDialogVisible,  bool isOptionalUpdateDismissed)  $default,) {final _that = this;
switch (_that) {
case _UpdateState():
return $default(_that.isUpdateDialogVisible,_that.isOptionalUpdateDismissed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isUpdateDialogVisible,  bool isOptionalUpdateDismissed)?  $default,) {final _that = this;
switch (_that) {
case _UpdateState() when $default != null:
return $default(_that.isUpdateDialogVisible,_that.isOptionalUpdateDismissed);case _:
  return null;

}
}

}

/// @nodoc


class _UpdateState implements UpdateState {
  const _UpdateState({this.isUpdateDialogVisible = false, this.isOptionalUpdateDismissed = false});
  

@override@JsonKey() final  bool isUpdateDialogVisible;
@override@JsonKey() final  bool isOptionalUpdateDismissed;

/// Create a copy of UpdateState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateStateCopyWith<_UpdateState> get copyWith => __$UpdateStateCopyWithImpl<_UpdateState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateState&&(identical(other.isUpdateDialogVisible, isUpdateDialogVisible) || other.isUpdateDialogVisible == isUpdateDialogVisible)&&(identical(other.isOptionalUpdateDismissed, isOptionalUpdateDismissed) || other.isOptionalUpdateDismissed == isOptionalUpdateDismissed));
}


@override
int get hashCode => Object.hash(runtimeType,isUpdateDialogVisible,isOptionalUpdateDismissed);

@override
String toString() {
  return 'UpdateState(isUpdateDialogVisible: $isUpdateDialogVisible, isOptionalUpdateDismissed: $isOptionalUpdateDismissed)';
}


}

/// @nodoc
abstract mixin class _$UpdateStateCopyWith<$Res> implements $UpdateStateCopyWith<$Res> {
  factory _$UpdateStateCopyWith(_UpdateState value, $Res Function(_UpdateState) _then) = __$UpdateStateCopyWithImpl;
@override @useResult
$Res call({
 bool isUpdateDialogVisible, bool isOptionalUpdateDismissed
});




}
/// @nodoc
class __$UpdateStateCopyWithImpl<$Res>
    implements _$UpdateStateCopyWith<$Res> {
  __$UpdateStateCopyWithImpl(this._self, this._then);

  final _UpdateState _self;
  final $Res Function(_UpdateState) _then;

/// Create a copy of UpdateState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isUpdateDialogVisible = null,Object? isOptionalUpdateDismissed = null,}) {
  return _then(_UpdateState(
isUpdateDialogVisible: null == isUpdateDialogVisible ? _self.isUpdateDialogVisible : isUpdateDialogVisible // ignore: cast_nullable_to_non_nullable
as bool,isOptionalUpdateDismissed: null == isOptionalUpdateDismissed ? _self.isOptionalUpdateDismissed : isOptionalUpdateDismissed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
