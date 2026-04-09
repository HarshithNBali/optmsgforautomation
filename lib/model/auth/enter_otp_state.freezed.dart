// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'enter_otp_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EnterOtpState {

// Flags
 bool get loading;// Phone data
 String get formattedPhone; String get mobile; String get countryCode;// User data
 Map<String, dynamic>? get userData;
/// Create a copy of EnterOtpState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnterOtpStateCopyWith<EnterOtpState> get copyWith => _$EnterOtpStateCopyWithImpl<EnterOtpState>(this as EnterOtpState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EnterOtpState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.formattedPhone, formattedPhone) || other.formattedPhone == formattedPhone)&&(identical(other.mobile, mobile) || other.mobile == mobile)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&const DeepCollectionEquality().equals(other.userData, userData));
}


@override
int get hashCode => Object.hash(runtimeType,loading,formattedPhone,mobile,countryCode,const DeepCollectionEquality().hash(userData));

@override
String toString() {
  return 'EnterOtpState(loading: $loading, formattedPhone: $formattedPhone, mobile: $mobile, countryCode: $countryCode, userData: $userData)';
}


}

/// @nodoc
abstract mixin class $EnterOtpStateCopyWith<$Res>  {
  factory $EnterOtpStateCopyWith(EnterOtpState value, $Res Function(EnterOtpState) _then) = _$EnterOtpStateCopyWithImpl;
@useResult
$Res call({
 bool loading, String formattedPhone, String mobile, String countryCode, Map<String, dynamic>? userData
});




}
/// @nodoc
class _$EnterOtpStateCopyWithImpl<$Res>
    implements $EnterOtpStateCopyWith<$Res> {
  _$EnterOtpStateCopyWithImpl(this._self, this._then);

  final EnterOtpState _self;
  final $Res Function(EnterOtpState) _then;

/// Create a copy of EnterOtpState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loading = null,Object? formattedPhone = null,Object? mobile = null,Object? countryCode = null,Object? userData = freezed,}) {
  return _then(_self.copyWith(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,formattedPhone: null == formattedPhone ? _self.formattedPhone : formattedPhone // ignore: cast_nullable_to_non_nullable
as String,mobile: null == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,userData: freezed == userData ? _self.userData : userData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [EnterOtpState].
extension EnterOtpStatePatterns on EnterOtpState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EnterOtpState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EnterOtpState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EnterOtpState value)  $default,){
final _that = this;
switch (_that) {
case _EnterOtpState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EnterOtpState value)?  $default,){
final _that = this;
switch (_that) {
case _EnterOtpState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool loading,  String formattedPhone,  String mobile,  String countryCode,  Map<String, dynamic>? userData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EnterOtpState() when $default != null:
return $default(_that.loading,_that.formattedPhone,_that.mobile,_that.countryCode,_that.userData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool loading,  String formattedPhone,  String mobile,  String countryCode,  Map<String, dynamic>? userData)  $default,) {final _that = this;
switch (_that) {
case _EnterOtpState():
return $default(_that.loading,_that.formattedPhone,_that.mobile,_that.countryCode,_that.userData);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool loading,  String formattedPhone,  String mobile,  String countryCode,  Map<String, dynamic>? userData)?  $default,) {final _that = this;
switch (_that) {
case _EnterOtpState() when $default != null:
return $default(_that.loading,_that.formattedPhone,_that.mobile,_that.countryCode,_that.userData);case _:
  return null;

}
}

}

/// @nodoc


class _EnterOtpState extends EnterOtpState {
  const _EnterOtpState({this.loading = false, this.formattedPhone = '', this.mobile = '', this.countryCode = '+1', final  Map<String, dynamic>? userData}): _userData = userData,super._();
  

// Flags
@override@JsonKey() final  bool loading;
// Phone data
@override@JsonKey() final  String formattedPhone;
@override@JsonKey() final  String mobile;
@override@JsonKey() final  String countryCode;
// User data
 final  Map<String, dynamic>? _userData;
// User data
@override Map<String, dynamic>? get userData {
  final value = _userData;
  if (value == null) return null;
  if (_userData is EqualUnmodifiableMapView) return _userData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of EnterOtpState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EnterOtpStateCopyWith<_EnterOtpState> get copyWith => __$EnterOtpStateCopyWithImpl<_EnterOtpState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EnterOtpState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.formattedPhone, formattedPhone) || other.formattedPhone == formattedPhone)&&(identical(other.mobile, mobile) || other.mobile == mobile)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&const DeepCollectionEquality().equals(other._userData, _userData));
}


@override
int get hashCode => Object.hash(runtimeType,loading,formattedPhone,mobile,countryCode,const DeepCollectionEquality().hash(_userData));

@override
String toString() {
  return 'EnterOtpState(loading: $loading, formattedPhone: $formattedPhone, mobile: $mobile, countryCode: $countryCode, userData: $userData)';
}


}

/// @nodoc
abstract mixin class _$EnterOtpStateCopyWith<$Res> implements $EnterOtpStateCopyWith<$Res> {
  factory _$EnterOtpStateCopyWith(_EnterOtpState value, $Res Function(_EnterOtpState) _then) = __$EnterOtpStateCopyWithImpl;
@override @useResult
$Res call({
 bool loading, String formattedPhone, String mobile, String countryCode, Map<String, dynamic>? userData
});




}
/// @nodoc
class __$EnterOtpStateCopyWithImpl<$Res>
    implements _$EnterOtpStateCopyWith<$Res> {
  __$EnterOtpStateCopyWithImpl(this._self, this._then);

  final _EnterOtpState _self;
  final $Res Function(_EnterOtpState) _then;

/// Create a copy of EnterOtpState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loading = null,Object? formattedPhone = null,Object? mobile = null,Object? countryCode = null,Object? userData = freezed,}) {
  return _then(_EnterOtpState(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,formattedPhone: null == formattedPhone ? _self.formattedPhone : formattedPhone // ignore: cast_nullable_to_non_nullable
as String,mobile: null == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,userData: freezed == userData ? _self._userData : userData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
