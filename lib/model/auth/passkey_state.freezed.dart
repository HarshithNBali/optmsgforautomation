// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'passkey_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PasskeyState {

// Flags
 bool get isLoading; bool get isEnabling; bool get isEnabled; bool get passkeySupported; bool get hasCompletedOnboarding;// Data
 Map<String, dynamic>? get userData; String? get errorMessage;
/// Create a copy of PasskeyState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasskeyStateCopyWith<PasskeyState> get copyWith => _$PasskeyStateCopyWithImpl<PasskeyState>(this as PasskeyState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasskeyState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isEnabling, isEnabling) || other.isEnabling == isEnabling)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.passkeySupported, passkeySupported) || other.passkeySupported == passkeySupported)&&(identical(other.hasCompletedOnboarding, hasCompletedOnboarding) || other.hasCompletedOnboarding == hasCompletedOnboarding)&&const DeepCollectionEquality().equals(other.userData, userData)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,isEnabling,isEnabled,passkeySupported,hasCompletedOnboarding,const DeepCollectionEquality().hash(userData),errorMessage);

@override
String toString() {
  return 'PasskeyState(isLoading: $isLoading, isEnabling: $isEnabling, isEnabled: $isEnabled, passkeySupported: $passkeySupported, hasCompletedOnboarding: $hasCompletedOnboarding, userData: $userData, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $PasskeyStateCopyWith<$Res>  {
  factory $PasskeyStateCopyWith(PasskeyState value, $Res Function(PasskeyState) _then) = _$PasskeyStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, bool isEnabling, bool isEnabled, bool passkeySupported, bool hasCompletedOnboarding, Map<String, dynamic>? userData, String? errorMessage
});




}
/// @nodoc
class _$PasskeyStateCopyWithImpl<$Res>
    implements $PasskeyStateCopyWith<$Res> {
  _$PasskeyStateCopyWithImpl(this._self, this._then);

  final PasskeyState _self;
  final $Res Function(PasskeyState) _then;

/// Create a copy of PasskeyState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? isEnabling = null,Object? isEnabled = null,Object? passkeySupported = null,Object? hasCompletedOnboarding = null,Object? userData = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isEnabling: null == isEnabling ? _self.isEnabling : isEnabling // ignore: cast_nullable_to_non_nullable
as bool,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,passkeySupported: null == passkeySupported ? _self.passkeySupported : passkeySupported // ignore: cast_nullable_to_non_nullable
as bool,hasCompletedOnboarding: null == hasCompletedOnboarding ? _self.hasCompletedOnboarding : hasCompletedOnboarding // ignore: cast_nullable_to_non_nullable
as bool,userData: freezed == userData ? _self.userData : userData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PasskeyState].
extension PasskeyStatePatterns on PasskeyState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PasskeyState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PasskeyState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PasskeyState value)  $default,){
final _that = this;
switch (_that) {
case _PasskeyState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PasskeyState value)?  $default,){
final _that = this;
switch (_that) {
case _PasskeyState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  bool isEnabling,  bool isEnabled,  bool passkeySupported,  bool hasCompletedOnboarding,  Map<String, dynamic>? userData,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PasskeyState() when $default != null:
return $default(_that.isLoading,_that.isEnabling,_that.isEnabled,_that.passkeySupported,_that.hasCompletedOnboarding,_that.userData,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  bool isEnabling,  bool isEnabled,  bool passkeySupported,  bool hasCompletedOnboarding,  Map<String, dynamic>? userData,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _PasskeyState():
return $default(_that.isLoading,_that.isEnabling,_that.isEnabled,_that.passkeySupported,_that.hasCompletedOnboarding,_that.userData,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  bool isEnabling,  bool isEnabled,  bool passkeySupported,  bool hasCompletedOnboarding,  Map<String, dynamic>? userData,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _PasskeyState() when $default != null:
return $default(_that.isLoading,_that.isEnabling,_that.isEnabled,_that.passkeySupported,_that.hasCompletedOnboarding,_that.userData,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _PasskeyState extends PasskeyState {
  const _PasskeyState({this.isLoading = false, this.isEnabling = false, this.isEnabled = false, this.passkeySupported = false, this.hasCompletedOnboarding = false, final  Map<String, dynamic>? userData, this.errorMessage}): _userData = userData,super._();
  

// Flags
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isEnabling;
@override@JsonKey() final  bool isEnabled;
@override@JsonKey() final  bool passkeySupported;
@override@JsonKey() final  bool hasCompletedOnboarding;
// Data
 final  Map<String, dynamic>? _userData;
// Data
@override Map<String, dynamic>? get userData {
  final value = _userData;
  if (value == null) return null;
  if (_userData is EqualUnmodifiableMapView) return _userData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? errorMessage;

/// Create a copy of PasskeyState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PasskeyStateCopyWith<_PasskeyState> get copyWith => __$PasskeyStateCopyWithImpl<_PasskeyState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PasskeyState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isEnabling, isEnabling) || other.isEnabling == isEnabling)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.passkeySupported, passkeySupported) || other.passkeySupported == passkeySupported)&&(identical(other.hasCompletedOnboarding, hasCompletedOnboarding) || other.hasCompletedOnboarding == hasCompletedOnboarding)&&const DeepCollectionEquality().equals(other._userData, _userData)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,isEnabling,isEnabled,passkeySupported,hasCompletedOnboarding,const DeepCollectionEquality().hash(_userData),errorMessage);

@override
String toString() {
  return 'PasskeyState(isLoading: $isLoading, isEnabling: $isEnabling, isEnabled: $isEnabled, passkeySupported: $passkeySupported, hasCompletedOnboarding: $hasCompletedOnboarding, userData: $userData, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$PasskeyStateCopyWith<$Res> implements $PasskeyStateCopyWith<$Res> {
  factory _$PasskeyStateCopyWith(_PasskeyState value, $Res Function(_PasskeyState) _then) = __$PasskeyStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, bool isEnabling, bool isEnabled, bool passkeySupported, bool hasCompletedOnboarding, Map<String, dynamic>? userData, String? errorMessage
});




}
/// @nodoc
class __$PasskeyStateCopyWithImpl<$Res>
    implements _$PasskeyStateCopyWith<$Res> {
  __$PasskeyStateCopyWithImpl(this._self, this._then);

  final _PasskeyState _self;
  final $Res Function(_PasskeyState) _then;

/// Create a copy of PasskeyState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? isEnabling = null,Object? isEnabled = null,Object? passkeySupported = null,Object? hasCompletedOnboarding = null,Object? userData = freezed,Object? errorMessage = freezed,}) {
  return _then(_PasskeyState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isEnabling: null == isEnabling ? _self.isEnabling : isEnabling // ignore: cast_nullable_to_non_nullable
as bool,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,passkeySupported: null == passkeySupported ? _self.passkeySupported : passkeySupported // ignore: cast_nullable_to_non_nullable
as bool,hasCompletedOnboarding: null == hasCompletedOnboarding ? _self.hasCompletedOnboarding : hasCompletedOnboarding // ignore: cast_nullable_to_non_nullable
as bool,userData: freezed == userData ? _self._userData : userData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
