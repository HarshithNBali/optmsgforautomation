// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'add_contact_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AddContactState {

 bool get isLoading; int get emailFieldCount;
/// Create a copy of AddContactState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddContactStateCopyWith<AddContactState> get copyWith => _$AddContactStateCopyWithImpl<AddContactState>(this as AddContactState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddContactState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.emailFieldCount, emailFieldCount) || other.emailFieldCount == emailFieldCount));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,emailFieldCount);

@override
String toString() {
  return 'AddContactState(isLoading: $isLoading, emailFieldCount: $emailFieldCount)';
}


}

/// @nodoc
abstract mixin class $AddContactStateCopyWith<$Res>  {
  factory $AddContactStateCopyWith(AddContactState value, $Res Function(AddContactState) _then) = _$AddContactStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, int emailFieldCount
});




}
/// @nodoc
class _$AddContactStateCopyWithImpl<$Res>
    implements $AddContactStateCopyWith<$Res> {
  _$AddContactStateCopyWithImpl(this._self, this._then);

  final AddContactState _self;
  final $Res Function(AddContactState) _then;

/// Create a copy of AddContactState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? emailFieldCount = null,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,emailFieldCount: null == emailFieldCount ? _self.emailFieldCount : emailFieldCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AddContactState].
extension AddContactStatePatterns on AddContactState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddContactState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddContactState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddContactState value)  $default,){
final _that = this;
switch (_that) {
case _AddContactState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddContactState value)?  $default,){
final _that = this;
switch (_that) {
case _AddContactState() when $default != null:
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
case _AddContactState() when $default != null:
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
case _AddContactState():
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
case _AddContactState() when $default != null:
return $default(_that.isLoading,_that.emailFieldCount);case _:
  return null;

}
}

}

/// @nodoc


class _AddContactState implements AddContactState {
  const _AddContactState({this.isLoading = false, this.emailFieldCount = 1});
  

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  int emailFieldCount;

/// Create a copy of AddContactState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddContactStateCopyWith<_AddContactState> get copyWith => __$AddContactStateCopyWithImpl<_AddContactState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddContactState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.emailFieldCount, emailFieldCount) || other.emailFieldCount == emailFieldCount));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,emailFieldCount);

@override
String toString() {
  return 'AddContactState(isLoading: $isLoading, emailFieldCount: $emailFieldCount)';
}


}

/// @nodoc
abstract mixin class _$AddContactStateCopyWith<$Res> implements $AddContactStateCopyWith<$Res> {
  factory _$AddContactStateCopyWith(_AddContactState value, $Res Function(_AddContactState) _then) = __$AddContactStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, int emailFieldCount
});




}
/// @nodoc
class __$AddContactStateCopyWithImpl<$Res>
    implements _$AddContactStateCopyWith<$Res> {
  __$AddContactStateCopyWithImpl(this._self, this._then);

  final _AddContactState _self;
  final $Res Function(_AddContactState) _then;

/// Create a copy of AddContactState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? emailFieldCount = null,}) {
  return _then(_AddContactState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,emailFieldCount: null == emailFieldCount ? _self.emailFieldCount : emailFieldCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
