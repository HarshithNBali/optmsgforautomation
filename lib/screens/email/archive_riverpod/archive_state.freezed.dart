// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'archive_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ArchiveState {

// Flags
 bool get isLoading; bool get isFetching; bool get isSearch; bool get showFilter; bool get showTagList; bool get longPressFlag; bool get allEmailIdsFlag; bool get tagFilter; bool get showCheckboxes; bool get showMenuOptions; bool get showMoveOverlay; bool get readingPaneEnabled; bool get showReadingPaneMenuOptions; bool get allEmailsTrue; bool get isInProcess;// Lists / data
 List<Emails> get items; List<int> get selectedEmailIds; List<String> get selectedEmails; int get lastClickedIndex; List<int> get tagIdFilter; List<int> get selectedTagIds;// Pagination
 int get previousPage; int get currentPage; int get totalEmailCount; int get selectedIndex;// Filters / search
 String get searchKey; String? get emailType; String? get currentPath; String get communityEmail;// Reading pane
 int? get selectedEmailIdForReadingPane; TagsListModel? get selectedEmailTags; int? get selectedEmailIndex; String? get selectedEmailSender; int get readingPaneRefreshKey; double? get emailListPaneWidth;// API models
 SentListModel? get inboxList; bool get isComposeHovered;// Notification
 bool get newNotification;
/// Create a copy of ArchiveState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArchiveStateCopyWith<ArchiveState> get copyWith => _$ArchiveStateCopyWithImpl<ArchiveState>(this as ArchiveState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ArchiveState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isFetching, isFetching) || other.isFetching == isFetching)&&(identical(other.isSearch, isSearch) || other.isSearch == isSearch)&&(identical(other.showFilter, showFilter) || other.showFilter == showFilter)&&(identical(other.showTagList, showTagList) || other.showTagList == showTagList)&&(identical(other.longPressFlag, longPressFlag) || other.longPressFlag == longPressFlag)&&(identical(other.allEmailIdsFlag, allEmailIdsFlag) || other.allEmailIdsFlag == allEmailIdsFlag)&&(identical(other.tagFilter, tagFilter) || other.tagFilter == tagFilter)&&(identical(other.showCheckboxes, showCheckboxes) || other.showCheckboxes == showCheckboxes)&&(identical(other.showMenuOptions, showMenuOptions) || other.showMenuOptions == showMenuOptions)&&(identical(other.showMoveOverlay, showMoveOverlay) || other.showMoveOverlay == showMoveOverlay)&&(identical(other.readingPaneEnabled, readingPaneEnabled) || other.readingPaneEnabled == readingPaneEnabled)&&(identical(other.showReadingPaneMenuOptions, showReadingPaneMenuOptions) || other.showReadingPaneMenuOptions == showReadingPaneMenuOptions)&&(identical(other.allEmailsTrue, allEmailsTrue) || other.allEmailsTrue == allEmailsTrue)&&(identical(other.isInProcess, isInProcess) || other.isInProcess == isInProcess)&&const DeepCollectionEquality().equals(other.items, items)&&const DeepCollectionEquality().equals(other.selectedEmailIds, selectedEmailIds)&&const DeepCollectionEquality().equals(other.selectedEmails, selectedEmails)&&(identical(other.lastClickedIndex, lastClickedIndex) || other.lastClickedIndex == lastClickedIndex)&&const DeepCollectionEquality().equals(other.tagIdFilter, tagIdFilter)&&const DeepCollectionEquality().equals(other.selectedTagIds, selectedTagIds)&&(identical(other.previousPage, previousPage) || other.previousPage == previousPage)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.totalEmailCount, totalEmailCount) || other.totalEmailCount == totalEmailCount)&&(identical(other.selectedIndex, selectedIndex) || other.selectedIndex == selectedIndex)&&(identical(other.searchKey, searchKey) || other.searchKey == searchKey)&&(identical(other.emailType, emailType) || other.emailType == emailType)&&(identical(other.currentPath, currentPath) || other.currentPath == currentPath)&&(identical(other.communityEmail, communityEmail) || other.communityEmail == communityEmail)&&(identical(other.selectedEmailIdForReadingPane, selectedEmailIdForReadingPane) || other.selectedEmailIdForReadingPane == selectedEmailIdForReadingPane)&&(identical(other.selectedEmailTags, selectedEmailTags) || other.selectedEmailTags == selectedEmailTags)&&(identical(other.selectedEmailIndex, selectedEmailIndex) || other.selectedEmailIndex == selectedEmailIndex)&&(identical(other.selectedEmailSender, selectedEmailSender) || other.selectedEmailSender == selectedEmailSender)&&(identical(other.readingPaneRefreshKey, readingPaneRefreshKey) || other.readingPaneRefreshKey == readingPaneRefreshKey)&&(identical(other.emailListPaneWidth, emailListPaneWidth) || other.emailListPaneWidth == emailListPaneWidth)&&(identical(other.inboxList, inboxList) || other.inboxList == inboxList)&&(identical(other.isComposeHovered, isComposeHovered) || other.isComposeHovered == isComposeHovered)&&(identical(other.newNotification, newNotification) || other.newNotification == newNotification));
}


@override
int get hashCode => Object.hashAll([runtimeType,isLoading,isFetching,isSearch,showFilter,showTagList,longPressFlag,allEmailIdsFlag,tagFilter,showCheckboxes,showMenuOptions,showMoveOverlay,readingPaneEnabled,showReadingPaneMenuOptions,allEmailsTrue,isInProcess,const DeepCollectionEquality().hash(items),const DeepCollectionEquality().hash(selectedEmailIds),const DeepCollectionEquality().hash(selectedEmails),lastClickedIndex,const DeepCollectionEquality().hash(tagIdFilter),const DeepCollectionEquality().hash(selectedTagIds),previousPage,currentPage,totalEmailCount,selectedIndex,searchKey,emailType,currentPath,communityEmail,selectedEmailIdForReadingPane,selectedEmailTags,selectedEmailIndex,selectedEmailSender,readingPaneRefreshKey,emailListPaneWidth,inboxList,isComposeHovered,newNotification]);

@override
String toString() {
  return 'ArchiveState(isLoading: $isLoading, isFetching: $isFetching, isSearch: $isSearch, showFilter: $showFilter, showTagList: $showTagList, longPressFlag: $longPressFlag, allEmailIdsFlag: $allEmailIdsFlag, tagFilter: $tagFilter, showCheckboxes: $showCheckboxes, showMenuOptions: $showMenuOptions, showMoveOverlay: $showMoveOverlay, readingPaneEnabled: $readingPaneEnabled, showReadingPaneMenuOptions: $showReadingPaneMenuOptions, allEmailsTrue: $allEmailsTrue, isInProcess: $isInProcess, items: $items, selectedEmailIds: $selectedEmailIds, selectedEmails: $selectedEmails, lastClickedIndex: $lastClickedIndex, tagIdFilter: $tagIdFilter, selectedTagIds: $selectedTagIds, previousPage: $previousPage, currentPage: $currentPage, totalEmailCount: $totalEmailCount, selectedIndex: $selectedIndex, searchKey: $searchKey, emailType: $emailType, currentPath: $currentPath, communityEmail: $communityEmail, selectedEmailIdForReadingPane: $selectedEmailIdForReadingPane, selectedEmailTags: $selectedEmailTags, selectedEmailIndex: $selectedEmailIndex, selectedEmailSender: $selectedEmailSender, readingPaneRefreshKey: $readingPaneRefreshKey, emailListPaneWidth: $emailListPaneWidth, inboxList: $inboxList, isComposeHovered: $isComposeHovered, newNotification: $newNotification)';
}


}

/// @nodoc
abstract mixin class $ArchiveStateCopyWith<$Res>  {
  factory $ArchiveStateCopyWith(ArchiveState value, $Res Function(ArchiveState) _then) = _$ArchiveStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, bool isFetching, bool isSearch, bool showFilter, bool showTagList, bool longPressFlag, bool allEmailIdsFlag, bool tagFilter, bool showCheckboxes, bool showMenuOptions, bool showMoveOverlay, bool readingPaneEnabled, bool showReadingPaneMenuOptions, bool allEmailsTrue, bool isInProcess, List<Emails> items, List<int> selectedEmailIds, List<String> selectedEmails, int lastClickedIndex, List<int> tagIdFilter, List<int> selectedTagIds, int previousPage, int currentPage, int totalEmailCount, int selectedIndex, String searchKey, String? emailType, String? currentPath, String communityEmail, int? selectedEmailIdForReadingPane, TagsListModel? selectedEmailTags, int? selectedEmailIndex, String? selectedEmailSender, int readingPaneRefreshKey, double? emailListPaneWidth, SentListModel? inboxList, bool isComposeHovered, bool newNotification
});




}
/// @nodoc
class _$ArchiveStateCopyWithImpl<$Res>
    implements $ArchiveStateCopyWith<$Res> {
  _$ArchiveStateCopyWithImpl(this._self, this._then);

  final ArchiveState _self;
  final $Res Function(ArchiveState) _then;

/// Create a copy of ArchiveState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? isFetching = null,Object? isSearch = null,Object? showFilter = null,Object? showTagList = null,Object? longPressFlag = null,Object? allEmailIdsFlag = null,Object? tagFilter = null,Object? showCheckboxes = null,Object? showMenuOptions = null,Object? showMoveOverlay = null,Object? readingPaneEnabled = null,Object? showReadingPaneMenuOptions = null,Object? allEmailsTrue = null,Object? isInProcess = null,Object? items = null,Object? selectedEmailIds = null,Object? selectedEmails = null,Object? lastClickedIndex = null,Object? tagIdFilter = null,Object? selectedTagIds = null,Object? previousPage = null,Object? currentPage = null,Object? totalEmailCount = null,Object? selectedIndex = null,Object? searchKey = null,Object? emailType = freezed,Object? currentPath = freezed,Object? communityEmail = null,Object? selectedEmailIdForReadingPane = freezed,Object? selectedEmailTags = freezed,Object? selectedEmailIndex = freezed,Object? selectedEmailSender = freezed,Object? readingPaneRefreshKey = null,Object? emailListPaneWidth = freezed,Object? inboxList = freezed,Object? isComposeHovered = null,Object? newNotification = null,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isFetching: null == isFetching ? _self.isFetching : isFetching // ignore: cast_nullable_to_non_nullable
as bool,isSearch: null == isSearch ? _self.isSearch : isSearch // ignore: cast_nullable_to_non_nullable
as bool,showFilter: null == showFilter ? _self.showFilter : showFilter // ignore: cast_nullable_to_non_nullable
as bool,showTagList: null == showTagList ? _self.showTagList : showTagList // ignore: cast_nullable_to_non_nullable
as bool,longPressFlag: null == longPressFlag ? _self.longPressFlag : longPressFlag // ignore: cast_nullable_to_non_nullable
as bool,allEmailIdsFlag: null == allEmailIdsFlag ? _self.allEmailIdsFlag : allEmailIdsFlag // ignore: cast_nullable_to_non_nullable
as bool,tagFilter: null == tagFilter ? _self.tagFilter : tagFilter // ignore: cast_nullable_to_non_nullable
as bool,showCheckboxes: null == showCheckboxes ? _self.showCheckboxes : showCheckboxes // ignore: cast_nullable_to_non_nullable
as bool,showMenuOptions: null == showMenuOptions ? _self.showMenuOptions : showMenuOptions // ignore: cast_nullable_to_non_nullable
as bool,showMoveOverlay: null == showMoveOverlay ? _self.showMoveOverlay : showMoveOverlay // ignore: cast_nullable_to_non_nullable
as bool,readingPaneEnabled: null == readingPaneEnabled ? _self.readingPaneEnabled : readingPaneEnabled // ignore: cast_nullable_to_non_nullable
as bool,showReadingPaneMenuOptions: null == showReadingPaneMenuOptions ? _self.showReadingPaneMenuOptions : showReadingPaneMenuOptions // ignore: cast_nullable_to_non_nullable
as bool,allEmailsTrue: null == allEmailsTrue ? _self.allEmailsTrue : allEmailsTrue // ignore: cast_nullable_to_non_nullable
as bool,isInProcess: null == isInProcess ? _self.isInProcess : isInProcess // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Emails>,selectedEmailIds: null == selectedEmailIds ? _self.selectedEmailIds : selectedEmailIds // ignore: cast_nullable_to_non_nullable
as List<int>,selectedEmails: null == selectedEmails ? _self.selectedEmails : selectedEmails // ignore: cast_nullable_to_non_nullable
as List<String>,lastClickedIndex: null == lastClickedIndex ? _self.lastClickedIndex : lastClickedIndex // ignore: cast_nullable_to_non_nullable
as int,tagIdFilter: null == tagIdFilter ? _self.tagIdFilter : tagIdFilter // ignore: cast_nullable_to_non_nullable
as List<int>,selectedTagIds: null == selectedTagIds ? _self.selectedTagIds : selectedTagIds // ignore: cast_nullable_to_non_nullable
as List<int>,previousPage: null == previousPage ? _self.previousPage : previousPage // ignore: cast_nullable_to_non_nullable
as int,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,totalEmailCount: null == totalEmailCount ? _self.totalEmailCount : totalEmailCount // ignore: cast_nullable_to_non_nullable
as int,selectedIndex: null == selectedIndex ? _self.selectedIndex : selectedIndex // ignore: cast_nullable_to_non_nullable
as int,searchKey: null == searchKey ? _self.searchKey : searchKey // ignore: cast_nullable_to_non_nullable
as String,emailType: freezed == emailType ? _self.emailType : emailType // ignore: cast_nullable_to_non_nullable
as String?,currentPath: freezed == currentPath ? _self.currentPath : currentPath // ignore: cast_nullable_to_non_nullable
as String?,communityEmail: null == communityEmail ? _self.communityEmail : communityEmail // ignore: cast_nullable_to_non_nullable
as String,selectedEmailIdForReadingPane: freezed == selectedEmailIdForReadingPane ? _self.selectedEmailIdForReadingPane : selectedEmailIdForReadingPane // ignore: cast_nullable_to_non_nullable
as int?,selectedEmailTags: freezed == selectedEmailTags ? _self.selectedEmailTags : selectedEmailTags // ignore: cast_nullable_to_non_nullable
as TagsListModel?,selectedEmailIndex: freezed == selectedEmailIndex ? _self.selectedEmailIndex : selectedEmailIndex // ignore: cast_nullable_to_non_nullable
as int?,selectedEmailSender: freezed == selectedEmailSender ? _self.selectedEmailSender : selectedEmailSender // ignore: cast_nullable_to_non_nullable
as String?,readingPaneRefreshKey: null == readingPaneRefreshKey ? _self.readingPaneRefreshKey : readingPaneRefreshKey // ignore: cast_nullable_to_non_nullable
as int,emailListPaneWidth: freezed == emailListPaneWidth ? _self.emailListPaneWidth : emailListPaneWidth // ignore: cast_nullable_to_non_nullable
as double?,inboxList: freezed == inboxList ? _self.inboxList : inboxList // ignore: cast_nullable_to_non_nullable
as SentListModel?,isComposeHovered: null == isComposeHovered ? _self.isComposeHovered : isComposeHovered // ignore: cast_nullable_to_non_nullable
as bool,newNotification: null == newNotification ? _self.newNotification : newNotification // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ArchiveState].
extension ArchiveStatePatterns on ArchiveState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ArchiveState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ArchiveState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ArchiveState value)  $default,){
final _that = this;
switch (_that) {
case _ArchiveState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ArchiveState value)?  $default,){
final _that = this;
switch (_that) {
case _ArchiveState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  bool isFetching,  bool isSearch,  bool showFilter,  bool showTagList,  bool longPressFlag,  bool allEmailIdsFlag,  bool tagFilter,  bool showCheckboxes,  bool showMenuOptions,  bool showMoveOverlay,  bool readingPaneEnabled,  bool showReadingPaneMenuOptions,  bool allEmailsTrue,  bool isInProcess,  List<Emails> items,  List<int> selectedEmailIds,  List<String> selectedEmails,  int lastClickedIndex,  List<int> tagIdFilter,  List<int> selectedTagIds,  int previousPage,  int currentPage,  int totalEmailCount,  int selectedIndex,  String searchKey,  String? emailType,  String? currentPath,  String communityEmail,  int? selectedEmailIdForReadingPane,  TagsListModel? selectedEmailTags,  int? selectedEmailIndex,  String? selectedEmailSender,  int readingPaneRefreshKey,  double? emailListPaneWidth,  SentListModel? inboxList,  bool isComposeHovered,  bool newNotification)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ArchiveState() when $default != null:
return $default(_that.isLoading,_that.isFetching,_that.isSearch,_that.showFilter,_that.showTagList,_that.longPressFlag,_that.allEmailIdsFlag,_that.tagFilter,_that.showCheckboxes,_that.showMenuOptions,_that.showMoveOverlay,_that.readingPaneEnabled,_that.showReadingPaneMenuOptions,_that.allEmailsTrue,_that.isInProcess,_that.items,_that.selectedEmailIds,_that.selectedEmails,_that.lastClickedIndex,_that.tagIdFilter,_that.selectedTagIds,_that.previousPage,_that.currentPage,_that.totalEmailCount,_that.selectedIndex,_that.searchKey,_that.emailType,_that.currentPath,_that.communityEmail,_that.selectedEmailIdForReadingPane,_that.selectedEmailTags,_that.selectedEmailIndex,_that.selectedEmailSender,_that.readingPaneRefreshKey,_that.emailListPaneWidth,_that.inboxList,_that.isComposeHovered,_that.newNotification);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  bool isFetching,  bool isSearch,  bool showFilter,  bool showTagList,  bool longPressFlag,  bool allEmailIdsFlag,  bool tagFilter,  bool showCheckboxes,  bool showMenuOptions,  bool showMoveOverlay,  bool readingPaneEnabled,  bool showReadingPaneMenuOptions,  bool allEmailsTrue,  bool isInProcess,  List<Emails> items,  List<int> selectedEmailIds,  List<String> selectedEmails,  int lastClickedIndex,  List<int> tagIdFilter,  List<int> selectedTagIds,  int previousPage,  int currentPage,  int totalEmailCount,  int selectedIndex,  String searchKey,  String? emailType,  String? currentPath,  String communityEmail,  int? selectedEmailIdForReadingPane,  TagsListModel? selectedEmailTags,  int? selectedEmailIndex,  String? selectedEmailSender,  int readingPaneRefreshKey,  double? emailListPaneWidth,  SentListModel? inboxList,  bool isComposeHovered,  bool newNotification)  $default,) {final _that = this;
switch (_that) {
case _ArchiveState():
return $default(_that.isLoading,_that.isFetching,_that.isSearch,_that.showFilter,_that.showTagList,_that.longPressFlag,_that.allEmailIdsFlag,_that.tagFilter,_that.showCheckboxes,_that.showMenuOptions,_that.showMoveOverlay,_that.readingPaneEnabled,_that.showReadingPaneMenuOptions,_that.allEmailsTrue,_that.isInProcess,_that.items,_that.selectedEmailIds,_that.selectedEmails,_that.lastClickedIndex,_that.tagIdFilter,_that.selectedTagIds,_that.previousPage,_that.currentPage,_that.totalEmailCount,_that.selectedIndex,_that.searchKey,_that.emailType,_that.currentPath,_that.communityEmail,_that.selectedEmailIdForReadingPane,_that.selectedEmailTags,_that.selectedEmailIndex,_that.selectedEmailSender,_that.readingPaneRefreshKey,_that.emailListPaneWidth,_that.inboxList,_that.isComposeHovered,_that.newNotification);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  bool isFetching,  bool isSearch,  bool showFilter,  bool showTagList,  bool longPressFlag,  bool allEmailIdsFlag,  bool tagFilter,  bool showCheckboxes,  bool showMenuOptions,  bool showMoveOverlay,  bool readingPaneEnabled,  bool showReadingPaneMenuOptions,  bool allEmailsTrue,  bool isInProcess,  List<Emails> items,  List<int> selectedEmailIds,  List<String> selectedEmails,  int lastClickedIndex,  List<int> tagIdFilter,  List<int> selectedTagIds,  int previousPage,  int currentPage,  int totalEmailCount,  int selectedIndex,  String searchKey,  String? emailType,  String? currentPath,  String communityEmail,  int? selectedEmailIdForReadingPane,  TagsListModel? selectedEmailTags,  int? selectedEmailIndex,  String? selectedEmailSender,  int readingPaneRefreshKey,  double? emailListPaneWidth,  SentListModel? inboxList,  bool isComposeHovered,  bool newNotification)?  $default,) {final _that = this;
switch (_that) {
case _ArchiveState() when $default != null:
return $default(_that.isLoading,_that.isFetching,_that.isSearch,_that.showFilter,_that.showTagList,_that.longPressFlag,_that.allEmailIdsFlag,_that.tagFilter,_that.showCheckboxes,_that.showMenuOptions,_that.showMoveOverlay,_that.readingPaneEnabled,_that.showReadingPaneMenuOptions,_that.allEmailsTrue,_that.isInProcess,_that.items,_that.selectedEmailIds,_that.selectedEmails,_that.lastClickedIndex,_that.tagIdFilter,_that.selectedTagIds,_that.previousPage,_that.currentPage,_that.totalEmailCount,_that.selectedIndex,_that.searchKey,_that.emailType,_that.currentPath,_that.communityEmail,_that.selectedEmailIdForReadingPane,_that.selectedEmailTags,_that.selectedEmailIndex,_that.selectedEmailSender,_that.readingPaneRefreshKey,_that.emailListPaneWidth,_that.inboxList,_that.isComposeHovered,_that.newNotification);case _:
  return null;

}
}

}

/// @nodoc


class _ArchiveState extends ArchiveState {
  const _ArchiveState({this.isLoading = false, this.isFetching = false, this.isSearch = false, this.showFilter = false, this.showTagList = false, this.longPressFlag = true, this.allEmailIdsFlag = false, this.tagFilter = false, this.showCheckboxes = false, this.showMenuOptions = false, this.showMoveOverlay = false, this.readingPaneEnabled = true, this.showReadingPaneMenuOptions = false, this.allEmailsTrue = true, this.isInProcess = false, final  List<Emails> items = const [], final  List<int> selectedEmailIds = const [], final  List<String> selectedEmails = const [], this.lastClickedIndex = -1, final  List<int> tagIdFilter = const [], final  List<int> selectedTagIds = const [], this.previousPage = 0, this.currentPage = 1, this.totalEmailCount = 0, this.selectedIndex = -1, this.searchKey = '', this.emailType, this.currentPath, this.communityEmail = '', this.selectedEmailIdForReadingPane, this.selectedEmailTags, this.selectedEmailIndex, this.selectedEmailSender, this.readingPaneRefreshKey = 0, this.emailListPaneWidth, this.inboxList, this.isComposeHovered = false, this.newNotification = false}): _items = items,_selectedEmailIds = selectedEmailIds,_selectedEmails = selectedEmails,_tagIdFilter = tagIdFilter,_selectedTagIds = selectedTagIds,super._();
  

// Flags
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isFetching;
@override@JsonKey() final  bool isSearch;
@override@JsonKey() final  bool showFilter;
@override@JsonKey() final  bool showTagList;
@override@JsonKey() final  bool longPressFlag;
@override@JsonKey() final  bool allEmailIdsFlag;
@override@JsonKey() final  bool tagFilter;
@override@JsonKey() final  bool showCheckboxes;
@override@JsonKey() final  bool showMenuOptions;
@override@JsonKey() final  bool showMoveOverlay;
@override@JsonKey() final  bool readingPaneEnabled;
@override@JsonKey() final  bool showReadingPaneMenuOptions;
@override@JsonKey() final  bool allEmailsTrue;
@override@JsonKey() final  bool isInProcess;
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
 final  List<int> _tagIdFilter;
@override@JsonKey() List<int> get tagIdFilter {
  if (_tagIdFilter is EqualUnmodifiableListView) return _tagIdFilter;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tagIdFilter);
}

 final  List<int> _selectedTagIds;
@override@JsonKey() List<int> get selectedTagIds {
  if (_selectedTagIds is EqualUnmodifiableListView) return _selectedTagIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedTagIds);
}

// Pagination
@override@JsonKey() final  int previousPage;
@override@JsonKey() final  int currentPage;
@override@JsonKey() final  int totalEmailCount;
@override@JsonKey() final  int selectedIndex;
// Filters / search
@override@JsonKey() final  String searchKey;
@override final  String? emailType;
@override final  String? currentPath;
@override@JsonKey() final  String communityEmail;
// Reading pane
@override final  int? selectedEmailIdForReadingPane;
@override final  TagsListModel? selectedEmailTags;
@override final  int? selectedEmailIndex;
@override final  String? selectedEmailSender;
@override@JsonKey() final  int readingPaneRefreshKey;
@override final  double? emailListPaneWidth;
// API models
@override final  SentListModel? inboxList;
@override@JsonKey() final  bool isComposeHovered;
// Notification
@override@JsonKey() final  bool newNotification;

/// Create a copy of ArchiveState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArchiveStateCopyWith<_ArchiveState> get copyWith => __$ArchiveStateCopyWithImpl<_ArchiveState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ArchiveState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isFetching, isFetching) || other.isFetching == isFetching)&&(identical(other.isSearch, isSearch) || other.isSearch == isSearch)&&(identical(other.showFilter, showFilter) || other.showFilter == showFilter)&&(identical(other.showTagList, showTagList) || other.showTagList == showTagList)&&(identical(other.longPressFlag, longPressFlag) || other.longPressFlag == longPressFlag)&&(identical(other.allEmailIdsFlag, allEmailIdsFlag) || other.allEmailIdsFlag == allEmailIdsFlag)&&(identical(other.tagFilter, tagFilter) || other.tagFilter == tagFilter)&&(identical(other.showCheckboxes, showCheckboxes) || other.showCheckboxes == showCheckboxes)&&(identical(other.showMenuOptions, showMenuOptions) || other.showMenuOptions == showMenuOptions)&&(identical(other.showMoveOverlay, showMoveOverlay) || other.showMoveOverlay == showMoveOverlay)&&(identical(other.readingPaneEnabled, readingPaneEnabled) || other.readingPaneEnabled == readingPaneEnabled)&&(identical(other.showReadingPaneMenuOptions, showReadingPaneMenuOptions) || other.showReadingPaneMenuOptions == showReadingPaneMenuOptions)&&(identical(other.allEmailsTrue, allEmailsTrue) || other.allEmailsTrue == allEmailsTrue)&&(identical(other.isInProcess, isInProcess) || other.isInProcess == isInProcess)&&const DeepCollectionEquality().equals(other._items, _items)&&const DeepCollectionEquality().equals(other._selectedEmailIds, _selectedEmailIds)&&const DeepCollectionEquality().equals(other._selectedEmails, _selectedEmails)&&(identical(other.lastClickedIndex, lastClickedIndex) || other.lastClickedIndex == lastClickedIndex)&&const DeepCollectionEquality().equals(other._tagIdFilter, _tagIdFilter)&&const DeepCollectionEquality().equals(other._selectedTagIds, _selectedTagIds)&&(identical(other.previousPage, previousPage) || other.previousPage == previousPage)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.totalEmailCount, totalEmailCount) || other.totalEmailCount == totalEmailCount)&&(identical(other.selectedIndex, selectedIndex) || other.selectedIndex == selectedIndex)&&(identical(other.searchKey, searchKey) || other.searchKey == searchKey)&&(identical(other.emailType, emailType) || other.emailType == emailType)&&(identical(other.currentPath, currentPath) || other.currentPath == currentPath)&&(identical(other.communityEmail, communityEmail) || other.communityEmail == communityEmail)&&(identical(other.selectedEmailIdForReadingPane, selectedEmailIdForReadingPane) || other.selectedEmailIdForReadingPane == selectedEmailIdForReadingPane)&&(identical(other.selectedEmailTags, selectedEmailTags) || other.selectedEmailTags == selectedEmailTags)&&(identical(other.selectedEmailIndex, selectedEmailIndex) || other.selectedEmailIndex == selectedEmailIndex)&&(identical(other.selectedEmailSender, selectedEmailSender) || other.selectedEmailSender == selectedEmailSender)&&(identical(other.readingPaneRefreshKey, readingPaneRefreshKey) || other.readingPaneRefreshKey == readingPaneRefreshKey)&&(identical(other.emailListPaneWidth, emailListPaneWidth) || other.emailListPaneWidth == emailListPaneWidth)&&(identical(other.inboxList, inboxList) || other.inboxList == inboxList)&&(identical(other.isComposeHovered, isComposeHovered) || other.isComposeHovered == isComposeHovered)&&(identical(other.newNotification, newNotification) || other.newNotification == newNotification));
}


@override
int get hashCode => Object.hashAll([runtimeType,isLoading,isFetching,isSearch,showFilter,showTagList,longPressFlag,allEmailIdsFlag,tagFilter,showCheckboxes,showMenuOptions,showMoveOverlay,readingPaneEnabled,showReadingPaneMenuOptions,allEmailsTrue,isInProcess,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_selectedEmailIds),const DeepCollectionEquality().hash(_selectedEmails),lastClickedIndex,const DeepCollectionEquality().hash(_tagIdFilter),const DeepCollectionEquality().hash(_selectedTagIds),previousPage,currentPage,totalEmailCount,selectedIndex,searchKey,emailType,currentPath,communityEmail,selectedEmailIdForReadingPane,selectedEmailTags,selectedEmailIndex,selectedEmailSender,readingPaneRefreshKey,emailListPaneWidth,inboxList,isComposeHovered,newNotification]);

@override
String toString() {
  return 'ArchiveState(isLoading: $isLoading, isFetching: $isFetching, isSearch: $isSearch, showFilter: $showFilter, showTagList: $showTagList, longPressFlag: $longPressFlag, allEmailIdsFlag: $allEmailIdsFlag, tagFilter: $tagFilter, showCheckboxes: $showCheckboxes, showMenuOptions: $showMenuOptions, showMoveOverlay: $showMoveOverlay, readingPaneEnabled: $readingPaneEnabled, showReadingPaneMenuOptions: $showReadingPaneMenuOptions, allEmailsTrue: $allEmailsTrue, isInProcess: $isInProcess, items: $items, selectedEmailIds: $selectedEmailIds, selectedEmails: $selectedEmails, lastClickedIndex: $lastClickedIndex, tagIdFilter: $tagIdFilter, selectedTagIds: $selectedTagIds, previousPage: $previousPage, currentPage: $currentPage, totalEmailCount: $totalEmailCount, selectedIndex: $selectedIndex, searchKey: $searchKey, emailType: $emailType, currentPath: $currentPath, communityEmail: $communityEmail, selectedEmailIdForReadingPane: $selectedEmailIdForReadingPane, selectedEmailTags: $selectedEmailTags, selectedEmailIndex: $selectedEmailIndex, selectedEmailSender: $selectedEmailSender, readingPaneRefreshKey: $readingPaneRefreshKey, emailListPaneWidth: $emailListPaneWidth, inboxList: $inboxList, isComposeHovered: $isComposeHovered, newNotification: $newNotification)';
}


}

/// @nodoc
abstract mixin class _$ArchiveStateCopyWith<$Res> implements $ArchiveStateCopyWith<$Res> {
  factory _$ArchiveStateCopyWith(_ArchiveState value, $Res Function(_ArchiveState) _then) = __$ArchiveStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, bool isFetching, bool isSearch, bool showFilter, bool showTagList, bool longPressFlag, bool allEmailIdsFlag, bool tagFilter, bool showCheckboxes, bool showMenuOptions, bool showMoveOverlay, bool readingPaneEnabled, bool showReadingPaneMenuOptions, bool allEmailsTrue, bool isInProcess, List<Emails> items, List<int> selectedEmailIds, List<String> selectedEmails, int lastClickedIndex, List<int> tagIdFilter, List<int> selectedTagIds, int previousPage, int currentPage, int totalEmailCount, int selectedIndex, String searchKey, String? emailType, String? currentPath, String communityEmail, int? selectedEmailIdForReadingPane, TagsListModel? selectedEmailTags, int? selectedEmailIndex, String? selectedEmailSender, int readingPaneRefreshKey, double? emailListPaneWidth, SentListModel? inboxList, bool isComposeHovered, bool newNotification
});




}
/// @nodoc
class __$ArchiveStateCopyWithImpl<$Res>
    implements _$ArchiveStateCopyWith<$Res> {
  __$ArchiveStateCopyWithImpl(this._self, this._then);

  final _ArchiveState _self;
  final $Res Function(_ArchiveState) _then;

/// Create a copy of ArchiveState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? isFetching = null,Object? isSearch = null,Object? showFilter = null,Object? showTagList = null,Object? longPressFlag = null,Object? allEmailIdsFlag = null,Object? tagFilter = null,Object? showCheckboxes = null,Object? showMenuOptions = null,Object? showMoveOverlay = null,Object? readingPaneEnabled = null,Object? showReadingPaneMenuOptions = null,Object? allEmailsTrue = null,Object? isInProcess = null,Object? items = null,Object? selectedEmailIds = null,Object? selectedEmails = null,Object? lastClickedIndex = null,Object? tagIdFilter = null,Object? selectedTagIds = null,Object? previousPage = null,Object? currentPage = null,Object? totalEmailCount = null,Object? selectedIndex = null,Object? searchKey = null,Object? emailType = freezed,Object? currentPath = freezed,Object? communityEmail = null,Object? selectedEmailIdForReadingPane = freezed,Object? selectedEmailTags = freezed,Object? selectedEmailIndex = freezed,Object? selectedEmailSender = freezed,Object? readingPaneRefreshKey = null,Object? emailListPaneWidth = freezed,Object? inboxList = freezed,Object? isComposeHovered = null,Object? newNotification = null,}) {
  return _then(_ArchiveState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isFetching: null == isFetching ? _self.isFetching : isFetching // ignore: cast_nullable_to_non_nullable
as bool,isSearch: null == isSearch ? _self.isSearch : isSearch // ignore: cast_nullable_to_non_nullable
as bool,showFilter: null == showFilter ? _self.showFilter : showFilter // ignore: cast_nullable_to_non_nullable
as bool,showTagList: null == showTagList ? _self.showTagList : showTagList // ignore: cast_nullable_to_non_nullable
as bool,longPressFlag: null == longPressFlag ? _self.longPressFlag : longPressFlag // ignore: cast_nullable_to_non_nullable
as bool,allEmailIdsFlag: null == allEmailIdsFlag ? _self.allEmailIdsFlag : allEmailIdsFlag // ignore: cast_nullable_to_non_nullable
as bool,tagFilter: null == tagFilter ? _self.tagFilter : tagFilter // ignore: cast_nullable_to_non_nullable
as bool,showCheckboxes: null == showCheckboxes ? _self.showCheckboxes : showCheckboxes // ignore: cast_nullable_to_non_nullable
as bool,showMenuOptions: null == showMenuOptions ? _self.showMenuOptions : showMenuOptions // ignore: cast_nullable_to_non_nullable
as bool,showMoveOverlay: null == showMoveOverlay ? _self.showMoveOverlay : showMoveOverlay // ignore: cast_nullable_to_non_nullable
as bool,readingPaneEnabled: null == readingPaneEnabled ? _self.readingPaneEnabled : readingPaneEnabled // ignore: cast_nullable_to_non_nullable
as bool,showReadingPaneMenuOptions: null == showReadingPaneMenuOptions ? _self.showReadingPaneMenuOptions : showReadingPaneMenuOptions // ignore: cast_nullable_to_non_nullable
as bool,allEmailsTrue: null == allEmailsTrue ? _self.allEmailsTrue : allEmailsTrue // ignore: cast_nullable_to_non_nullable
as bool,isInProcess: null == isInProcess ? _self.isInProcess : isInProcess // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Emails>,selectedEmailIds: null == selectedEmailIds ? _self._selectedEmailIds : selectedEmailIds // ignore: cast_nullable_to_non_nullable
as List<int>,selectedEmails: null == selectedEmails ? _self._selectedEmails : selectedEmails // ignore: cast_nullable_to_non_nullable
as List<String>,lastClickedIndex: null == lastClickedIndex ? _self.lastClickedIndex : lastClickedIndex // ignore: cast_nullable_to_non_nullable
as int,tagIdFilter: null == tagIdFilter ? _self._tagIdFilter : tagIdFilter // ignore: cast_nullable_to_non_nullable
as List<int>,selectedTagIds: null == selectedTagIds ? _self._selectedTagIds : selectedTagIds // ignore: cast_nullable_to_non_nullable
as List<int>,previousPage: null == previousPage ? _self.previousPage : previousPage // ignore: cast_nullable_to_non_nullable
as int,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,totalEmailCount: null == totalEmailCount ? _self.totalEmailCount : totalEmailCount // ignore: cast_nullable_to_non_nullable
as int,selectedIndex: null == selectedIndex ? _self.selectedIndex : selectedIndex // ignore: cast_nullable_to_non_nullable
as int,searchKey: null == searchKey ? _self.searchKey : searchKey // ignore: cast_nullable_to_non_nullable
as String,emailType: freezed == emailType ? _self.emailType : emailType // ignore: cast_nullable_to_non_nullable
as String?,currentPath: freezed == currentPath ? _self.currentPath : currentPath // ignore: cast_nullable_to_non_nullable
as String?,communityEmail: null == communityEmail ? _self.communityEmail : communityEmail // ignore: cast_nullable_to_non_nullable
as String,selectedEmailIdForReadingPane: freezed == selectedEmailIdForReadingPane ? _self.selectedEmailIdForReadingPane : selectedEmailIdForReadingPane // ignore: cast_nullable_to_non_nullable
as int?,selectedEmailTags: freezed == selectedEmailTags ? _self.selectedEmailTags : selectedEmailTags // ignore: cast_nullable_to_non_nullable
as TagsListModel?,selectedEmailIndex: freezed == selectedEmailIndex ? _self.selectedEmailIndex : selectedEmailIndex // ignore: cast_nullable_to_non_nullable
as int?,selectedEmailSender: freezed == selectedEmailSender ? _self.selectedEmailSender : selectedEmailSender // ignore: cast_nullable_to_non_nullable
as String?,readingPaneRefreshKey: null == readingPaneRefreshKey ? _self.readingPaneRefreshKey : readingPaneRefreshKey // ignore: cast_nullable_to_non_nullable
as int,emailListPaneWidth: freezed == emailListPaneWidth ? _self.emailListPaneWidth : emailListPaneWidth // ignore: cast_nullable_to_non_nullable
as double?,inboxList: freezed == inboxList ? _self.inboxList : inboxList // ignore: cast_nullable_to_non_nullable
as SentListModel?,isComposeHovered: null == isComposeHovered ? _self.isComposeHovered : isComposeHovered // ignore: cast_nullable_to_non_nullable
as bool,newNotification: null == newNotification ? _self.newNotification : newNotification // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
