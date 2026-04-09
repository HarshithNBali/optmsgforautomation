// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'draft_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DraftState {

// Flags
 bool get isLoading; bool get isFetching; bool get isSearch; bool get longPressFlag; bool get allEmailIdsFlag; bool get showCheckboxes; bool get isComposeHovered;// Lists / data
 List<Emails> get items; List<int> get selectedEmailIds; List<String> get selectedEmails; int get lastClickedIndex;// Pagination
 int get previousPage; int get currentPage; String get searchKey; int get totalEmailCount; String? get emailType;// Reading pane
 bool get readingPaneEnabled; int? get selectedEmailIdForReadingPane; int? get selectedEmailIndex; int? get currentlyViewedEmailId; double? get emailListPaneWidth;// API models
 DraftListModel? get draftList;// User data
 Map<String, dynamic>? get userData; String get token;// Notifications
 bool get newNotification;
/// Create a copy of DraftState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DraftStateCopyWith<DraftState> get copyWith => _$DraftStateCopyWithImpl<DraftState>(this as DraftState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DraftState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isFetching, isFetching) || other.isFetching == isFetching)&&(identical(other.isSearch, isSearch) || other.isSearch == isSearch)&&(identical(other.longPressFlag, longPressFlag) || other.longPressFlag == longPressFlag)&&(identical(other.allEmailIdsFlag, allEmailIdsFlag) || other.allEmailIdsFlag == allEmailIdsFlag)&&(identical(other.showCheckboxes, showCheckboxes) || other.showCheckboxes == showCheckboxes)&&(identical(other.isComposeHovered, isComposeHovered) || other.isComposeHovered == isComposeHovered)&&const DeepCollectionEquality().equals(other.items, items)&&const DeepCollectionEquality().equals(other.selectedEmailIds, selectedEmailIds)&&const DeepCollectionEquality().equals(other.selectedEmails, selectedEmails)&&(identical(other.lastClickedIndex, lastClickedIndex) || other.lastClickedIndex == lastClickedIndex)&&(identical(other.previousPage, previousPage) || other.previousPage == previousPage)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.searchKey, searchKey) || other.searchKey == searchKey)&&(identical(other.totalEmailCount, totalEmailCount) || other.totalEmailCount == totalEmailCount)&&(identical(other.emailType, emailType) || other.emailType == emailType)&&(identical(other.readingPaneEnabled, readingPaneEnabled) || other.readingPaneEnabled == readingPaneEnabled)&&(identical(other.selectedEmailIdForReadingPane, selectedEmailIdForReadingPane) || other.selectedEmailIdForReadingPane == selectedEmailIdForReadingPane)&&(identical(other.selectedEmailIndex, selectedEmailIndex) || other.selectedEmailIndex == selectedEmailIndex)&&(identical(other.currentlyViewedEmailId, currentlyViewedEmailId) || other.currentlyViewedEmailId == currentlyViewedEmailId)&&(identical(other.emailListPaneWidth, emailListPaneWidth) || other.emailListPaneWidth == emailListPaneWidth)&&(identical(other.draftList, draftList) || other.draftList == draftList)&&const DeepCollectionEquality().equals(other.userData, userData)&&(identical(other.token, token) || other.token == token)&&(identical(other.newNotification, newNotification) || other.newNotification == newNotification));
}


@override
int get hashCode => Object.hashAll([runtimeType,isLoading,isFetching,isSearch,longPressFlag,allEmailIdsFlag,showCheckboxes,isComposeHovered,const DeepCollectionEquality().hash(items),const DeepCollectionEquality().hash(selectedEmailIds),const DeepCollectionEquality().hash(selectedEmails),lastClickedIndex,previousPage,currentPage,searchKey,totalEmailCount,emailType,readingPaneEnabled,selectedEmailIdForReadingPane,selectedEmailIndex,currentlyViewedEmailId,emailListPaneWidth,draftList,const DeepCollectionEquality().hash(userData),token,newNotification]);

@override
String toString() {
  return 'DraftState(isLoading: $isLoading, isFetching: $isFetching, isSearch: $isSearch, longPressFlag: $longPressFlag, allEmailIdsFlag: $allEmailIdsFlag, showCheckboxes: $showCheckboxes, isComposeHovered: $isComposeHovered, items: $items, selectedEmailIds: $selectedEmailIds, selectedEmails: $selectedEmails, lastClickedIndex: $lastClickedIndex, previousPage: $previousPage, currentPage: $currentPage, searchKey: $searchKey, totalEmailCount: $totalEmailCount, emailType: $emailType, readingPaneEnabled: $readingPaneEnabled, selectedEmailIdForReadingPane: $selectedEmailIdForReadingPane, selectedEmailIndex: $selectedEmailIndex, currentlyViewedEmailId: $currentlyViewedEmailId, emailListPaneWidth: $emailListPaneWidth, draftList: $draftList, userData: $userData, token: $token, newNotification: $newNotification)';
}


}

/// @nodoc
abstract mixin class $DraftStateCopyWith<$Res>  {
  factory $DraftStateCopyWith(DraftState value, $Res Function(DraftState) _then) = _$DraftStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, bool isFetching, bool isSearch, bool longPressFlag, bool allEmailIdsFlag, bool showCheckboxes, bool isComposeHovered, List<Emails> items, List<int> selectedEmailIds, List<String> selectedEmails, int lastClickedIndex, int previousPage, int currentPage, String searchKey, int totalEmailCount, String? emailType, bool readingPaneEnabled, int? selectedEmailIdForReadingPane, int? selectedEmailIndex, int? currentlyViewedEmailId, double? emailListPaneWidth, DraftListModel? draftList, Map<String, dynamic>? userData, String token, bool newNotification
});




}
/// @nodoc
class _$DraftStateCopyWithImpl<$Res>
    implements $DraftStateCopyWith<$Res> {
  _$DraftStateCopyWithImpl(this._self, this._then);

  final DraftState _self;
  final $Res Function(DraftState) _then;

/// Create a copy of DraftState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? isFetching = null,Object? isSearch = null,Object? longPressFlag = null,Object? allEmailIdsFlag = null,Object? showCheckboxes = null,Object? isComposeHovered = null,Object? items = null,Object? selectedEmailIds = null,Object? selectedEmails = null,Object? lastClickedIndex = null,Object? previousPage = null,Object? currentPage = null,Object? searchKey = null,Object? totalEmailCount = null,Object? emailType = freezed,Object? readingPaneEnabled = null,Object? selectedEmailIdForReadingPane = freezed,Object? selectedEmailIndex = freezed,Object? currentlyViewedEmailId = freezed,Object? emailListPaneWidth = freezed,Object? draftList = freezed,Object? userData = freezed,Object? token = null,Object? newNotification = null,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isFetching: null == isFetching ? _self.isFetching : isFetching // ignore: cast_nullable_to_non_nullable
as bool,isSearch: null == isSearch ? _self.isSearch : isSearch // ignore: cast_nullable_to_non_nullable
as bool,longPressFlag: null == longPressFlag ? _self.longPressFlag : longPressFlag // ignore: cast_nullable_to_non_nullable
as bool,allEmailIdsFlag: null == allEmailIdsFlag ? _self.allEmailIdsFlag : allEmailIdsFlag // ignore: cast_nullable_to_non_nullable
as bool,showCheckboxes: null == showCheckboxes ? _self.showCheckboxes : showCheckboxes // ignore: cast_nullable_to_non_nullable
as bool,isComposeHovered: null == isComposeHovered ? _self.isComposeHovered : isComposeHovered // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Emails>,selectedEmailIds: null == selectedEmailIds ? _self.selectedEmailIds : selectedEmailIds // ignore: cast_nullable_to_non_nullable
as List<int>,selectedEmails: null == selectedEmails ? _self.selectedEmails : selectedEmails // ignore: cast_nullable_to_non_nullable
as List<String>,lastClickedIndex: null == lastClickedIndex ? _self.lastClickedIndex : lastClickedIndex // ignore: cast_nullable_to_non_nullable
as int,previousPage: null == previousPage ? _self.previousPage : previousPage // ignore: cast_nullable_to_non_nullable
as int,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,searchKey: null == searchKey ? _self.searchKey : searchKey // ignore: cast_nullable_to_non_nullable
as String,totalEmailCount: null == totalEmailCount ? _self.totalEmailCount : totalEmailCount // ignore: cast_nullable_to_non_nullable
as int,emailType: freezed == emailType ? _self.emailType : emailType // ignore: cast_nullable_to_non_nullable
as String?,readingPaneEnabled: null == readingPaneEnabled ? _self.readingPaneEnabled : readingPaneEnabled // ignore: cast_nullable_to_non_nullable
as bool,selectedEmailIdForReadingPane: freezed == selectedEmailIdForReadingPane ? _self.selectedEmailIdForReadingPane : selectedEmailIdForReadingPane // ignore: cast_nullable_to_non_nullable
as int?,selectedEmailIndex: freezed == selectedEmailIndex ? _self.selectedEmailIndex : selectedEmailIndex // ignore: cast_nullable_to_non_nullable
as int?,currentlyViewedEmailId: freezed == currentlyViewedEmailId ? _self.currentlyViewedEmailId : currentlyViewedEmailId // ignore: cast_nullable_to_non_nullable
as int?,emailListPaneWidth: freezed == emailListPaneWidth ? _self.emailListPaneWidth : emailListPaneWidth // ignore: cast_nullable_to_non_nullable
as double?,draftList: freezed == draftList ? _self.draftList : draftList // ignore: cast_nullable_to_non_nullable
as DraftListModel?,userData: freezed == userData ? _self.userData : userData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,newNotification: null == newNotification ? _self.newNotification : newNotification // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DraftState].
extension DraftStatePatterns on DraftState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DraftState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DraftState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DraftState value)  $default,){
final _that = this;
switch (_that) {
case _DraftState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DraftState value)?  $default,){
final _that = this;
switch (_that) {
case _DraftState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  bool isFetching,  bool isSearch,  bool longPressFlag,  bool allEmailIdsFlag,  bool showCheckboxes,  bool isComposeHovered,  List<Emails> items,  List<int> selectedEmailIds,  List<String> selectedEmails,  int lastClickedIndex,  int previousPage,  int currentPage,  String searchKey,  int totalEmailCount,  String? emailType,  bool readingPaneEnabled,  int? selectedEmailIdForReadingPane,  int? selectedEmailIndex,  int? currentlyViewedEmailId,  double? emailListPaneWidth,  DraftListModel? draftList,  Map<String, dynamic>? userData,  String token,  bool newNotification)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DraftState() when $default != null:
return $default(_that.isLoading,_that.isFetching,_that.isSearch,_that.longPressFlag,_that.allEmailIdsFlag,_that.showCheckboxes,_that.isComposeHovered,_that.items,_that.selectedEmailIds,_that.selectedEmails,_that.lastClickedIndex,_that.previousPage,_that.currentPage,_that.searchKey,_that.totalEmailCount,_that.emailType,_that.readingPaneEnabled,_that.selectedEmailIdForReadingPane,_that.selectedEmailIndex,_that.currentlyViewedEmailId,_that.emailListPaneWidth,_that.draftList,_that.userData,_that.token,_that.newNotification);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  bool isFetching,  bool isSearch,  bool longPressFlag,  bool allEmailIdsFlag,  bool showCheckboxes,  bool isComposeHovered,  List<Emails> items,  List<int> selectedEmailIds,  List<String> selectedEmails,  int lastClickedIndex,  int previousPage,  int currentPage,  String searchKey,  int totalEmailCount,  String? emailType,  bool readingPaneEnabled,  int? selectedEmailIdForReadingPane,  int? selectedEmailIndex,  int? currentlyViewedEmailId,  double? emailListPaneWidth,  DraftListModel? draftList,  Map<String, dynamic>? userData,  String token,  bool newNotification)  $default,) {final _that = this;
switch (_that) {
case _DraftState():
return $default(_that.isLoading,_that.isFetching,_that.isSearch,_that.longPressFlag,_that.allEmailIdsFlag,_that.showCheckboxes,_that.isComposeHovered,_that.items,_that.selectedEmailIds,_that.selectedEmails,_that.lastClickedIndex,_that.previousPage,_that.currentPage,_that.searchKey,_that.totalEmailCount,_that.emailType,_that.readingPaneEnabled,_that.selectedEmailIdForReadingPane,_that.selectedEmailIndex,_that.currentlyViewedEmailId,_that.emailListPaneWidth,_that.draftList,_that.userData,_that.token,_that.newNotification);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  bool isFetching,  bool isSearch,  bool longPressFlag,  bool allEmailIdsFlag,  bool showCheckboxes,  bool isComposeHovered,  List<Emails> items,  List<int> selectedEmailIds,  List<String> selectedEmails,  int lastClickedIndex,  int previousPage,  int currentPage,  String searchKey,  int totalEmailCount,  String? emailType,  bool readingPaneEnabled,  int? selectedEmailIdForReadingPane,  int? selectedEmailIndex,  int? currentlyViewedEmailId,  double? emailListPaneWidth,  DraftListModel? draftList,  Map<String, dynamic>? userData,  String token,  bool newNotification)?  $default,) {final _that = this;
switch (_that) {
case _DraftState() when $default != null:
return $default(_that.isLoading,_that.isFetching,_that.isSearch,_that.longPressFlag,_that.allEmailIdsFlag,_that.showCheckboxes,_that.isComposeHovered,_that.items,_that.selectedEmailIds,_that.selectedEmails,_that.lastClickedIndex,_that.previousPage,_that.currentPage,_that.searchKey,_that.totalEmailCount,_that.emailType,_that.readingPaneEnabled,_that.selectedEmailIdForReadingPane,_that.selectedEmailIndex,_that.currentlyViewedEmailId,_that.emailListPaneWidth,_that.draftList,_that.userData,_that.token,_that.newNotification);case _:
  return null;

}
}

}

/// @nodoc


class _DraftState extends DraftState {
  const _DraftState({this.isLoading = false, this.isFetching = false, this.isSearch = false, this.longPressFlag = true, this.allEmailIdsFlag = false, this.showCheckboxes = false, this.isComposeHovered = false, final  List<Emails> items = const [], final  List<int> selectedEmailIds = const [], final  List<String> selectedEmails = const [], this.lastClickedIndex = -1, this.previousPage = 0, this.currentPage = 1, this.searchKey = '', this.totalEmailCount = 0, this.emailType = 'draft', this.readingPaneEnabled = false, this.selectedEmailIdForReadingPane, this.selectedEmailIndex, this.currentlyViewedEmailId, this.emailListPaneWidth, this.draftList, final  Map<String, dynamic>? userData, this.token = '', this.newNotification = false}): _items = items,_selectedEmailIds = selectedEmailIds,_selectedEmails = selectedEmails,_userData = userData,super._();
  

// Flags
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isFetching;
@override@JsonKey() final  bool isSearch;
@override@JsonKey() final  bool longPressFlag;
@override@JsonKey() final  bool allEmailIdsFlag;
@override@JsonKey() final  bool showCheckboxes;
@override@JsonKey() final  bool isComposeHovered;
// Lists / data
 final  List<Emails> _items;
// Lists / data
@override@JsonKey() List<Emails> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  List<int> _selectedEmailIds;
@override@JsonKey() List<int> get selectedEmailIds {
  if (_selectedEmailIds is EqualUnmodifiableListView) return _selectedEmailIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedEmailIds);
}

 final  List<String> _selectedEmails;
@override@JsonKey() List<String> get selectedEmails {
  if (_selectedEmails is EqualUnmodifiableListView) return _selectedEmails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedEmails);
}

@override@JsonKey() final  int lastClickedIndex;
// Pagination
@override@JsonKey() final  int previousPage;
@override@JsonKey() final  int currentPage;
@override@JsonKey() final  String searchKey;
@override@JsonKey() final  int totalEmailCount;
@override@JsonKey() final  String? emailType;
// Reading pane
@override@JsonKey() final  bool readingPaneEnabled;
@override final  int? selectedEmailIdForReadingPane;
@override final  int? selectedEmailIndex;
@override final  int? currentlyViewedEmailId;
@override final  double? emailListPaneWidth;
// API models
@override final  DraftListModel? draftList;
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

@override@JsonKey() final  String token;
// Notifications
@override@JsonKey() final  bool newNotification;

/// Create a copy of DraftState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DraftStateCopyWith<_DraftState> get copyWith => __$DraftStateCopyWithImpl<_DraftState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DraftState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isFetching, isFetching) || other.isFetching == isFetching)&&(identical(other.isSearch, isSearch) || other.isSearch == isSearch)&&(identical(other.longPressFlag, longPressFlag) || other.longPressFlag == longPressFlag)&&(identical(other.allEmailIdsFlag, allEmailIdsFlag) || other.allEmailIdsFlag == allEmailIdsFlag)&&(identical(other.showCheckboxes, showCheckboxes) || other.showCheckboxes == showCheckboxes)&&(identical(other.isComposeHovered, isComposeHovered) || other.isComposeHovered == isComposeHovered)&&const DeepCollectionEquality().equals(other._items, _items)&&const DeepCollectionEquality().equals(other._selectedEmailIds, _selectedEmailIds)&&const DeepCollectionEquality().equals(other._selectedEmails, _selectedEmails)&&(identical(other.lastClickedIndex, lastClickedIndex) || other.lastClickedIndex == lastClickedIndex)&&(identical(other.previousPage, previousPage) || other.previousPage == previousPage)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.searchKey, searchKey) || other.searchKey == searchKey)&&(identical(other.totalEmailCount, totalEmailCount) || other.totalEmailCount == totalEmailCount)&&(identical(other.emailType, emailType) || other.emailType == emailType)&&(identical(other.readingPaneEnabled, readingPaneEnabled) || other.readingPaneEnabled == readingPaneEnabled)&&(identical(other.selectedEmailIdForReadingPane, selectedEmailIdForReadingPane) || other.selectedEmailIdForReadingPane == selectedEmailIdForReadingPane)&&(identical(other.selectedEmailIndex, selectedEmailIndex) || other.selectedEmailIndex == selectedEmailIndex)&&(identical(other.currentlyViewedEmailId, currentlyViewedEmailId) || other.currentlyViewedEmailId == currentlyViewedEmailId)&&(identical(other.emailListPaneWidth, emailListPaneWidth) || other.emailListPaneWidth == emailListPaneWidth)&&(identical(other.draftList, draftList) || other.draftList == draftList)&&const DeepCollectionEquality().equals(other._userData, _userData)&&(identical(other.token, token) || other.token == token)&&(identical(other.newNotification, newNotification) || other.newNotification == newNotification));
}


@override
int get hashCode => Object.hashAll([runtimeType,isLoading,isFetching,isSearch,longPressFlag,allEmailIdsFlag,showCheckboxes,isComposeHovered,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_selectedEmailIds),const DeepCollectionEquality().hash(_selectedEmails),lastClickedIndex,previousPage,currentPage,searchKey,totalEmailCount,emailType,readingPaneEnabled,selectedEmailIdForReadingPane,selectedEmailIndex,currentlyViewedEmailId,emailListPaneWidth,draftList,const DeepCollectionEquality().hash(_userData),token,newNotification]);

@override
String toString() {
  return 'DraftState(isLoading: $isLoading, isFetching: $isFetching, isSearch: $isSearch, longPressFlag: $longPressFlag, allEmailIdsFlag: $allEmailIdsFlag, showCheckboxes: $showCheckboxes, isComposeHovered: $isComposeHovered, items: $items, selectedEmailIds: $selectedEmailIds, selectedEmails: $selectedEmails, lastClickedIndex: $lastClickedIndex, previousPage: $previousPage, currentPage: $currentPage, searchKey: $searchKey, totalEmailCount: $totalEmailCount, emailType: $emailType, readingPaneEnabled: $readingPaneEnabled, selectedEmailIdForReadingPane: $selectedEmailIdForReadingPane, selectedEmailIndex: $selectedEmailIndex, currentlyViewedEmailId: $currentlyViewedEmailId, emailListPaneWidth: $emailListPaneWidth, draftList: $draftList, userData: $userData, token: $token, newNotification: $newNotification)';
}


}

/// @nodoc
abstract mixin class _$DraftStateCopyWith<$Res> implements $DraftStateCopyWith<$Res> {
  factory _$DraftStateCopyWith(_DraftState value, $Res Function(_DraftState) _then) = __$DraftStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, bool isFetching, bool isSearch, bool longPressFlag, bool allEmailIdsFlag, bool showCheckboxes, bool isComposeHovered, List<Emails> items, List<int> selectedEmailIds, List<String> selectedEmails, int lastClickedIndex, int previousPage, int currentPage, String searchKey, int totalEmailCount, String? emailType, bool readingPaneEnabled, int? selectedEmailIdForReadingPane, int? selectedEmailIndex, int? currentlyViewedEmailId, double? emailListPaneWidth, DraftListModel? draftList, Map<String, dynamic>? userData, String token, bool newNotification
});




}
/// @nodoc
class __$DraftStateCopyWithImpl<$Res>
    implements _$DraftStateCopyWith<$Res> {
  __$DraftStateCopyWithImpl(this._self, this._then);

  final _DraftState _self;
  final $Res Function(_DraftState) _then;

/// Create a copy of DraftState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? isFetching = null,Object? isSearch = null,Object? longPressFlag = null,Object? allEmailIdsFlag = null,Object? showCheckboxes = null,Object? isComposeHovered = null,Object? items = null,Object? selectedEmailIds = null,Object? selectedEmails = null,Object? lastClickedIndex = null,Object? previousPage = null,Object? currentPage = null,Object? searchKey = null,Object? totalEmailCount = null,Object? emailType = freezed,Object? readingPaneEnabled = null,Object? selectedEmailIdForReadingPane = freezed,Object? selectedEmailIndex = freezed,Object? currentlyViewedEmailId = freezed,Object? emailListPaneWidth = freezed,Object? draftList = freezed,Object? userData = freezed,Object? token = null,Object? newNotification = null,}) {
  return _then(_DraftState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isFetching: null == isFetching ? _self.isFetching : isFetching // ignore: cast_nullable_to_non_nullable
as bool,isSearch: null == isSearch ? _self.isSearch : isSearch // ignore: cast_nullable_to_non_nullable
as bool,longPressFlag: null == longPressFlag ? _self.longPressFlag : longPressFlag // ignore: cast_nullable_to_non_nullable
as bool,allEmailIdsFlag: null == allEmailIdsFlag ? _self.allEmailIdsFlag : allEmailIdsFlag // ignore: cast_nullable_to_non_nullable
as bool,showCheckboxes: null == showCheckboxes ? _self.showCheckboxes : showCheckboxes // ignore: cast_nullable_to_non_nullable
as bool,isComposeHovered: null == isComposeHovered ? _self.isComposeHovered : isComposeHovered // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Emails>,selectedEmailIds: null == selectedEmailIds ? _self._selectedEmailIds : selectedEmailIds // ignore: cast_nullable_to_non_nullable
as List<int>,selectedEmails: null == selectedEmails ? _self._selectedEmails : selectedEmails // ignore: cast_nullable_to_non_nullable
as List<String>,lastClickedIndex: null == lastClickedIndex ? _self.lastClickedIndex : lastClickedIndex // ignore: cast_nullable_to_non_nullable
as int,previousPage: null == previousPage ? _self.previousPage : previousPage // ignore: cast_nullable_to_non_nullable
as int,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,searchKey: null == searchKey ? _self.searchKey : searchKey // ignore: cast_nullable_to_non_nullable
as String,totalEmailCount: null == totalEmailCount ? _self.totalEmailCount : totalEmailCount // ignore: cast_nullable_to_non_nullable
as int,emailType: freezed == emailType ? _self.emailType : emailType // ignore: cast_nullable_to_non_nullable
as String?,readingPaneEnabled: null == readingPaneEnabled ? _self.readingPaneEnabled : readingPaneEnabled // ignore: cast_nullable_to_non_nullable
as bool,selectedEmailIdForReadingPane: freezed == selectedEmailIdForReadingPane ? _self.selectedEmailIdForReadingPane : selectedEmailIdForReadingPane // ignore: cast_nullable_to_non_nullable
as int?,selectedEmailIndex: freezed == selectedEmailIndex ? _self.selectedEmailIndex : selectedEmailIndex // ignore: cast_nullable_to_non_nullable
as int?,currentlyViewedEmailId: freezed == currentlyViewedEmailId ? _self.currentlyViewedEmailId : currentlyViewedEmailId // ignore: cast_nullable_to_non_nullable
as int?,emailListPaneWidth: freezed == emailListPaneWidth ? _self.emailListPaneWidth : emailListPaneWidth // ignore: cast_nullable_to_non_nullable
as double?,draftList: freezed == draftList ? _self.draftList : draftList // ignore: cast_nullable_to_non_nullable
as DraftListModel?,userData: freezed == userData ? _self._userData : userData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,newNotification: null == newNotification ? _self.newNotification : newNotification // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
