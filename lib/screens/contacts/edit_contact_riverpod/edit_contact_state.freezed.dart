// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'edit_contact_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EditContactState {

 bool get isLoading; int get emailFieldCount;
/// Create a copy of EditContactState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditContactStateCopyWith<EditContactState> get copyWith => _$EditContactStateCopyWithImpl<EditContactState>(this as EditContactState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditContactState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.emailFieldCount, emailFieldCount) || other.emailFieldCount == emailFieldCount));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,emailFieldCount);

@override
String toString() {
  return 'EditContactState(isLoading: $isLoading, emailFieldCount: $emailFieldCount)';
}


}

/// @nodoc
abstract mixin class $EditContactStateCopyWith<$Res>  {
  factory $EditContactStateCopyWith(EditContactState value, $Res Function(EditContactState) _then) = _$EditContactStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, int emailFieldCount
});




}
/// @nodoc
class _$EditContactStateCopyWithImpl<$Res>
    implements $EditContactStateCopyWith<$Res> {
  _$EditContactStateCopyWithImpl(this._self, this._then);

  final EditContactState _self;
  final $Res Function(EditContactState) _then;

/// Create a copy of EditContactState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? emailFieldCount = null,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,emailFieldCount: null == emailFieldCount ? _self.emailFieldCount : emailFieldCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [EditContactState].
extension EditContactStatePatterns on EditContactState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EditContactState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EditContactState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EditContactState value)  $default,){
final _that = this;
switch (_that) {
case _EditContactState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EditContactState value)?  $default,){
final _that = this;
switch (_that) {
case _EditContactState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  int emailFieldCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EditContactState() when $default != null:
return $default(_that.isLoading,_that.emailFieldCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  int emailFieldCount)  $default,) {final _that = this;
switch (_that) {
case _EditContactState():
return $default(_that.isLoading,_that.emailFieldCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  int emailFieldCount)?  $default,) {final _that = this;
switch (_that) {
case _EditContactState() when $default != null:
return $default(_that.isLoading,_that.emailFieldCount);case _:
  return null;

}
}

}

/// @nodoc


class _EditContactState implements EditContactState {
  const _EditContactState({this.isLoading = false, this.emailFieldCount = 0});
  

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  int emailFieldCount;

/// Create a copy of EditContactState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EditContactStateCopyWith<_EditContactState> get copyWith => __$EditContactStateCopyWithImpl<_EditContactState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EditContactState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.emailFieldCount, emailFieldCount) || other.emailFieldCount == emailFieldCount));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,emailFieldCount);

@override
String toString() {
  return 'EditContactState(isLoading: $isLoading, emailFieldCount: $emailFieldCount)';
}


}

/// @nodoc
abstract mixin class _$EditContactStateCopyWith<$Res> implements $EditContactStateCopyWith<$Res> {
  factory _$EditContactStateCopyWith(_EditContactState value, $Res Function(_EditContactState) _then) = __$EditContactStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, int emailFieldCount
});




}
/// @nodoc
class __$EditContactStateCopyWithImpl<$Res>
    implements _$EditContactStateCopyWith<$Res> {
  __$EditContactStateCopyWithImpl(this._self, this._then);

  final _EditContactState _self;
  final $Res Function(_EditContactState) _then;

/// Create a copy of EditContactState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? emailFieldCount = null,}) {
  return _then(_EditContactState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,emailFieldCount: null == emailFieldCount ? _self.emailFieldCount : emailFieldCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
