// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'global_variable_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GlobalVariableState {

 List<String> get pathList; bool get hasCalledLastActivity; String get emailNavigation;
/// Create a copy of GlobalVariableState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GlobalVariableStateCopyWith<GlobalVariableState> get copyWith => _$GlobalVariableStateCopyWithImpl<GlobalVariableState>(this as GlobalVariableState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GlobalVariableState&&const DeepCollectionEquality().equals(other.pathList, pathList)&&(identical(other.hasCalledLastActivity, hasCalledLastActivity) || other.hasCalledLastActivity == hasCalledLastActivity)&&(identical(other.emailNavigation, emailNavigation) || other.emailNavigation == emailNavigation));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(pathList),hasCalledLastActivity,emailNavigation);

@override
String toString() {
  return 'GlobalVariableState(pathList: $pathList, hasCalledLastActivity: $hasCalledLastActivity, emailNavigation: $emailNavigation)';
}


}

/// @nodoc
abstract mixin class $GlobalVariableStateCopyWith<$Res>  {
  factory $GlobalVariableStateCopyWith(GlobalVariableState value, $Res Function(GlobalVariableState) _then) = _$GlobalVariableStateCopyWithImpl;
@useResult
$Res call({
 List<String> pathList, bool hasCalledLastActivity, String emailNavigation
});




}
/// @nodoc
class _$GlobalVariableStateCopyWithImpl<$Res>
    implements $GlobalVariableStateCopyWith<$Res> {
  _$GlobalVariableStateCopyWithImpl(this._self, this._then);

  final GlobalVariableState _self;
  final $Res Function(GlobalVariableState) _then;

/// Create a copy of GlobalVariableState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pathList = null,Object? hasCalledLastActivity = null,Object? emailNavigation = null,}) {
  return _then(_self.copyWith(
pathList: null == pathList ? _self.pathList : pathList // ignore: cast_nullable_to_non_nullable
as List<String>,hasCalledLastActivity: null == hasCalledLastActivity ? _self.hasCalledLastActivity : hasCalledLastActivity // ignore: cast_nullable_to_non_nullable
as bool,emailNavigation: null == emailNavigation ? _self.emailNavigation : emailNavigation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GlobalVariableState].
extension GlobalVariableStatePatterns on GlobalVariableState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GlobalVariableState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GlobalVariableState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GlobalVariableState value)  $default,){
final _that = this;
switch (_that) {
case _GlobalVariableState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GlobalVariableState value)?  $default,){
final _that = this;
switch (_that) {
case _GlobalVariableState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> pathList,  bool hasCalledLastActivity,  String emailNavigation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GlobalVariableState() when $default != null:
return $default(_that.pathList,_that.hasCalledLastActivity,_that.emailNavigation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> pathList,  bool hasCalledLastActivity,  String emailNavigation)  $default,) {final _that = this;
switch (_that) {
case _GlobalVariableState():
return $default(_that.pathList,_that.hasCalledLastActivity,_that.emailNavigation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> pathList,  bool hasCalledLastActivity,  String emailNavigation)?  $default,) {final _that = this;
switch (_that) {
case _GlobalVariableState() when $default != null:
return $default(_that.pathList,_that.hasCalledLastActivity,_that.emailNavigation);case _:
  return null;

}
}

}

/// @nodoc


class _GlobalVariableState implements GlobalVariableState {
  const _GlobalVariableState({final  List<String> pathList = const [], this.hasCalledLastActivity = false, this.emailNavigation = '1'}): _pathList = pathList;
  

 final  List<String> _pathList;
@override@JsonKey() List<String> get pathList {
  if (_pathList is EqualUnmodifiableListView) return _pathList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pathList);
}

@override@JsonKey() final  bool hasCalledLastActivity;
@override@JsonKey() final  String emailNavigation;

/// Create a copy of GlobalVariableState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GlobalVariableStateCopyWith<_GlobalVariableState> get copyWith => __$GlobalVariableStateCopyWithImpl<_GlobalVariableState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GlobalVariableState&&const DeepCollectionEquality().equals(other._pathList, _pathList)&&(identical(other.hasCalledLastActivity, hasCalledLastActivity) || other.hasCalledLastActivity == hasCalledLastActivity)&&(identical(other.emailNavigation, emailNavigation) || other.emailNavigation == emailNavigation));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_pathList),hasCalledLastActivity,emailNavigation);

@override
String toString() {
  return 'GlobalVariableState(pathList: $pathList, hasCalledLastActivity: $hasCalledLastActivity, emailNavigation: $emailNavigation)';
}


}

/// @nodoc
abstract mixin class _$GlobalVariableStateCopyWith<$Res> implements $GlobalVariableStateCopyWith<$Res> {
  factory _$GlobalVariableStateCopyWith(_GlobalVariableState value, $Res Function(_GlobalVariableState) _then) = __$GlobalVariableStateCopyWithImpl;
@override @useResult
$Res call({
 List<String> pathList, bool hasCalledLastActivity, String emailNavigation
});




}
/// @nodoc
class __$GlobalVariableStateCopyWithImpl<$Res>
    implements _$GlobalVariableStateCopyWith<$Res> {
  __$GlobalVariableStateCopyWithImpl(this._self, this._then);

  final _GlobalVariableState _self;
  final $Res Function(_GlobalVariableState) _then;

/// Create a copy of GlobalVariableState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pathList = null,Object? hasCalledLastActivity = null,Object? emailNavigation = null,}) {
  return _then(_GlobalVariableState(
pathList: null == pathList ? _self._pathList : pathList // ignore: cast_nullable_to_non_nullable
as List<String>,hasCalledLastActivity: null == hasCalledLastActivity ? _self.hasCalledLastActivity : hasCalledLastActivity // ignore: cast_nullable_to_non_nullable
as bool,emailNavigation: null == emailNavigation ? _self.emailNavigation : emailNavigation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
