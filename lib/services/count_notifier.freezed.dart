// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'count_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CountState implements DiagnosticableTreeMixin {

 int get inboxCount; int get draftCount; int get archiveCount; int get trashCount; bool get isUpdateDialogVisible; bool get isUpdatePopUpDismiss; String get newNotification;
/// Create a copy of CountState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CountStateCopyWith<CountState> get copyWith => _$CountStateCopyWithImpl<CountState>(this as CountState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CountState'))
    ..add(DiagnosticsProperty('inboxCount', inboxCount))..add(DiagnosticsProperty('draftCount', draftCount))..add(DiagnosticsProperty('archiveCount', archiveCount))..add(DiagnosticsProperty('trashCount', trashCount))..add(DiagnosticsProperty('isUpdateDialogVisible', isUpdateDialogVisible))..add(DiagnosticsProperty('isUpdatePopUpDismiss', isUpdatePopUpDismiss))..add(DiagnosticsProperty('newNotification', newNotification));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CountState&&(identical(other.inboxCount, inboxCount) || other.inboxCount == inboxCount)&&(identical(other.draftCount, draftCount) || other.draftCount == draftCount)&&(identical(other.archiveCount, archiveCount) || other.archiveCount == archiveCount)&&(identical(other.trashCount, trashCount) || other.trashCount == trashCount)&&(identical(other.isUpdateDialogVisible, isUpdateDialogVisible) || other.isUpdateDialogVisible == isUpdateDialogVisible)&&(identical(other.isUpdatePopUpDismiss, isUpdatePopUpDismiss) || other.isUpdatePopUpDismiss == isUpdatePopUpDismiss)&&(identical(other.newNotification, newNotification) || other.newNotification == newNotification));
}


@override
int get hashCode => Object.hash(runtimeType,inboxCount,draftCount,archiveCount,trashCount,isUpdateDialogVisible,isUpdatePopUpDismiss,newNotification);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CountState(inboxCount: $inboxCount, draftCount: $draftCount, archiveCount: $archiveCount, trashCount: $trashCount, isUpdateDialogVisible: $isUpdateDialogVisible, isUpdatePopUpDismiss: $isUpdatePopUpDismiss, newNotification: $newNotification)';
}


}

/// @nodoc
abstract mixin class $CountStateCopyWith<$Res>  {
  factory $CountStateCopyWith(CountState value, $Res Function(CountState) _then) = _$CountStateCopyWithImpl;
@useResult
$Res call({
 int inboxCount, int draftCount, int archiveCount, int trashCount, bool isUpdateDialogVisible, bool isUpdatePopUpDismiss, String newNotification
});




}
/// @nodoc
class _$CountStateCopyWithImpl<$Res>
    implements $CountStateCopyWith<$Res> {
  _$CountStateCopyWithImpl(this._self, this._then);

  final CountState _self;
  final $Res Function(CountState) _then;

/// Create a copy of CountState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? inboxCount = null,Object? draftCount = null,Object? archiveCount = null,Object? trashCount = null,Object? isUpdateDialogVisible = null,Object? isUpdatePopUpDismiss = null,Object? newNotification = null,}) {
  return _then(_self.copyWith(
inboxCount: null == inboxCount ? _self.inboxCount : inboxCount // ignore: cast_nullable_to_non_nullable
as int,draftCount: null == draftCount ? _self.draftCount : draftCount // ignore: cast_nullable_to_non_nullable
as int,archiveCount: null == archiveCount ? _self.archiveCount : archiveCount // ignore: cast_nullable_to_non_nullable
as int,trashCount: null == trashCount ? _self.trashCount : trashCount // ignore: cast_nullable_to_non_nullable
as int,isUpdateDialogVisible: null == isUpdateDialogVisible ? _self.isUpdateDialogVisible : isUpdateDialogVisible // ignore: cast_nullable_to_non_nullable
as bool,isUpdatePopUpDismiss: null == isUpdatePopUpDismiss ? _self.isUpdatePopUpDismiss : isUpdatePopUpDismiss // ignore: cast_nullable_to_non_nullable
as bool,newNotification: null == newNotification ? _self.newNotification : newNotification // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CountState].
extension CountStatePatterns on CountState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CountState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CountState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CountState value)  $default,){
final _that = this;
switch (_that) {
case _CountState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CountState value)?  $default,){
final _that = this;
switch (_that) {
case _CountState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int inboxCount,  int draftCount,  int archiveCount,  int trashCount,  bool isUpdateDialogVisible,  bool isUpdatePopUpDismiss,  String newNotification)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CountState() when $default != null:
return $default(_that.inboxCount,_that.draftCount,_that.archiveCount,_that.trashCount,_that.isUpdateDialogVisible,_that.isUpdatePopUpDismiss,_that.newNotification);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int inboxCount,  int draftCount,  int archiveCount,  int trashCount,  bool isUpdateDialogVisible,  bool isUpdatePopUpDismiss,  String newNotification)  $default,) {final _that = this;
switch (_that) {
case _CountState():
return $default(_that.inboxCount,_that.draftCount,_that.archiveCount,_that.trashCount,_that.isUpdateDialogVisible,_that.isUpdatePopUpDismiss,_that.newNotification);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int inboxCount,  int draftCount,  int archiveCount,  int trashCount,  bool isUpdateDialogVisible,  bool isUpdatePopUpDismiss,  String newNotification)?  $default,) {final _that = this;
switch (_that) {
case _CountState() when $default != null:
return $default(_that.inboxCount,_that.draftCount,_that.archiveCount,_that.trashCount,_that.isUpdateDialogVisible,_that.isUpdatePopUpDismiss,_that.newNotification);case _:
  return null;

}
}

}

/// @nodoc


class _CountState with DiagnosticableTreeMixin implements CountState {
  const _CountState({this.inboxCount = 0, this.draftCount = 0, this.archiveCount = 0, this.trashCount = 0, this.isUpdateDialogVisible = false, this.isUpdatePopUpDismiss = false, this.newNotification = "no"});
  

@override@JsonKey() final  int inboxCount;
@override@JsonKey() final  int draftCount;
@override@JsonKey() final  int archiveCount;
@override@JsonKey() final  int trashCount;
@override@JsonKey() final  bool isUpdateDialogVisible;
@override@JsonKey() final  bool isUpdatePopUpDismiss;
@override@JsonKey() final  String newNotification;

/// Create a copy of CountState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CountStateCopyWith<_CountState> get copyWith => __$CountStateCopyWithImpl<_CountState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CountState'))
    ..add(DiagnosticsProperty('inboxCount', inboxCount))..add(DiagnosticsProperty('draftCount', draftCount))..add(DiagnosticsProperty('archiveCount', archiveCount))..add(DiagnosticsProperty('trashCount', trashCount))..add(DiagnosticsProperty('isUpdateDialogVisible', isUpdateDialogVisible))..add(DiagnosticsProperty('isUpdatePopUpDismiss', isUpdatePopUpDismiss))..add(DiagnosticsProperty('newNotification', newNotification));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CountState&&(identical(other.inboxCount, inboxCount) || other.inboxCount == inboxCount)&&(identical(other.draftCount, draftCount) || other.draftCount == draftCount)&&(identical(other.archiveCount, archiveCount) || other.archiveCount == archiveCount)&&(identical(other.trashCount, trashCount) || other.trashCount == trashCount)&&(identical(other.isUpdateDialogVisible, isUpdateDialogVisible) || other.isUpdateDialogVisible == isUpdateDialogVisible)&&(identical(other.isUpdatePopUpDismiss, isUpdatePopUpDismiss) || other.isUpdatePopUpDismiss == isUpdatePopUpDismiss)&&(identical(other.newNotification, newNotification) || other.newNotification == newNotification));
}


@override
int get hashCode => Object.hash(runtimeType,inboxCount,draftCount,archiveCount,trashCount,isUpdateDialogVisible,isUpdatePopUpDismiss,newNotification);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CountState(inboxCount: $inboxCount, draftCount: $draftCount, archiveCount: $archiveCount, trashCount: $trashCount, isUpdateDialogVisible: $isUpdateDialogVisible, isUpdatePopUpDismiss: $isUpdatePopUpDismiss, newNotification: $newNotification)';
}


}

/// @nodoc
abstract mixin class _$CountStateCopyWith<$Res> implements $CountStateCopyWith<$Res> {
  factory _$CountStateCopyWith(_CountState value, $Res Function(_CountState) _then) = __$CountStateCopyWithImpl;
@override @useResult
$Res call({
 int inboxCount, int draftCount, int archiveCount, int trashCount, bool isUpdateDialogVisible, bool isUpdatePopUpDismiss, String newNotification
});




}
/// @nodoc
class __$CountStateCopyWithImpl<$Res>
    implements _$CountStateCopyWith<$Res> {
  __$CountStateCopyWithImpl(this._self, this._then);

  final _CountState _self;
  final $Res Function(_CountState) _then;

/// Create a copy of CountState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? inboxCount = null,Object? draftCount = null,Object? archiveCount = null,Object? trashCount = null,Object? isUpdateDialogVisible = null,Object? isUpdatePopUpDismiss = null,Object? newNotification = null,}) {
  return _then(_CountState(
inboxCount: null == inboxCount ? _self.inboxCount : inboxCount // ignore: cast_nullable_to_non_nullable
as int,draftCount: null == draftCount ? _self.draftCount : draftCount // ignore: cast_nullable_to_non_nullable
as int,archiveCount: null == archiveCount ? _self.archiveCount : archiveCount // ignore: cast_nullable_to_non_nullable
as int,trashCount: null == trashCount ? _self.trashCount : trashCount // ignore: cast_nullable_to_non_nullable
as int,isUpdateDialogVisible: null == isUpdateDialogVisible ? _self.isUpdateDialogVisible : isUpdateDialogVisible // ignore: cast_nullable_to_non_nullable
as bool,isUpdatePopUpDismiss: null == isUpdatePopUpDismiss ? _self.isUpdatePopUpDismiss : isUpdatePopUpDismiss // ignore: cast_nullable_to_non_nullable
as bool,newNotification: null == newNotification ? _self.newNotification : newNotification // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
