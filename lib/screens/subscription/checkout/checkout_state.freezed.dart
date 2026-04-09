// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkout_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CheckoutState {

 bool get isLoading; Map<String, dynamic>? get selectedPlan; String get subscriptionPage; bool get isPromoApplied; double get grandTotal; double get originalCharge; double get discount; String get discountType; String get planType; String get token; MyProfile? get profile; String get promoCode; String? get errorMessage; String? get paymentStatus;
/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckoutStateCopyWith<CheckoutState> get copyWith => _$CheckoutStateCopyWithImpl<CheckoutState>(this as CheckoutState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other.selectedPlan, selectedPlan)&&(identical(other.subscriptionPage, subscriptionPage) || other.subscriptionPage == subscriptionPage)&&(identical(other.isPromoApplied, isPromoApplied) || other.isPromoApplied == isPromoApplied)&&(identical(other.grandTotal, grandTotal) || other.grandTotal == grandTotal)&&(identical(other.originalCharge, originalCharge) || other.originalCharge == originalCharge)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.discountType, discountType) || other.discountType == discountType)&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.token, token) || other.token == token)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.promoCode, promoCode) || other.promoCode == promoCode)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(selectedPlan),subscriptionPage,isPromoApplied,grandTotal,originalCharge,discount,discountType,planType,token,profile,promoCode,errorMessage,paymentStatus);

@override
String toString() {
  return 'CheckoutState(isLoading: $isLoading, selectedPlan: $selectedPlan, subscriptionPage: $subscriptionPage, isPromoApplied: $isPromoApplied, grandTotal: $grandTotal, originalCharge: $originalCharge, discount: $discount, discountType: $discountType, planType: $planType, token: $token, profile: $profile, promoCode: $promoCode, errorMessage: $errorMessage, paymentStatus: $paymentStatus)';
}


}

/// @nodoc
abstract mixin class $CheckoutStateCopyWith<$Res>  {
  factory $CheckoutStateCopyWith(CheckoutState value, $Res Function(CheckoutState) _then) = _$CheckoutStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, Map<String, dynamic>? selectedPlan, String subscriptionPage, bool isPromoApplied, double grandTotal, double originalCharge, double discount, String discountType, String planType, String token, MyProfile? profile, String promoCode, String? errorMessage, String? paymentStatus
});




}
/// @nodoc
class _$CheckoutStateCopyWithImpl<$Res>
    implements $CheckoutStateCopyWith<$Res> {
  _$CheckoutStateCopyWithImpl(this._self, this._then);

  final CheckoutState _self;
  final $Res Function(CheckoutState) _then;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? selectedPlan = freezed,Object? subscriptionPage = null,Object? isPromoApplied = null,Object? grandTotal = null,Object? originalCharge = null,Object? discount = null,Object? discountType = null,Object? planType = null,Object? token = null,Object? profile = freezed,Object? promoCode = null,Object? errorMessage = freezed,Object? paymentStatus = freezed,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,selectedPlan: freezed == selectedPlan ? _self.selectedPlan : selectedPlan // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,subscriptionPage: null == subscriptionPage ? _self.subscriptionPage : subscriptionPage // ignore: cast_nullable_to_non_nullable
as String,isPromoApplied: null == isPromoApplied ? _self.isPromoApplied : isPromoApplied // ignore: cast_nullable_to_non_nullable
as bool,grandTotal: null == grandTotal ? _self.grandTotal : grandTotal // ignore: cast_nullable_to_non_nullable
as double,originalCharge: null == originalCharge ? _self.originalCharge : originalCharge // ignore: cast_nullable_to_non_nullable
as double,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double,discountType: null == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as String,planType: null == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as MyProfile?,promoCode: null == promoCode ? _self.promoCode : promoCode // ignore: cast_nullable_to_non_nullable
as String,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,paymentStatus: freezed == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckoutState].
extension CheckoutStatePatterns on CheckoutState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckoutState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckoutState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckoutState value)  $default,){
final _that = this;
switch (_that) {
case _CheckoutState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckoutState value)?  $default,){
final _that = this;
switch (_that) {
case _CheckoutState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  Map<String, dynamic>? selectedPlan,  String subscriptionPage,  bool isPromoApplied,  double grandTotal,  double originalCharge,  double discount,  String discountType,  String planType,  String token,  MyProfile? profile,  String promoCode,  String? errorMessage,  String? paymentStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckoutState() when $default != null:
return $default(_that.isLoading,_that.selectedPlan,_that.subscriptionPage,_that.isPromoApplied,_that.grandTotal,_that.originalCharge,_that.discount,_that.discountType,_that.planType,_that.token,_that.profile,_that.promoCode,_that.errorMessage,_that.paymentStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  Map<String, dynamic>? selectedPlan,  String subscriptionPage,  bool isPromoApplied,  double grandTotal,  double originalCharge,  double discount,  String discountType,  String planType,  String token,  MyProfile? profile,  String promoCode,  String? errorMessage,  String? paymentStatus)  $default,) {final _that = this;
switch (_that) {
case _CheckoutState():
return $default(_that.isLoading,_that.selectedPlan,_that.subscriptionPage,_that.isPromoApplied,_that.grandTotal,_that.originalCharge,_that.discount,_that.discountType,_that.planType,_that.token,_that.profile,_that.promoCode,_that.errorMessage,_that.paymentStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  Map<String, dynamic>? selectedPlan,  String subscriptionPage,  bool isPromoApplied,  double grandTotal,  double originalCharge,  double discount,  String discountType,  String planType,  String token,  MyProfile? profile,  String promoCode,  String? errorMessage,  String? paymentStatus)?  $default,) {final _that = this;
switch (_that) {
case _CheckoutState() when $default != null:
return $default(_that.isLoading,_that.selectedPlan,_that.subscriptionPage,_that.isPromoApplied,_that.grandTotal,_that.originalCharge,_that.discount,_that.discountType,_that.planType,_that.token,_that.profile,_that.promoCode,_that.errorMessage,_that.paymentStatus);case _:
  return null;

}
}

}

/// @nodoc


class _CheckoutState implements CheckoutState {
  const _CheckoutState({this.isLoading = false, final  Map<String, dynamic>? selectedPlan, this.subscriptionPage = '', this.isPromoApplied = false, this.grandTotal = 0, this.originalCharge = 0, this.discount = 0, this.discountType = '', this.planType = '', this.token = '', this.profile, this.promoCode = '', this.errorMessage, this.paymentStatus}): _selectedPlan = selectedPlan;
  

@override@JsonKey() final  bool isLoading;
 final  Map<String, dynamic>? _selectedPlan;
@override Map<String, dynamic>? get selectedPlan {
  final value = _selectedPlan;
  if (value == null) return null;
  if (_selectedPlan is EqualUnmodifiableMapView) return _selectedPlan;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey() final  String subscriptionPage;
@override@JsonKey() final  bool isPromoApplied;
@override@JsonKey() final  double grandTotal;
@override@JsonKey() final  double originalCharge;
@override@JsonKey() final  double discount;
@override@JsonKey() final  String discountType;
@override@JsonKey() final  String planType;
@override@JsonKey() final  String token;
@override final  MyProfile? profile;
@override@JsonKey() final  String promoCode;
@override final  String? errorMessage;
@override final  String? paymentStatus;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckoutStateCopyWith<_CheckoutState> get copyWith => __$CheckoutStateCopyWithImpl<_CheckoutState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckoutState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other._selectedPlan, _selectedPlan)&&(identical(other.subscriptionPage, subscriptionPage) || other.subscriptionPage == subscriptionPage)&&(identical(other.isPromoApplied, isPromoApplied) || other.isPromoApplied == isPromoApplied)&&(identical(other.grandTotal, grandTotal) || other.grandTotal == grandTotal)&&(identical(other.originalCharge, originalCharge) || other.originalCharge == originalCharge)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.discountType, discountType) || other.discountType == discountType)&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.token, token) || other.token == token)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.promoCode, promoCode) || other.promoCode == promoCode)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(_selectedPlan),subscriptionPage,isPromoApplied,grandTotal,originalCharge,discount,discountType,planType,token,profile,promoCode,errorMessage,paymentStatus);

@override
String toString() {
  return 'CheckoutState(isLoading: $isLoading, selectedPlan: $selectedPlan, subscriptionPage: $subscriptionPage, isPromoApplied: $isPromoApplied, grandTotal: $grandTotal, originalCharge: $originalCharge, discount: $discount, discountType: $discountType, planType: $planType, token: $token, profile: $profile, promoCode: $promoCode, errorMessage: $errorMessage, paymentStatus: $paymentStatus)';
}


}

/// @nodoc
abstract mixin class _$CheckoutStateCopyWith<$Res> implements $CheckoutStateCopyWith<$Res> {
  factory _$CheckoutStateCopyWith(_CheckoutState value, $Res Function(_CheckoutState) _then) = __$CheckoutStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, Map<String, dynamic>? selectedPlan, String subscriptionPage, bool isPromoApplied, double grandTotal, double originalCharge, double discount, String discountType, String planType, String token, MyProfile? profile, String promoCode, String? errorMessage, String? paymentStatus
});




}
/// @nodoc
class __$CheckoutStateCopyWithImpl<$Res>
    implements _$CheckoutStateCopyWith<$Res> {
  __$CheckoutStateCopyWithImpl(this._self, this._then);

  final _CheckoutState _self;
  final $Res Function(_CheckoutState) _then;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? selectedPlan = freezed,Object? subscriptionPage = null,Object? isPromoApplied = null,Object? grandTotal = null,Object? originalCharge = null,Object? discount = null,Object? discountType = null,Object? planType = null,Object? token = null,Object? profile = freezed,Object? promoCode = null,Object? errorMessage = freezed,Object? paymentStatus = freezed,}) {
  return _then(_CheckoutState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,selectedPlan: freezed == selectedPlan ? _self._selectedPlan : selectedPlan // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,subscriptionPage: null == subscriptionPage ? _self.subscriptionPage : subscriptionPage // ignore: cast_nullable_to_non_nullable
as String,isPromoApplied: null == isPromoApplied ? _self.isPromoApplied : isPromoApplied // ignore: cast_nullable_to_non_nullable
as bool,grandTotal: null == grandTotal ? _self.grandTotal : grandTotal // ignore: cast_nullable_to_non_nullable
as double,originalCharge: null == originalCharge ? _self.originalCharge : originalCharge // ignore: cast_nullable_to_non_nullable
as double,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double,discountType: null == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as String,planType: null == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as MyProfile?,promoCode: null == promoCode ? _self.promoCode : promoCode // ignore: cast_nullable_to_non_nullable
as String,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,paymentStatus: freezed == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
