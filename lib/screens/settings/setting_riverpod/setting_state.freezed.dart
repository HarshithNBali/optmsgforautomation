// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'setting_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsState {

// User data
 Map<String, dynamic>? get userData;// Flags
 bool get isLoading; bool get isNotificationSelected; bool get isBiometricSelected; bool get lastNameSorted; bool get syncContact; bool get readingPaneEnabled;/// Theme mode: 'system' (default), 'light', or 'dark'.
 String get themeModePref; bool get showLogoutDialog;
/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsStateCopyWith<SettingsState> get copyWith => _$SettingsStateCopyWithImpl<SettingsState>(this as SettingsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsState&&const DeepCollectionEquality().equals(other.userData, userData)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isNotificationSelected, isNotificationSelected) || other.isNotificationSelected == isNotificationSelected)&&(identical(other.isBiometricSelected, isBiometricSelected) || other.isBiometricSelected == isBiometricSelected)&&(identical(other.lastNameSorted, lastNameSorted) || other.lastNameSorted == lastNameSorted)&&(identical(other.syncContact, syncContact) || other.syncContact == syncContact)&&(identical(other.readingPaneEnabled, readingPaneEnabled) || other.readingPaneEnabled == readingPaneEnabled)&&(identical(other.themeModePref, themeModePref) || other.themeModePref == themeModePref)&&(identical(other.showLogoutDialog, showLogoutDialog) || other.showLogoutDialog == showLogoutDialog));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(userData),isLoading,isNotificationSelected,isBiometricSelected,lastNameSorted,syncContact,readingPaneEnabled,themeModePref,showLogoutDialog);

@override
String toString() {
  return 'SettingsState(userData: $userData, isLoading: $isLoading, isNotificationSelected: $isNotificationSelected, isBiometricSelected: $isBiometricSelected, lastNameSorted: $lastNameSorted, syncContact: $syncContact, readingPaneEnabled: $readingPaneEnabled, themeModePref: $themeModePref, showLogoutDialog: $showLogoutDialog)';
}


}

/// @nodoc
abstract mixin class $SettingsStateCopyWith<$Res>  {
  factory $SettingsStateCopyWith(SettingsState value, $Res Function(SettingsState) _then) = _$SettingsStateCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic>? userData, bool isLoading, bool isNotificationSelected, bool isBiometricSelected, bool lastNameSorted, bool syncContact, bool readingPaneEnabled, String themeModePref, bool showLogoutDialog
});




}
/// @nodoc
class _$SettingsStateCopyWithImpl<$Res>
    implements $SettingsStateCopyWith<$Res> {
  _$SettingsStateCopyWithImpl(this._self, this._then);

  final SettingsState _self;
  final $Res Function(SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userData = freezed,Object? isLoading = null,Object? isNotificationSelected = null,Object? isBiometricSelected = null,Object? lastNameSorted = null,Object? syncContact = null,Object? readingPaneEnabled = null,Object? themeModePref = null,Object? showLogoutDialog = null,}) {
  return _then(_self.copyWith(
userData: freezed == userData ? _self.userData : userData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isNotificationSelected: null == isNotificationSelected ? _self.isNotificationSelected : isNotificationSelected // ignore: cast_nullable_to_non_nullable
as bool,isBiometricSelected: null == isBiometricSelected ? _self.isBiometricSelected : isBiometricSelected // ignore: cast_nullable_to_non_nullable
as bool,lastNameSorted: null == lastNameSorted ? _self.lastNameSorted : lastNameSorted // ignore: cast_nullable_to_non_nullable
as bool,syncContact: null == syncContact ? _self.syncContact : syncContact // ignore: cast_nullable_to_non_nullable
as bool,readingPaneEnabled: null == readingPaneEnabled ? _self.readingPaneEnabled : readingPaneEnabled // ignore: cast_nullable_to_non_nullable
as bool,themeModePref: null == themeModePref ? _self.themeModePref : themeModePref // ignore: cast_nullable_to_non_nullable
as String,showLogoutDialog: null == showLogoutDialog ? _self.showLogoutDialog : showLogoutDialog // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SettingsState].
extension SettingsStatePatterns on SettingsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettingsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettingsState value)  $default,){
final _that = this;
switch (_that) {
case _SettingsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettingsState value)?  $default,){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, dynamic>? userData,  bool isLoading,  bool isNotificationSelected,  bool isBiometricSelected,  bool lastNameSorted,  bool syncContact,  bool readingPaneEnabled,  String themeModePref,  bool showLogoutDialog)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.userData,_that.isLoading,_that.isNotificationSelected,_that.isBiometricSelected,_that.lastNameSorted,_that.syncContact,_that.readingPaneEnabled,_that.themeModePref,_that.showLogoutDialog);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, dynamic>? userData,  bool isLoading,  bool isNotificationSelected,  bool isBiometricSelected,  bool lastNameSorted,  bool syncContact,  bool readingPaneEnabled,  String themeModePref,  bool showLogoutDialog)  $default,) {final _that = this;
switch (_that) {
case _SettingsState():
return $default(_that.userData,_that.isLoading,_that.isNotificationSelected,_that.isBiometricSelected,_that.lastNameSorted,_that.syncContact,_that.readingPaneEnabled,_that.themeModePref,_that.showLogoutDialog);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, dynamic>? userData,  bool isLoading,  bool isNotificationSelected,  bool isBiometricSelected,  bool lastNameSorted,  bool syncContact,  bool readingPaneEnabled,  String themeModePref,  bool showLogoutDialog)?  $default,) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.userData,_that.isLoading,_that.isNotificationSelected,_that.isBiometricSelected,_that.lastNameSorted,_that.syncContact,_that.readingPaneEnabled,_that.themeModePref,_that.showLogoutDialog);case _:
  return null;

}
}

}

/// @nodoc


class _SettingsState extends SettingsState {
  const _SettingsState({final  Map<String, dynamic>? userData, this.isLoading = false, this.isNotificationSelected = true, this.isBiometricSelected = false, this.lastNameSorted = true, this.syncContact = true, this.readingPaneEnabled = true, this.themeModePref = 'system', this.showLogoutDialog = false}): _userData = userData,super._();
  

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

// Flags
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isNotificationSelected;
@override@JsonKey() final  bool isBiometricSelected;
@override@JsonKey() final  bool lastNameSorted;
@override@JsonKey() final  bool syncContact;
@override@JsonKey() final  bool readingPaneEnabled;
/// Theme mode: 'system' (default), 'light', or 'dark'.
@override@JsonKey() final  String themeModePref;
@override@JsonKey() final  bool showLogoutDialog;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsStateCopyWith<_SettingsState> get copyWith => __$SettingsStateCopyWithImpl<_SettingsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingsState&&const DeepCollectionEquality().equals(other._userData, _userData)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isNotificationSelected, isNotificationSelected) || other.isNotificationSelected == isNotificationSelected)&&(identical(other.isBiometricSelected, isBiometricSelected) || other.isBiometricSelected == isBiometricSelected)&&(identical(other.lastNameSorted, lastNameSorted) || other.lastNameSorted == lastNameSorted)&&(identical(other.syncContact, syncContact) || other.syncContact == syncContact)&&(identical(other.readingPaneEnabled, readingPaneEnabled) || other.readingPaneEnabled == readingPaneEnabled)&&(identical(other.themeModePref, themeModePref) || other.themeModePref == themeModePref)&&(identical(other.showLogoutDialog, showLogoutDialog) || other.showLogoutDialog == showLogoutDialog));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_userData),isLoading,isNotificationSelected,isBiometricSelected,lastNameSorted,syncContact,readingPaneEnabled,themeModePref,showLogoutDialog);

@override
String toString() {
  return 'SettingsState(userData: $userData, isLoading: $isLoading, isNotificationSelected: $isNotificationSelected, isBiometricSelected: $isBiometricSelected, lastNameSorted: $lastNameSorted, syncContact: $syncContact, readingPaneEnabled: $readingPaneEnabled, themeModePref: $themeModePref, showLogoutDialog: $showLogoutDialog)';
}


}

/// @nodoc
abstract mixin class _$SettingsStateCopyWith<$Res> implements $SettingsStateCopyWith<$Res> {
  factory _$SettingsStateCopyWith(_SettingsState value, $Res Function(_SettingsState) _then) = __$SettingsStateCopyWithImpl;
@override @useResult
$Res call({
 Map<String, dynamic>? userData, bool isLoading, bool isNotificationSelected, bool isBiometricSelected, bool lastNameSorted, bool syncContact, bool readingPaneEnabled, String themeModePref, bool showLogoutDialog
});




}
/// @nodoc
class __$SettingsStateCopyWithImpl<$Res>
    implements _$SettingsStateCopyWith<$Res> {
  __$SettingsStateCopyWithImpl(this._self, this._then);

  final _SettingsState _self;
  final $Res Function(_SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userData = freezed,Object? isLoading = null,Object? isNotificationSelected = null,Object? isBiometricSelected = null,Object? lastNameSorted = null,Object? syncContact = null,Object? readingPaneEnabled = null,Object? themeModePref = null,Object? showLogoutDialog = null,}) {
  return _then(_SettingsState(
userData: freezed == userData ? _self._userData : userData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isNotificationSelected: null == isNotificationSelected ? _self.isNotificationSelected : isNotificationSelected // ignore: cast_nullable_to_non_nullable
as bool,isBiometricSelected: null == isBiometricSelected ? _self.isBiometricSelected : isBiometricSelected // ignore: cast_nullable_to_non_nullable
as bool,lastNameSorted: null == lastNameSorted ? _self.lastNameSorted : lastNameSorted // ignore: cast_nullable_to_non_nullable
as bool,syncContact: null == syncContact ? _self.syncContact : syncContact // ignore: cast_nullable_to_non_nullable
as bool,readingPaneEnabled: null == readingPaneEnabled ? _self.readingPaneEnabled : readingPaneEnabled // ignore: cast_nullable_to_non_nullable
as bool,themeModePref: null == themeModePref ? _self.themeModePref : themeModePref // ignore: cast_nullable_to_non_nullable
as String,showLogoutDialog: null == showLogoutDialog ? _self.showLogoutDialog : showLogoutDialog // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
