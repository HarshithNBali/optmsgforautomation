// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bottom_nav_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BottomNavState {

 int get currentIndex; bool get showBottomNavBar; int get inboxCount; int get trashCount; int get draftCount; int get archiveCount; Map<String, dynamic>? get userData; bool get loading; bool get initialized; String? get lastRoute;
/// Create a copy of BottomNavState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BottomNavStateCopyWith<BottomNavState> get copyWith => _$BottomNavStateCopyWithImpl<BottomNavState>(this as BottomNavState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BottomNavState&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex)&&(identical(other.showBottomNavBar, showBottomNavBar) || other.showBottomNavBar == showBottomNavBar)&&(identical(other.inboxCount, inboxCount) || other.inboxCount == inboxCount)&&(identical(other.trashCount, trashCount) || other.trashCount == trashCount)&&(identical(other.draftCount, draftCount) || other.draftCount == draftCount)&&(identical(other.archiveCount, archiveCount) || other.archiveCount == archiveCount)&&const DeepCollectionEquality().equals(other.userData, userData)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.initialized, initialized) || other.initialized == initialized)&&(identical(other.lastRoute, lastRoute) || other.lastRoute == lastRoute));
}


@override
int get hashCode => Object.hash(runtimeType,currentIndex,showBottomNavBar,inboxCount,trashCount,draftCount,archiveCount,const DeepCollectionEquality().hash(userData),loading,initialized,lastRoute);

@override
String toString() {
  return 'BottomNavState(currentIndex: $currentIndex, showBottomNavBar: $showBottomNavBar, inboxCount: $inboxCount, trashCount: $trashCount, draftCount: $draftCount, archiveCount: $archiveCount, userData: $userData, loading: $loading, initialized: $initialized, lastRoute: $lastRoute)';
}


}

/// @nodoc
abstract mixin class $BottomNavStateCopyWith<$Res>  {
  factory $BottomNavStateCopyWith(BottomNavState value, $Res Function(BottomNavState) _then) = _$BottomNavStateCopyWithImpl;
@useResult
$Res call({
 int currentIndex, bool showBottomNavBar, int inboxCount, int trashCount, int draftCount, int archiveCount, Map<String, dynamic>? userData, bool loading, bool initialized, String? lastRoute
});




}
/// @nodoc
class _$BottomNavStateCopyWithImpl<$Res>
    implements $BottomNavStateCopyWith<$Res> {
  _$BottomNavStateCopyWithImpl(this._self, this._then);

  final BottomNavState _self;
  final $Res Function(BottomNavState) _then;

/// Create a copy of BottomNavState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentIndex = null,Object? showBottomNavBar = null,Object? inboxCount = null,Object? trashCount = null,Object? draftCount = null,Object? archiveCount = null,Object? userData = freezed,Object? loading = null,Object? initialized = null,Object? lastRoute = freezed,}) {
  return _then(_self.copyWith(
currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,showBottomNavBar: null == showBottomNavBar ? _self.showBottomNavBar : showBottomNavBar // ignore: cast_nullable_to_non_nullable
as bool,inboxCount: null == inboxCount ? _self.inboxCount : inboxCount // ignore: cast_nullable_to_non_nullable
as int,trashCount: null == trashCount ? _self.trashCount : trashCount // ignore: cast_nullable_to_non_nullable
as int,draftCount: null == draftCount ? _self.draftCount : draftCount // ignore: cast_nullable_to_non_nullable
as int,archiveCount: null == archiveCount ? _self.archiveCount : archiveCount // ignore: cast_nullable_to_non_nullable
as int,userData: freezed == userData ? _self.userData : userData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,initialized: null == initialized ? _self.initialized : initialized // ignore: cast_nullable_to_non_nullable
as bool,lastRoute: freezed == lastRoute ? _self.lastRoute : lastRoute // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BottomNavState].
extension BottomNavStatePatterns on BottomNavState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BottomNavState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BottomNavState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BottomNavState value)  $default,){
final _that = this;
switch (_that) {
case _BottomNavState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BottomNavState value)?  $default,){
final _that = this;
switch (_that) {
case _BottomNavState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int currentIndex,  bool showBottomNavBar,  int inboxCount,  int trashCount,  int draftCount,  int archiveCount,  Map<String, dynamic>? userData,  bool loading,  bool initialized,  String? lastRoute)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BottomNavState() when $default != null:
return $default(_that.currentIndex,_that.showBottomNavBar,_that.inboxCount,_that.trashCount,_that.draftCount,_that.archiveCount,_that.userData,_that.loading,_that.initialized,_that.lastRoute);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int currentIndex,  bool showBottomNavBar,  int inboxCount,  int trashCount,  int draftCount,  int archiveCount,  Map<String, dynamic>? userData,  bool loading,  bool initialized,  String? lastRoute)  $default,) {final _that = this;
switch (_that) {
case _BottomNavState():
return $default(_that.currentIndex,_that.showBottomNavBar,_that.inboxCount,_that.trashCount,_that.draftCount,_that.archiveCount,_that.userData,_that.loading,_that.initialized,_that.lastRoute);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int currentIndex,  bool showBottomNavBar,  int inboxCount,  int trashCount,  int draftCount,  int archiveCount,  Map<String, dynamic>? userData,  bool loading,  bool initialized,  String? lastRoute)?  $default,) {final _that = this;
switch (_that) {
case _BottomNavState() when $default != null:
return $default(_that.currentIndex,_that.showBottomNavBar,_that.inboxCount,_that.trashCount,_that.draftCount,_that.archiveCount,_that.userData,_that.loading,_that.initialized,_that.lastRoute);case _:
  return null;

}
}

}

/// @nodoc


class _BottomNavState implements BottomNavState {
  const _BottomNavState({this.currentIndex = 0, this.showBottomNavBar = true, this.inboxCount = 0, this.trashCount = 0, this.draftCount = 0, this.archiveCount = 0, final  Map<String, dynamic>? userData, this.loading = false, this.initialized = false, this.lastRoute}): _userData = userData;
  

@override@JsonKey() final  int currentIndex;
@override@JsonKey() final  bool showBottomNavBar;
@override@JsonKey() final  int inboxCount;
@override@JsonKey() final  int trashCount;
@override@JsonKey() final  int draftCount;
@override@JsonKey() final  int archiveCount;
 final  Map<String, dynamic>? _userData;
@override Map<String, dynamic>? get userData {
  final value = _userData;
  if (value == null) return null;
  if (_userData is EqualUnmodifiableMapView) return _userData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey() final  bool loading;
@override@JsonKey() final  bool initialized;
@override final  String? lastRoute;

/// Create a copy of BottomNavState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BottomNavStateCopyWith<_BottomNavState> get copyWith => __$BottomNavStateCopyWithImpl<_BottomNavState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BottomNavState&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex)&&(identical(other.showBottomNavBar, showBottomNavBar) || other.showBottomNavBar == showBottomNavBar)&&(identical(other.inboxCount, inboxCount) || other.inboxCount == inboxCount)&&(identical(other.trashCount, trashCount) || other.trashCount == trashCount)&&(identical(other.draftCount, draftCount) || other.draftCount == draftCount)&&(identical(other.archiveCount, archiveCount) || other.archiveCount == archiveCount)&&const DeepCollectionEquality().equals(other._userData, _userData)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.initialized, initialized) || other.initialized == initialized)&&(identical(other.lastRoute, lastRoute) || other.lastRoute == lastRoute));
}


@override
int get hashCode => Object.hash(runtimeType,currentIndex,showBottomNavBar,inboxCount,trashCount,draftCount,archiveCount,const DeepCollectionEquality().hash(_userData),loading,initialized,lastRoute);

@override
String toString() {
  return 'BottomNavState(currentIndex: $currentIndex, showBottomNavBar: $showBottomNavBar, inboxCount: $inboxCount, trashCount: $trashCount, draftCount: $draftCount, archiveCount: $archiveCount, userData: $userData, loading: $loading, initialized: $initialized, lastRoute: $lastRoute)';
}


}

/// @nodoc
abstract mixin class _$BottomNavStateCopyWith<$Res> implements $BottomNavStateCopyWith<$Res> {
  factory _$BottomNavStateCopyWith(_BottomNavState value, $Res Function(_BottomNavState) _then) = __$BottomNavStateCopyWithImpl;
@override @useResult
$Res call({
 int currentIndex, bool showBottomNavBar, int inboxCount, int trashCount, int draftCount, int archiveCount, Map<String, dynamic>? userData, bool loading, bool initialized, String? lastRoute
});




}
/// @nodoc
class __$BottomNavStateCopyWithImpl<$Res>
    implements _$BottomNavStateCopyWith<$Res> {
  __$BottomNavStateCopyWithImpl(this._self, this._then);

  final _BottomNavState _self;
  final $Res Function(_BottomNavState) _then;

/// Create a copy of BottomNavState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentIndex = null,Object? showBottomNavBar = null,Object? inboxCount = null,Object? trashCount = null,Object? draftCount = null,Object? archiveCount = null,Object? userData = freezed,Object? loading = null,Object? initialized = null,Object? lastRoute = freezed,}) {
  return _then(_BottomNavState(
currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,showBottomNavBar: null == showBottomNavBar ? _self.showBottomNavBar : showBottomNavBar // ignore: cast_nullable_to_non_nullable
as bool,inboxCount: null == inboxCount ? _self.inboxCount : inboxCount // ignore: cast_nullable_to_non_nullable
as int,trashCount: null == trashCount ? _self.trashCount : trashCount // ignore: cast_nullable_to_non_nullable
as int,draftCount: null == draftCount ? _self.draftCount : draftCount // ignore: cast_nullable_to_non_nullable
as int,archiveCount: null == archiveCount ? _self.archiveCount : archiveCount // ignore: cast_nullable_to_non_nullable
as int,userData: freezed == userData ? _self._userData : userData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,initialized: null == initialized ? _self.initialized : initialized // ignore: cast_nullable_to_non_nullable
as bool,lastRoute: freezed == lastRoute ? _self.lastRoute : lastRoute // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
