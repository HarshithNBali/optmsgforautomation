// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'view_contact_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ViewContactState {

 bool get isSubmitting; bool get loadingContactDetails; bool get readingPaneEnabled; String get token; List<Contact> get emails; Contacts? get contact;
/// Create a copy of ViewContactState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ViewContactStateCopyWith<ViewContactState> get copyWith => _$ViewContactStateCopyWithImpl<ViewContactState>(this as ViewContactState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ViewContactState&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.loadingContactDetails, loadingContactDetails) || other.loadingContactDetails == loadingContactDetails)&&(identical(other.readingPaneEnabled, readingPaneEnabled) || other.readingPaneEnabled == readingPaneEnabled)&&(identical(other.token, token) || other.token == token)&&const DeepCollectionEquality().equals(other.emails, emails)&&(identical(other.contact, contact) || other.contact == contact));
}


@override
int get hashCode => Object.hash(runtimeType,isSubmitting,loadingContactDetails,readingPaneEnabled,token,const DeepCollectionEquality().hash(emails),contact);

@override
String toString() {
  return 'ViewContactState(isSubmitting: $isSubmitting, loadingContactDetails: $loadingContactDetails, readingPaneEnabled: $readingPaneEnabled, token: $token, emails: $emails, contact: $contact)';
}


}

/// @nodoc
abstract mixin class $ViewContactStateCopyWith<$Res>  {
  factory $ViewContactStateCopyWith(ViewContactState value, $Res Function(ViewContactState) _then) = _$ViewContactStateCopyWithImpl;
@useResult
$Res call({
 bool isSubmitting, bool loadingContactDetails, bool readingPaneEnabled, String token, List<Contact> emails, Contacts? contact
});




}
/// @nodoc
class _$ViewContactStateCopyWithImpl<$Res>
    implements $ViewContactStateCopyWith<$Res> {
  _$ViewContactStateCopyWithImpl(this._self, this._then);

  final ViewContactState _self;
  final $Res Function(ViewContactState) _then;

/// Create a copy of ViewContactState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isSubmitting = null,Object? loadingContactDetails = null,Object? readingPaneEnabled = null,Object? token = null,Object? emails = null,Object? contact = freezed,}) {
  return _then(_self.copyWith(
isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,loadingContactDetails: null == loadingContactDetails ? _self.loadingContactDetails : loadingContactDetails // ignore: cast_nullable_to_non_nullable
as bool,readingPaneEnabled: null == readingPaneEnabled ? _self.readingPaneEnabled : readingPaneEnabled // ignore: cast_nullable_to_non_nullable
as bool,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,emails: null == emails ? _self.emails : emails // ignore: cast_nullable_to_non_nullable
as List<Contact>,contact: freezed == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as Contacts?,
  ));
}

}


/// Adds pattern-matching-related methods to [ViewContactState].
extension ViewContactStatePatterns on ViewContactState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ViewContactState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ViewContactState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ViewContactState value)  $default,){
final _that = this;
switch (_that) {
case _ViewContactState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ViewContactState value)?  $default,){
final _that = this;
switch (_that) {
case _ViewContactState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isSubmitting,  bool loadingContactDetails,  bool readingPaneEnabled,  String token,  List<Contact> emails,  Contacts? contact)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ViewContactState() when $default != null:
return $default(_that.isSubmitting,_that.loadingContactDetails,_that.readingPaneEnabled,_that.token,_that.emails,_that.contact);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isSubmitting,  bool loadingContactDetails,  bool readingPaneEnabled,  String token,  List<Contact> emails,  Contacts? contact)  $default,) {final _that = this;
switch (_that) {
case _ViewContactState():
return $default(_that.isSubmitting,_that.loadingContactDetails,_that.readingPaneEnabled,_that.token,_that.emails,_that.contact);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isSubmitting,  bool loadingContactDetails,  bool readingPaneEnabled,  String token,  List<Contact> emails,  Contacts? contact)?  $default,) {final _that = this;
switch (_that) {
case _ViewContactState() when $default != null:
return $default(_that.isSubmitting,_that.loadingContactDetails,_that.readingPaneEnabled,_that.token,_that.emails,_that.contact);case _:
  return null;

}
}

}

/// @nodoc


class _ViewContactState implements ViewContactState {
  const _ViewContactState({this.isSubmitting = false, this.loadingContactDetails = false, this.readingPaneEnabled = false, this.token = '', final  List<Contact> emails = const [], this.contact}): _emails = emails;
  

@override@JsonKey() final  bool isSubmitting;
@override@JsonKey() final  bool loadingContactDetails;
@override@JsonKey() final  bool readingPaneEnabled;
@override@JsonKey() final  String token;
 final  List<Contact> _emails;
@override@JsonKey() List<Contact> get emails {
  if (_emails is EqualUnmodifiableListView) return _emails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_emails);
}

@override final  Contacts? contact;

/// Create a copy of ViewContactState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ViewContactStateCopyWith<_ViewContactState> get copyWith => __$ViewContactStateCopyWithImpl<_ViewContactState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ViewContactState&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.loadingContactDetails, loadingContactDetails) || other.loadingContactDetails == loadingContactDetails)&&(identical(other.readingPaneEnabled, readingPaneEnabled) || other.readingPaneEnabled == readingPaneEnabled)&&(identical(other.token, token) || other.token == token)&&const DeepCollectionEquality().equals(other._emails, _emails)&&(identical(other.contact, contact) || other.contact == contact));
}


@override
int get hashCode => Object.hash(runtimeType,isSubmitting,loadingContactDetails,readingPaneEnabled,token,const DeepCollectionEquality().hash(_emails),contact);

@override
String toString() {
  return 'ViewContactState(isSubmitting: $isSubmitting, loadingContactDetails: $loadingContactDetails, readingPaneEnabled: $readingPaneEnabled, token: $token, emails: $emails, contact: $contact)';
}


}

/// @nodoc
abstract mixin class _$ViewContactStateCopyWith<$Res> implements $ViewContactStateCopyWith<$Res> {
  factory _$ViewContactStateCopyWith(_ViewContactState value, $Res Function(_ViewContactState) _then) = __$ViewContactStateCopyWithImpl;
@override @useResult
$Res call({
 bool isSubmitting, bool loadingContactDetails, bool readingPaneEnabled, String token, List<Contact> emails, Contacts? contact
});




}
/// @nodoc
class __$ViewContactStateCopyWithImpl<$Res>
    implements _$ViewContactStateCopyWith<$Res> {
  __$ViewContactStateCopyWithImpl(this._self, this._then);

  final _ViewContactState _self;
  final $Res Function(_ViewContactState) _then;

/// Create a copy of ViewContactState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isSubmitting = null,Object? loadingContactDetails = null,Object? readingPaneEnabled = null,Object? token = null,Object? emails = null,Object? contact = freezed,}) {
  return _then(_ViewContactState(
isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,loadingContactDetails: null == loadingContactDetails ? _self.loadingContactDetails : loadingContactDetails // ignore: cast_nullable_to_non_nullable
as bool,readingPaneEnabled: null == readingPaneEnabled ? _self.readingPaneEnabled : readingPaneEnabled // ignore: cast_nullable_to_non_nullable
as bool,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,emails: null == emails ? _self._emails : emails // ignore: cast_nullable_to_non_nullable
as List<Contact>,contact: freezed == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as Contacts?,
  ));
}


}

// dart format on
