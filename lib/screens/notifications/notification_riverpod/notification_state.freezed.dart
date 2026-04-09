// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NotificationState {

 List<Notifications> get items; bool get isLoading; int get currentPage; bool get hasMore; int get inboxCount; int get draftCount; int get trashCount; int get archiveCount; String get newNotification; bool get isNewNotification;// Multi-select
 List<int> get selectedNotificationIds; bool get longPressFlag; bool get allNotificationIdsFlag; bool get showCheckboxes; int get lastClickedIndex;
/// Create a copy of NotificationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationStateCopyWith<NotificationState> get copyWith => _$NotificationStateCopyWithImpl<NotificationState>(this as NotificationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationState&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.inboxCount, inboxCount) || other.inboxCount == inboxCount)&&(identical(other.draftCount, draftCount) || other.draftCount == draftCount)&&(identical(other.trashCount, trashCount) || other.trashCount == trashCount)&&(identical(other.archiveCount, archiveCount) || other.archiveCount == archiveCount)&&(identical(other.newNotification, newNotification) || other.newNotification == newNotification)&&(identical(other.isNewNotification, isNewNotification) || other.isNewNotification == isNewNotification)&&const DeepCollectionEquality().equals(other.selectedNotificationIds, selectedNotificationIds)&&(identical(other.longPressFlag, longPressFlag) || other.longPressFlag == longPressFlag)&&(identical(other.allNotificationIdsFlag, allNotificationIdsFlag) || other.allNotificationIdsFlag == allNotificationIdsFlag)&&(identical(other.showCheckboxes, showCheckboxes) || other.showCheckboxes == showCheckboxes)&&(identical(other.lastClickedIndex, lastClickedIndex) || other.lastClickedIndex == lastClickedIndex));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),isLoading,currentPage,hasMore,inboxCount,draftCount,trashCount,archiveCount,newNotification,isNewNotification,const DeepCollectionEquality().hash(selectedNotificationIds),longPressFlag,allNotificationIdsFlag,showCheckboxes,lastClickedIndex);

@override
String toString() {
  return 'NotificationState(items: $items, isLoading: $isLoading, currentPage: $currentPage, hasMore: $hasMore, inboxCount: $inboxCount, draftCount: $draftCount, trashCount: $trashCount, archiveCount: $archiveCount, newNotification: $newNotification, isNewNotification: $isNewNotification, selectedNotificationIds: $selectedNotificationIds, longPressFlag: $longPressFlag, allNotificationIdsFlag: $allNotificationIdsFlag, showCheckboxes: $showCheckboxes, lastClickedIndex: $lastClickedIndex)';
}


}

/// @nodoc
abstract mixin class $NotificationStateCopyWith<$Res>  {
  factory $NotificationStateCopyWith(NotificationState value, $Res Function(NotificationState) _then) = _$NotificationStateCopyWithImpl;
@useResult
$Res call({
 List<Notifications> items, bool isLoading, int currentPage, bool hasMore, int inboxCount, int draftCount, int trashCount, int archiveCount, String newNotification, bool isNewNotification, List<int> selectedNotificationIds, bool longPressFlag, bool allNotificationIdsFlag, bool showCheckboxes, int lastClickedIndex
});




}
/// @nodoc
class _$NotificationStateCopyWithImpl<$Res>
    implements $NotificationStateCopyWith<$Res> {
  _$NotificationStateCopyWithImpl(this._self, this._then);

  final NotificationState _self;
  final $Res Function(NotificationState) _then;

/// Create a copy of NotificationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? isLoading = null,Object? currentPage = null,Object? hasMore = null,Object? inboxCount = null,Object? draftCount = null,Object? trashCount = null,Object? archiveCount = null,Object? newNotification = null,Object? isNewNotification = null,Object? selectedNotificationIds = null,Object? longPressFlag = null,Object? allNotificationIdsFlag = null,Object? showCheckboxes = null,Object? lastClickedIndex = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Notifications>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,inboxCount: null == inboxCount ? _self.inboxCount : inboxCount // ignore: cast_nullable_to_non_nullable
as int,draftCount: null == draftCount ? _self.draftCount : draftCount // ignore: cast_nullable_to_non_nullable
as int,trashCount: null == trashCount ? _self.trashCount : trashCount // ignore: cast_nullable_to_non_nullable
as int,archiveCount: null == archiveCount ? _self.archiveCount : archiveCount // ignore: cast_nullable_to_non_nullable
as int,newNotification: null == newNotification ? _self.newNotification : newNotification // ignore: cast_nullable_to_non_nullable
as String,isNewNotification: null == isNewNotification ? _self.isNewNotification : isNewNotification // ignore: cast_nullable_to_non_nullable
as bool,selectedNotificationIds: null == selectedNotificationIds ? _self.selectedNotificationIds : selectedNotificationIds // ignore: cast_nullable_to_non_nullable
as List<int>,longPressFlag: null == longPressFlag ? _self.longPressFlag : longPressFlag // ignore: cast_nullable_to_non_nullable
as bool,allNotificationIdsFlag: null == allNotificationIdsFlag ? _self.allNotificationIdsFlag : allNotificationIdsFlag // ignore: cast_nullable_to_non_nullable
as bool,showCheckboxes: null == showCheckboxes ? _self.showCheckboxes : showCheckboxes // ignore: cast_nullable_to_non_nullable
as bool,lastClickedIndex: null == lastClickedIndex ? _self.lastClickedIndex : lastClickedIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationState].
extension NotificationStatePatterns on NotificationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationState value)  $default,){
final _that = this;
switch (_that) {
case _NotificationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationState value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Notifications> items,  bool isLoading,  int currentPage,  bool hasMore,  int inboxCount,  int draftCount,  int trashCount,  int archiveCount,  String newNotification,  bool isNewNotification,  List<int> selectedNotificationIds,  bool longPressFlag,  bool allNotificationIdsFlag,  bool showCheckboxes,  int lastClickedIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationState() when $default != null:
return $default(_that.items,_that.isLoading,_that.currentPage,_that.hasMore,_that.inboxCount,_that.draftCount,_that.trashCount,_that.archiveCount,_that.newNotification,_that.isNewNotification,_that.selectedNotificationIds,_that.longPressFlag,_that.allNotificationIdsFlag,_that.showCheckboxes,_that.lastClickedIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Notifications> items,  bool isLoading,  int currentPage,  bool hasMore,  int inboxCount,  int draftCount,  int trashCount,  int archiveCount,  String newNotification,  bool isNewNotification,  List<int> selectedNotificationIds,  bool longPressFlag,  bool allNotificationIdsFlag,  bool showCheckboxes,  int lastClickedIndex)  $default,) {final _that = this;
switch (_that) {
case _NotificationState():
return $default(_that.items,_that.isLoading,_that.currentPage,_that.hasMore,_that.inboxCount,_that.draftCount,_that.trashCount,_that.archiveCount,_that.newNotification,_that.isNewNotification,_that.selectedNotificationIds,_that.longPressFlag,_that.allNotificationIdsFlag,_that.showCheckboxes,_that.lastClickedIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Notifications> items,  bool isLoading,  int currentPage,  bool hasMore,  int inboxCount,  int draftCount,  int trashCount,  int archiveCount,  String newNotification,  bool isNewNotification,  List<int> selectedNotificationIds,  bool longPressFlag,  bool allNotificationIdsFlag,  bool showCheckboxes,  int lastClickedIndex)?  $default,) {final _that = this;
switch (_that) {
case _NotificationState() when $default != null:
return $default(_that.items,_that.isLoading,_that.currentPage,_that.hasMore,_that.inboxCount,_that.draftCount,_that.trashCount,_that.archiveCount,_that.newNotification,_that.isNewNotification,_that.selectedNotificationIds,_that.longPressFlag,_that.allNotificationIdsFlag,_that.showCheckboxes,_that.lastClickedIndex);case _:
  return null;

}
}

}

/// @nodoc


class _NotificationState extends NotificationState {
  const _NotificationState({final  List<Notifications> items = const [], this.isLoading = false, this.currentPage = 1, this.hasMore = true, this.inboxCount = 0, this.draftCount = 0, this.trashCount = 0, this.archiveCount = 0, this.newNotification = "no", this.isNewNotification = false, final  List<int> selectedNotificationIds = const [], this.longPressFlag = true, this.allNotificationIdsFlag = false, this.showCheckboxes = false, this.lastClickedIndex = -1}): _items = items,_selectedNotificationIds = selectedNotificationIds,super._();
  

 final  List<Notifications> _items;
@override@JsonKey() List<Notifications> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  int currentPage;
@override@JsonKey() final  bool hasMore;
@override@JsonKey() final  int inboxCount;
@override@JsonKey() final  int draftCount;
@override@JsonKey() final  int trashCount;
@override@JsonKey() final  int archiveCount;
@override@JsonKey() final  String newNotification;
@override@JsonKey() final  bool isNewNotification;
// Multi-select
 final  List<int> _selectedNotificationIds;
// Multi-select
@override@JsonKey() List<int> get selectedNotificationIds {
  if (_selectedNotificationIds is EqualUnmodifiableListView) return _selectedNotificationIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedNotificationIds);
}

@override@JsonKey() final  bool longPressFlag;
@override@JsonKey() final  bool allNotificationIdsFlag;
@override@JsonKey() final  bool showCheckboxes;
@override@JsonKey() final  int lastClickedIndex;

/// Create a copy of NotificationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationStateCopyWith<_NotificationState> get copyWith => __$NotificationStateCopyWithImpl<_NotificationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationState&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.inboxCount, inboxCount) || other.inboxCount == inboxCount)&&(identical(other.draftCount, draftCount) || other.draftCount == draftCount)&&(identical(other.trashCount, trashCount) || other.trashCount == trashCount)&&(identical(other.archiveCount, archiveCount) || other.archiveCount == archiveCount)&&(identical(other.newNotification, newNotification) || other.newNotification == newNotification)&&(identical(other.isNewNotification, isNewNotification) || other.isNewNotification == isNewNotification)&&const DeepCollectionEquality().equals(other._selectedNotificationIds, _selectedNotificationIds)&&(identical(other.longPressFlag, longPressFlag) || other.longPressFlag == longPressFlag)&&(identical(other.allNotificationIdsFlag, allNotificationIdsFlag) || other.allNotificationIdsFlag == allNotificationIdsFlag)&&(identical(other.showCheckboxes, showCheckboxes) || other.showCheckboxes == showCheckboxes)&&(identical(other.lastClickedIndex, lastClickedIndex) || other.lastClickedIndex == lastClickedIndex));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),isLoading,currentPage,hasMore,inboxCount,draftCount,trashCount,archiveCount,newNotification,isNewNotification,const DeepCollectionEquality().hash(_selectedNotificationIds),longPressFlag,allNotificationIdsFlag,showCheckboxes,lastClickedIndex);

@override
String toString() {
  return 'NotificationState(items: $items, isLoading: $isLoading, currentPage: $currentPage, hasMore: $hasMore, inboxCount: $inboxCount, draftCount: $draftCount, trashCount: $trashCount, archiveCount: $archiveCount, newNotification: $newNotification, isNewNotification: $isNewNotification, selectedNotificationIds: $selectedNotificationIds, longPressFlag: $longPressFlag, allNotificationIdsFlag: $allNotificationIdsFlag, showCheckboxes: $showCheckboxes, lastClickedIndex: $lastClickedIndex)';
}


}

/// @nodoc
abstract mixin class _$NotificationStateCopyWith<$Res> implements $NotificationStateCopyWith<$Res> {
  factory _$NotificationStateCopyWith(_NotificationState value, $Res Function(_NotificationState) _then) = __$NotificationStateCopyWithImpl;
@override @useResult
$Res call({
 List<Notifications> items, bool isLoading, int currentPage, bool hasMore, int inboxCount, int draftCount, int trashCount, int archiveCount, String newNotification, bool isNewNotification, List<int> selectedNotificationIds, bool longPressFlag, bool allNotificationIdsFlag, bool showCheckboxes, int lastClickedIndex
});




}
/// @nodoc
class __$NotificationStateCopyWithImpl<$Res>
    implements _$NotificationStateCopyWith<$Res> {
  __$NotificationStateCopyWithImpl(this._self, this._then);

  final _NotificationState _self;
  final $Res Function(_NotificationState) _then;

/// Create a copy of NotificationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? isLoading = null,Object? currentPage = null,Object? hasMore = null,Object? inboxCount = null,Object? draftCount = null,Object? trashCount = null,Object? archiveCount = null,Object? newNotification = null,Object? isNewNotification = null,Object? selectedNotificationIds = null,Object? longPressFlag = null,Object? allNotificationIdsFlag = null,Object? showCheckboxes = null,Object? lastClickedIndex = null,}) {
  return _then(_NotificationState(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Notifications>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,inboxCount: null == inboxCount ? _self.inboxCount : inboxCount // ignore: cast_nullable_to_non_nullable
as int,draftCount: null == draftCount ? _self.draftCount : draftCount // ignore: cast_nullable_to_non_nullable
as int,trashCount: null == trashCount ? _self.trashCount : trashCount // ignore: cast_nullable_to_non_nullable
as int,archiveCount: null == archiveCount ? _self.archiveCount : archiveCount // ignore: cast_nullable_to_non_nullable
as int,newNotification: null == newNotification ? _self.newNotification : newNotification // ignore: cast_nullable_to_non_nullable
as String,isNewNotification: null == isNewNotification ? _self.isNewNotification : isNewNotification // ignore: cast_nullable_to_non_nullable
as bool,selectedNotificationIds: null == selectedNotificationIds ? _self._selectedNotificationIds : selectedNotificationIds // ignore: cast_nullable_to_non_nullable
as List<int>,longPressFlag: null == longPressFlag ? _self.longPressFlag : longPressFlag // ignore: cast_nullable_to_non_nullable
as bool,allNotificationIdsFlag: null == allNotificationIdsFlag ? _self.allNotificationIdsFlag : allNotificationIdsFlag // ignore: cast_nullable_to_non_nullable
as bool,showCheckboxes: null == showCheckboxes ? _self.showCheckboxes : showCheckboxes // ignore: cast_nullable_to_non_nullable
as bool,lastClickedIndex: null == lastClickedIndex ? _self.lastClickedIndex : lastClickedIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
