// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'web_enter_otp_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WebEnterOtpState {

 bool get isLoading; String get formattedPhoneNumber; String get countryCode; String get deviceToken; int get resendCooldownSeconds; Map<String, dynamic>? get userData;
/// Create a copy of WebEnterOtpState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WebEnterOtpStateCopyWith<WebEnterOtpState> get copyWith => _$WebEnterOtpStateCopyWithImpl<WebEnterOtpState>(this as WebEnterOtpState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WebEnterOtpState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.formattedPhoneNumber, formattedPhoneNumber) || other.formattedPhoneNumber == formattedPhoneNumber)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.deviceToken, deviceToken) || other.deviceToken == deviceToken)&&(identical(other.resendCooldownSeconds, resendCooldownSeconds) || other.resendCooldownSeconds == resendCooldownSeconds)&&const DeepCollectionEquality().equals(other.userData, userData));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,formattedPhoneNumber,countryCode,deviceToken,resendCooldownSeconds,const DeepCollectionEquality().hash(userData));

@override
String toString() {
  return 'WebEnterOtpState(isLoading: $isLoading, formattedPhoneNumber: $formattedPhoneNumber, countryCode: $countryCode, deviceToken: $deviceToken, resendCooldownSeconds: $resendCooldownSeconds, userData: $userData)';
}


}

/// @nodoc
abstract mixin class $WebEnterOtpStateCopyWith<$Res>  {
  factory $WebEnterOtpStateCopyWith(WebEnterOtpState value, $Res Function(WebEnterOtpState) _then) = _$WebEnterOtpStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, String formattedPhoneNumber, String countryCode, String deviceToken, int resendCooldownSeconds, Map<String, dynamic>? userData
});




}
/// @nodoc
class _$WebEnterOtpStateCopyWithImpl<$Res>
    implements $WebEnterOtpStateCopyWith<$Res> {
  _$WebEnterOtpStateCopyWithImpl(this._self, this._then);

  final WebEnterOtpState _self;
  final $Res Function(WebEnterOtpState) _then;

/// Create a copy of WebEnterOtpState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? formattedPhoneNumber = null,Object? countryCode = null,Object? deviceToken = null,Object? resendCooldownSeconds = null,Object? userData = freezed,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,formattedPhoneNumber: null == formattedPhoneNumber ? _self.formattedPhoneNumber : formattedPhoneNumber // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,deviceToken: null == deviceToken ? _self.deviceToken : deviceToken // ignore: cast_nullable_to_non_nullable
as String,resendCooldownSeconds: null == resendCooldownSeconds ? _self.resendCooldownSeconds : resendCooldownSeconds // ignore: cast_nullable_to_non_nullable
as int,userData: freezed == userData ? _self.userData : userData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [WebEnterOtpState].
extension WebEnterOtpStatePatterns on WebEnterOtpState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WebEnterOtpState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WebEnterOtpState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WebEnterOtpState value)  $default,){
final _that = this;
switch (_that) {
case _WebEnterOtpState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WebEnterOtpState value)?  $default,){
final _that = this;
switch (_that) {
case _WebEnterOtpState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  String formattedPhoneNumber,  String countryCode,  String deviceToken,  int resendCooldownSeconds,  Map<String, dynamic>? userData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WebEnterOtpState() when $default != null:
return $default(_that.isLoading,_that.formattedPhoneNumber,_that.countryCode,_that.deviceToken,_that.resendCooldownSeconds,_that.userData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  String formattedPhoneNumber,  String countryCode,  String deviceToken,  int resendCooldownSeconds,  Map<String, dynamic>? userData)  $default,) {final _that = this;
switch (_that) {
case _WebEnterOtpState():
return $default(_that.isLoading,_that.formattedPhoneNumber,_that.countryCode,_that.deviceToken,_that.resendCooldownSeconds,_that.userData);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  String formattedPhoneNumber,  String countryCode,  String deviceToken,  int resendCooldownSeconds,  Map<String, dynamic>? userData)?  $default,) {final _that = this;
switch (_that) {
case _WebEnterOtpState() when $default != null:
return $default(_that.isLoading,_that.formattedPhoneNumber,_that.countryCode,_that.deviceToken,_that.resendCooldownSeconds,_that.userData);case _:
  return null;

}
}

}

/// @nodoc


class _WebEnterOtpState implements WebEnterOtpState {
  const _WebEnterOtpState({this.isLoading = false, this.formattedPhoneNumber = '', this.countryCode = '+1', this.deviceToken = '', this.resendCooldownSeconds = 0, final  Map<String, dynamic>? userData}): _userData = userData;
  

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  String formattedPhoneNumber;
@override@JsonKey() final  String countryCode;
@override@JsonKey() final  String deviceToken;
@override@JsonKey() final  int resendCooldownSeconds;
 final  Map<String, dynamic>? _userData;
@override Map<String, dynamic>? get userData {
  final value = _userData;
  if (value == null) return null;
  if (_userData is EqualUnmodifiableMapView) return _userData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of WebEnterOtpState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WebEnterOtpStateCopyWith<_WebEnterOtpState> get copyWith => __$WebEnterOtpStateCopyWithImpl<_WebEnterOtpState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WebEnterOtpState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.formattedPhoneNumber, formattedPhoneNumber) || other.formattedPhoneNumber == formattedPhoneNumber)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.deviceToken, deviceToken) || other.deviceToken == deviceToken)&&(identical(other.resendCooldownSeconds, resendCooldownSeconds) || other.resendCooldownSeconds == resendCooldownSeconds)&&const DeepCollectionEquality().equals(other._userData, _userData));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,formattedPhoneNumber,countryCode,deviceToken,resendCooldownSeconds,const DeepCollectionEquality().hash(_userData));

@override
String toString() {
  return 'WebEnterOtpState(isLoading: $isLoading, formattedPhoneNumber: $formattedPhoneNumber, countryCode: $countryCode, deviceToken: $deviceToken, resendCooldownSeconds: $resendCooldownSeconds, userData: $userData)';
}


}

/// @nodoc
abstract mixin class _$WebEnterOtpStateCopyWith<$Res> implements $WebEnterOtpStateCopyWith<$Res> {
  factory _$WebEnterOtpStateCopyWith(_WebEnterOtpState value, $Res Function(_WebEnterOtpState) _then) = __$WebEnterOtpStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, String formattedPhoneNumber, String countryCode, String deviceToken, int resendCooldownSeconds, Map<String, dynamic>? userData
});




}
/// @nodoc
class __$WebEnterOtpStateCopyWithImpl<$Res>
    implements _$WebEnterOtpStateCopyWith<$Res> {
  __$WebEnterOtpStateCopyWithImpl(this._self, this._then);

  final _WebEnterOtpState _self;
  final $Res Function(_WebEnterOtpState) _then;

/// Create a copy of WebEnterOtpState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? formattedPhoneNumber = null,Object? countryCode = null,Object? deviceToken = null,Object? resendCooldownSeconds = null,Object? userData = freezed,}) {
  return _then(_WebEnterOtpState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,formattedPhoneNumber: null == formattedPhoneNumber ? _self.formattedPhoneNumber : formattedPhoneNumber // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,deviceToken: null == deviceToken ? _self.deviceToken : deviceToken // ignore: cast_nullable_to_non_nullable
as String,resendCooldownSeconds: null == resendCooldownSeconds ? _self.resendCooldownSeconds : resendCooldownSeconds // ignore: cast_nullable_to_non_nullable
as int,userData: freezed == userData ? _self._userData : userData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
