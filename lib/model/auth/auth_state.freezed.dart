// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthState {

 AuthStatus get status; bool get isInitialized; String? get errorMessage; AuthErrorType get errorType; Map<String, dynamic>? get verifyUser; bool? get isDescopeLogin; Map<String, dynamic>? get userData; String? get mobile; String? get countryCode; String? get formattedPhone; bool get isUserNameAvailable; bool get isReadOnly;
/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthStateCopyWith<AuthState> get copyWith => _$AuthStateCopyWithImpl<AuthState>(this as AuthState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthState&&(identical(other.status, status) || other.status == status)&&(identical(other.isInitialized, isInitialized) || other.isInitialized == isInitialized)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.errorType, errorType) || other.errorType == errorType)&&const DeepCollectionEquality().equals(other.verifyUser, verifyUser)&&(identical(other.isDescopeLogin, isDescopeLogin) || other.isDescopeLogin == isDescopeLogin)&&const DeepCollectionEquality().equals(other.userData, userData)&&(identical(other.mobile, mobile) || other.mobile == mobile)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.formattedPhone, formattedPhone) || other.formattedPhone == formattedPhone)&&(identical(other.isUserNameAvailable, isUserNameAvailable) || other.isUserNameAvailable == isUserNameAvailable)&&(identical(other.isReadOnly, isReadOnly) || other.isReadOnly == isReadOnly));
}


@override
int get hashCode => Object.hash(runtimeType,status,isInitialized,errorMessage,errorType,const DeepCollectionEquality().hash(verifyUser),isDescopeLogin,const DeepCollectionEquality().hash(userData),mobile,countryCode,formattedPhone,isUserNameAvailable,isReadOnly);

@override
String toString() {
  return 'AuthState(status: $status, isInitialized: $isInitialized, errorMessage: $errorMessage, errorType: $errorType, verifyUser: $verifyUser, isDescopeLogin: $isDescopeLogin, userData: $userData, mobile: $mobile, countryCode: $countryCode, formattedPhone: $formattedPhone, isUserNameAvailable: $isUserNameAvailable, isReadOnly: $isReadOnly)';
}


}

/// @nodoc
abstract mixin class $AuthStateCopyWith<$Res>  {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) _then) = _$AuthStateCopyWithImpl;
@useResult
$Res call({
 AuthStatus status, bool isInitialized, String? errorMessage, AuthErrorType errorType, Map<String, dynamic>? verifyUser, bool? isDescopeLogin, Map<String, dynamic>? userData, String? mobile, String? countryCode, String? formattedPhone, bool isUserNameAvailable, bool isReadOnly
});




}
/// @nodoc
class _$AuthStateCopyWithImpl<$Res>
    implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._self, this._then);

  final AuthState _self;
  final $Res Function(AuthState) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? isInitialized = null,Object? errorMessage = freezed,Object? errorType = null,Object? verifyUser = freezed,Object? isDescopeLogin = freezed,Object? userData = freezed,Object? mobile = freezed,Object? countryCode = freezed,Object? formattedPhone = freezed,Object? isUserNameAvailable = null,Object? isReadOnly = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AuthStatus,isInitialized: null == isInitialized ? _self.isInitialized : isInitialized // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,errorType: null == errorType ? _self.errorType : errorType // ignore: cast_nullable_to_non_nullable
as AuthErrorType,verifyUser: freezed == verifyUser ? _self.verifyUser : verifyUser // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,isDescopeLogin: freezed == isDescopeLogin ? _self.isDescopeLogin : isDescopeLogin // ignore: cast_nullable_to_non_nullable
as bool?,userData: freezed == userData ? _self.userData : userData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,mobile: freezed == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String?,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,formattedPhone: freezed == formattedPhone ? _self.formattedPhone : formattedPhone // ignore: cast_nullable_to_non_nullable
as String?,isUserNameAvailable: null == isUserNameAvailable ? _self.isUserNameAvailable : isUserNameAvailable // ignore: cast_nullable_to_non_nullable
as bool,isReadOnly: null == isReadOnly ? _self.isReadOnly : isReadOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthState].
extension AuthStatePatterns on AuthState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthState value)  $default,){
final _that = this;
switch (_that) {
case _AuthState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthState value)?  $default,){
final _that = this;
switch (_that) {
case _AuthState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AuthStatus status,  bool isInitialized,  String? errorMessage,  AuthErrorType errorType,  Map<String, dynamic>? verifyUser,  bool? isDescopeLogin,  Map<String, dynamic>? userData,  String? mobile,  String? countryCode,  String? formattedPhone,  bool isUserNameAvailable,  bool isReadOnly)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthState() when $default != null:
return $default(_that.status,_that.isInitialized,_that.errorMessage,_that.errorType,_that.verifyUser,_that.isDescopeLogin,_that.userData,_that.mobile,_that.countryCode,_that.formattedPhone,_that.isUserNameAvailable,_that.isReadOnly);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AuthStatus status,  bool isInitialized,  String? errorMessage,  AuthErrorType errorType,  Map<String, dynamic>? verifyUser,  bool? isDescopeLogin,  Map<String, dynamic>? userData,  String? mobile,  String? countryCode,  String? formattedPhone,  bool isUserNameAvailable,  bool isReadOnly)  $default,) {final _that = this;
switch (_that) {
case _AuthState():
return $default(_that.status,_that.isInitialized,_that.errorMessage,_that.errorType,_that.verifyUser,_that.isDescopeLogin,_that.userData,_that.mobile,_that.countryCode,_that.formattedPhone,_that.isUserNameAvailable,_that.isReadOnly);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AuthStatus status,  bool isInitialized,  String? errorMessage,  AuthErrorType errorType,  Map<String, dynamic>? verifyUser,  bool? isDescopeLogin,  Map<String, dynamic>? userData,  String? mobile,  String? countryCode,  String? formattedPhone,  bool isUserNameAvailable,  bool isReadOnly)?  $default,) {final _that = this;
switch (_that) {
case _AuthState() when $default != null:
return $default(_that.status,_that.isInitialized,_that.errorMessage,_that.errorType,_that.verifyUser,_that.isDescopeLogin,_that.userData,_that.mobile,_that.countryCode,_that.formattedPhone,_that.isUserNameAvailable,_that.isReadOnly);case _:
  return null;

}
}

}

/// @nodoc


class _AuthState extends AuthState {
  const _AuthState({required this.status, this.isInitialized = false, this.errorMessage, this.errorType = AuthErrorType.generic, final  Map<String, dynamic>? verifyUser, this.isDescopeLogin, final  Map<String, dynamic>? userData, this.mobile, this.countryCode, this.formattedPhone, this.isUserNameAvailable = false, this.isReadOnly = false}): _verifyUser = verifyUser,_userData = userData,super._();
  

@override final  AuthStatus status;
@override@JsonKey() final  bool isInitialized;
@override final  String? errorMessage;
@override@JsonKey() final  AuthErrorType errorType;
 final  Map<String, dynamic>? _verifyUser;
@override Map<String, dynamic>? get verifyUser {
  final value = _verifyUser;
  if (value == null) return null;
  if (_verifyUser is EqualUnmodifiableMapView) return _verifyUser;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  bool? isDescopeLogin;
 final  Map<String, dynamic>? _userData;
@override Map<String, dynamic>? get userData {
  final value = _userData;
  if (value == null) return null;
  if (_userData is EqualUnmodifiableMapView) return _userData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? mobile;
@override final  String? countryCode;
@override final  String? formattedPhone;
@override@JsonKey() final  bool isUserNameAvailable;
@override@JsonKey() final  bool isReadOnly;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthStateCopyWith<_AuthState> get copyWith => __$AuthStateCopyWithImpl<_AuthState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthState&&(identical(other.status, status) || other.status == status)&&(identical(other.isInitialized, isInitialized) || other.isInitialized == isInitialized)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.errorType, errorType) || other.errorType == errorType)&&const DeepCollectionEquality().equals(other._verifyUser, _verifyUser)&&(identical(other.isDescopeLogin, isDescopeLogin) || other.isDescopeLogin == isDescopeLogin)&&const DeepCollectionEquality().equals(other._userData, _userData)&&(identical(other.mobile, mobile) || other.mobile == mobile)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.formattedPhone, formattedPhone) || other.formattedPhone == formattedPhone)&&(identical(other.isUserNameAvailable, isUserNameAvailable) || other.isUserNameAvailable == isUserNameAvailable)&&(identical(other.isReadOnly, isReadOnly) || other.isReadOnly == isReadOnly));
}


@override
int get hashCode => Object.hash(runtimeType,status,isInitialized,errorMessage,errorType,const DeepCollectionEquality().hash(_verifyUser),isDescopeLogin,const DeepCollectionEquality().hash(_userData),mobile,countryCode,formattedPhone,isUserNameAvailable,isReadOnly);

@override
String toString() {
  return 'AuthState(status: $status, isInitialized: $isInitialized, errorMessage: $errorMessage, errorType: $errorType, verifyUser: $verifyUser, isDescopeLogin: $isDescopeLogin, userData: $userData, mobile: $mobile, countryCode: $countryCode, formattedPhone: $formattedPhone, isUserNameAvailable: $isUserNameAvailable, isReadOnly: $isReadOnly)';
}


}

/// @nodoc
abstract mixin class _$AuthStateCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory _$AuthStateCopyWith(_AuthState value, $Res Function(_AuthState) _then) = __$AuthStateCopyWithImpl;
@override @useResult
$Res call({
 AuthStatus status, bool isInitialized, String? errorMessage, AuthErrorType errorType, Map<String, dynamic>? verifyUser, bool? isDescopeLogin, Map<String, dynamic>? userData, String? mobile, String? countryCode, String? formattedPhone, bool isUserNameAvailable, bool isReadOnly
});




}
/// @nodoc
class __$AuthStateCopyWithImpl<$Res>
    implements _$AuthStateCopyWith<$Res> {
  __$AuthStateCopyWithImpl(this._self, this._then);

  final _AuthState _self;
  final $Res Function(_AuthState) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? isInitialized = null,Object? errorMessage = freezed,Object? errorType = null,Object? verifyUser = freezed,Object? isDescopeLogin = freezed,Object? userData = freezed,Object? mobile = freezed,Object? countryCode = freezed,Object? formattedPhone = freezed,Object? isUserNameAvailable = null,Object? isReadOnly = null,}) {
  return _then(_AuthState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AuthStatus,isInitialized: null == isInitialized ? _self.isInitialized : isInitialized // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,errorType: null == errorType ? _self.errorType : errorType // ignore: cast_nullable_to_non_nullable
as AuthErrorType,verifyUser: freezed == verifyUser ? _self._verifyUser : verifyUser // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,isDescopeLogin: freezed == isDescopeLogin ? _self.isDescopeLogin : isDescopeLogin // ignore: cast_nullable_to_non_nullable
as bool?,userData: freezed == userData ? _self._userData : userData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,mobile: freezed == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String?,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,formattedPhone: freezed == formattedPhone ? _self.formattedPhone : formattedPhone // ignore: cast_nullable_to_non_nullable
as String?,isUserNameAvailable: null == isUserNameAvailable ? _self.isUserNameAvailable : isUserNameAvailable // ignore: cast_nullable_to_non_nullable
as bool,isReadOnly: null == isReadOnly ? _self.isReadOnly : isReadOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
