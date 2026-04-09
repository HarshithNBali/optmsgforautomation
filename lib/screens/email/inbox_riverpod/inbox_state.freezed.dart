// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inbox_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InboxState {

// Flags
 bool get isLoading; bool get isFetching; bool get isSearch; bool get showFilter; bool get showTagList; bool get isTagListForFilter;// New flag to distinguish filter vs apply
 bool get longPressFlag; bool get allEmailIdsFlag; bool get tagFilter; bool get allEmailsTrue; bool get showMenuOptions; bool get showMoveOverlay; bool get readingPaneEnabled; bool get showReadingPaneMenuOptions; bool get showCheckboxes; bool get isComposeHovered; bool get syncContact; bool get isInProcess; bool get readingPaneEnabledWeb;// Paging / Search / Filter
 int get previousPage; int get currentPage; String get searchKey; List<int> get selectedEmailIds; List<String> get selectedEmails; int get lastClickedIndex; int get badgeCount; String? get emailType; String get token; InboxListModel? get inboxList; List<int> get tagIdFilter; int get totalEmailCount; List<int> get selectedTagIds;// Reading Pane
 int? get selectedEmailIdForReadingPane;// Compose in reading pane (when set, shows compose instead of email detail)
 Map<String, dynamic>? get composeInReadingPane; TagsListModel? get selectedEmailTags; int? get selectedEmailIndex; String? get selectedEmailSender; int get readingPaneRefreshKey; int? get currentlyViewedEmailId; double? get emailListPaneWidth; double? get readingPaneHeight;// Data
 List<Emails> get items; Map<String, dynamic>? get userData;// Undo
 List<Emails> get undoBuffer; List<int> get undoIds;// Notification
 bool get newNotification; String? get pendingOptInEmail; String? get pendingOptInSenderName; List<String> get pendingOptInEmails;// Tags
 List<Tags> get tagsItems; bool get showTagDialog; int get tagDialogEmailId; int get tagDialogItemIndex; bool get tagDialogIsMove; List<int> get tagDialogInitialTagIds;// Error
 String? get errorMessage;
/// Create a copy of InboxState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InboxStateCopyWith<InboxState> get copyWith => _$InboxStateCopyWithImpl<InboxState>(this as InboxState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InboxState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isFetching, isFetching) || other.isFetching == isFetching)&&(identical(other.isSearch, isSearch) || other.isSearch == isSearch)&&(identical(other.showFilter, showFilter) || other.showFilter == showFilter)&&(identical(other.showTagList, showTagList) || other.showTagList == showTagList)&&(identical(other.isTagListForFilter, isTagListForFilter) || other.isTagListForFilter == isTagListForFilter)&&(identical(other.longPressFlag, longPressFlag) || other.longPressFlag == longPressFlag)&&(identical(other.allEmailIdsFlag, allEmailIdsFlag) || other.allEmailIdsFlag == allEmailIdsFlag)&&(identical(other.tagFilter, tagFilter) || other.tagFilter == tagFilter)&&(identical(other.allEmailsTrue, allEmailsTrue) || other.allEmailsTrue == allEmailsTrue)&&(identical(other.showMenuOptions, showMenuOptions) || other.showMenuOptions == showMenuOptions)&&(identical(other.showMoveOverlay, showMoveOverlay) || other.showMoveOverlay == showMoveOverlay)&&(identical(other.readingPaneEnabled, readingPaneEnabled) || other.readingPaneEnabled == readingPaneEnabled)&&(identical(other.showReadingPaneMenuOptions, showReadingPaneMenuOptions) || other.showReadingPaneMenuOptions == showReadingPaneMenuOptions)&&(identical(other.showCheckboxes, showCheckboxes) || other.showCheckboxes == showCheckboxes)&&(identical(other.isComposeHovered, isComposeHovered) || other.isComposeHovered == isComposeHovered)&&(identical(other.syncContact, syncContact) || other.syncContact == syncContact)&&(identical(other.isInProcess, isInProcess) || other.isInProcess == isInProcess)&&(identical(other.readingPaneEnabledWeb, readingPaneEnabledWeb) || other.readingPaneEnabledWeb == readingPaneEnabledWeb)&&(identical(other.previousPage, previousPage) || other.previousPage == previousPage)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.searchKey, searchKey) || other.searchKey == searchKey)&&const DeepCollectionEquality().equals(other.selectedEmailIds, selectedEmailIds)&&const DeepCollectionEquality().equals(other.selectedEmails, selectedEmails)&&(identical(other.lastClickedIndex, lastClickedIndex) || other.lastClickedIndex == lastClickedIndex)&&(identical(other.badgeCount, badgeCount) || other.badgeCount == badgeCount)&&(identical(other.emailType, emailType) || other.emailType == emailType)&&(identical(other.token, token) || other.token == token)&&(identical(other.inboxList, inboxList) || other.inboxList == inboxList)&&const DeepCollectionEquality().equals(other.tagIdFilter, tagIdFilter)&&(identical(other.totalEmailCount, totalEmailCount) || other.totalEmailCount == totalEmailCount)&&const DeepCollectionEquality().equals(other.selectedTagIds, selectedTagIds)&&(identical(other.selectedEmailIdForReadingPane, selectedEmailIdForReadingPane) || other.selectedEmailIdForReadingPane == selectedEmailIdForReadingPane)&&const DeepCollectionEquality().equals(other.composeInReadingPane, composeInReadingPane)&&(identical(other.selectedEmailTags, selectedEmailTags) || other.selectedEmailTags == selectedEmailTags)&&(identical(other.selectedEmailIndex, selectedEmailIndex) || other.selectedEmailIndex == selectedEmailIndex)&&(identical(other.selectedEmailSender, selectedEmailSender) || other.selectedEmailSender == selectedEmailSender)&&(identical(other.readingPaneRefreshKey, readingPaneRefreshKey) || other.readingPaneRefreshKey == readingPaneRefreshKey)&&(identical(other.currentlyViewedEmailId, currentlyViewedEmailId) || other.currentlyViewedEmailId == currentlyViewedEmailId)&&(identical(other.emailListPaneWidth, emailListPaneWidth) || other.emailListPaneWidth == emailListPaneWidth)&&(identical(other.readingPaneHeight, readingPaneHeight) || other.readingPaneHeight == readingPaneHeight)&&const DeepCollectionEquality().equals(other.items, items)&&const DeepCollectionEquality().equals(other.userData, userData)&&const DeepCollectionEquality().equals(other.undoBuffer, undoBuffer)&&const DeepCollectionEquality().equals(other.undoIds, undoIds)&&(identical(other.newNotification, newNotification) || other.newNotification == newNotification)&&(identical(other.pendingOptInEmail, pendingOptInEmail) || other.pendingOptInEmail == pendingOptInEmail)&&(identical(other.pendingOptInSenderName, pendingOptInSenderName) || other.pendingOptInSenderName == pendingOptInSenderName)&&const DeepCollectionEquality().equals(other.pendingOptInEmails, pendingOptInEmails)&&const DeepCollectionEquality().equals(other.tagsItems, tagsItems)&&(identical(other.showTagDialog, showTagDialog) || other.showTagDialog == showTagDialog)&&(identical(other.tagDialogEmailId, tagDialogEmailId) || other.tagDialogEmailId == tagDialogEmailId)&&(identical(other.tagDialogItemIndex, tagDialogItemIndex) || other.tagDialogItemIndex == tagDialogItemIndex)&&(identical(other.tagDialogIsMove, tagDialogIsMove) || other.tagDialogIsMove == tagDialogIsMove)&&const DeepCollectionEquality().equals(other.tagDialogInitialTagIds, tagDialogInitialTagIds)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hashAll([runtimeType,isLoading,isFetching,isSearch,showFilter,showTagList,isTagListForFilter,longPressFlag,allEmailIdsFlag,tagFilter,allEmailsTrue,showMenuOptions,showMoveOverlay,readingPaneEnabled,showReadingPaneMenuOptions,showCheckboxes,isComposeHovered,syncContact,isInProcess,readingPaneEnabledWeb,previousPage,currentPage,searchKey,const DeepCollectionEquality().hash(selectedEmailIds),const DeepCollectionEquality().hash(selectedEmails),lastClickedIndex,badgeCount,emailType,token,inboxList,const DeepCollectionEquality().hash(tagIdFilter),totalEmailCount,const DeepCollectionEquality().hash(selectedTagIds),selectedEmailIdForReadingPane,const DeepCollectionEquality().hash(composeInReadingPane),selectedEmailTags,selectedEmailIndex,selectedEmailSender,readingPaneRefreshKey,currentlyViewedEmailId,emailListPaneWidth,readingPaneHeight,const DeepCollectionEquality().hash(items),const DeepCollectionEquality().hash(userData),const DeepCollectionEquality().hash(undoBuffer),const DeepCollectionEquality().hash(undoIds),newNotification,pendingOptInEmail,pendingOptInSenderName,const DeepCollectionEquality().hash(pendingOptInEmails),const DeepCollectionEquality().hash(tagsItems),showTagDialog,tagDialogEmailId,tagDialogItemIndex,tagDialogIsMove,const DeepCollectionEquality().hash(tagDialogInitialTagIds),errorMessage]);

@override
String toString() {
  return 'InboxState(isLoading: $isLoading, isFetching: $isFetching, isSearch: $isSearch, showFilter: $showFilter, showTagList: $showTagList, isTagListForFilter: $isTagListForFilter, longPressFlag: $longPressFlag, allEmailIdsFlag: $allEmailIdsFlag, tagFilter: $tagFilter, allEmailsTrue: $allEmailsTrue, showMenuOptions: $showMenuOptions, showMoveOverlay: $showMoveOverlay, readingPaneEnabled: $readingPaneEnabled, showReadingPaneMenuOptions: $showReadingPaneMenuOptions, showCheckboxes: $showCheckboxes, isComposeHovered: $isComposeHovered, syncContact: $syncContact, isInProcess: $isInProcess, readingPaneEnabledWeb: $readingPaneEnabledWeb, previousPage: $previousPage, currentPage: $currentPage, searchKey: $searchKey, selectedEmailIds: $selectedEmailIds, selectedEmails: $selectedEmails, lastClickedIndex: $lastClickedIndex, badgeCount: $badgeCount, emailType: $emailType, token: $token, inboxList: $inboxList, tagIdFilter: $tagIdFilter, totalEmailCount: $totalEmailCount, selectedTagIds: $selectedTagIds, selectedEmailIdForReadingPane: $selectedEmailIdForReadingPane, composeInReadingPane: $composeInReadingPane, selectedEmailTags: $selectedEmailTags, selectedEmailIndex: $selectedEmailIndex, selectedEmailSender: $selectedEmailSender, readingPaneRefreshKey: $readingPaneRefreshKey, currentlyViewedEmailId: $currentlyViewedEmailId, emailListPaneWidth: $emailListPaneWidth, readingPaneHeight: $readingPaneHeight, items: $items, userData: $userData, undoBuffer: $undoBuffer, undoIds: $undoIds, newNotification: $newNotification, pendingOptInEmail: $pendingOptInEmail, pendingOptInSenderName: $pendingOptInSenderName, pendingOptInEmails: $pendingOptInEmails, tagsItems: $tagsItems, showTagDialog: $showTagDialog, tagDialogEmailId: $tagDialogEmailId, tagDialogItemIndex: $tagDialogItemIndex, tagDialogIsMove: $tagDialogIsMove, tagDialogInitialTagIds: $tagDialogInitialTagIds, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $InboxStateCopyWith<$Res>  {
  factory $InboxStateCopyWith(InboxState value, $Res Function(InboxState) _then) = _$InboxStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, bool isFetching, bool isSearch, bool showFilter, bool showTagList, bool isTagListForFilter, bool longPressFlag, bool allEmailIdsFlag, bool tagFilter, bool allEmailsTrue, bool showMenuOptions, bool showMoveOverlay, bool readingPaneEnabled, bool showReadingPaneMenuOptions, bool showCheckboxes, bool isComposeHovered, bool syncContact, bool isInProcess, bool readingPaneEnabledWeb, int previousPage, int currentPage, String searchKey, List<int> selectedEmailIds, List<String> selectedEmails, int lastClickedIndex, int badgeCount, String? emailType, String token, InboxListModel? inboxList, List<int> tagIdFilter, int totalEmailCount, List<int> selectedTagIds, int? selectedEmailIdForReadingPane, Map<String, dynamic>? composeInReadingPane, TagsListModel? selectedEmailTags, int? selectedEmailIndex, String? selectedEmailSender, int readingPaneRefreshKey, int? currentlyViewedEmailId, double? emailListPaneWidth, double? readingPaneHeight, List<Emails> items, Map<String, dynamic>? userData, List<Emails> undoBuffer, List<int> undoIds, bool newNotification, String? pendingOptInEmail, String? pendingOptInSenderName, List<String> pendingOptInEmails, List<Tags> tagsItems, bool showTagDialog, int tagDialogEmailId, int tagDialogItemIndex, bool tagDialogIsMove, List<int> tagDialogInitialTagIds, String? errorMessage
});




}
/// @nodoc
class _$InboxStateCopyWithImpl<$Res>
    implements $InboxStateCopyWith<$Res> {
  _$InboxStateCopyWithImpl(this._self, this._then);

  final InboxState _self;
  final $Res Function(InboxState) _then;

/// Create a copy of InboxState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? isFetching = null,Object? isSearch = null,Object? showFilter = null,Object? showTagList = null,Object? isTagListForFilter = null,Object? longPressFlag = null,Object? allEmailIdsFlag = null,Object? tagFilter = null,Object? allEmailsTrue = null,Object? showMenuOptions = null,Object? showMoveOverlay = null,Object? readingPaneEnabled = null,Object? showReadingPaneMenuOptions = null,Object? showCheckboxes = null,Object? isComposeHovered = null,Object? syncContact = null,Object? isInProcess = null,Object? readingPaneEnabledWeb = null,Object? previousPage = null,Object? currentPage = null,Object? searchKey = null,Object? selectedEmailIds = null,Object? selectedEmails = null,Object? lastClickedIndex = null,Object? badgeCount = null,Object? emailType = freezed,Object? token = null,Object? inboxList = freezed,Object? tagIdFilter = null,Object? totalEmailCount = null,Object? selectedTagIds = null,Object? selectedEmailIdForReadingPane = freezed,Object? composeInReadingPane = freezed,Object? selectedEmailTags = freezed,Object? selectedEmailIndex = freezed,Object? selectedEmailSender = freezed,Object? readingPaneRefreshKey = null,Object? currentlyViewedEmailId = freezed,Object? emailListPaneWidth = freezed,Object? readingPaneHeight = freezed,Object? items = null,Object? userData = freezed,Object? undoBuffer = null,Object? undoIds = null,Object? newNotification = null,Object? pendingOptInEmail = freezed,Object? pendingOptInSenderName = freezed,Object? pendingOptInEmails = null,Object? tagsItems = null,Object? showTagDialog = null,Object? tagDialogEmailId = null,Object? tagDialogItemIndex = null,Object? tagDialogIsMove = null,Object? tagDialogInitialTagIds = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isFetching: null == isFetching ? _self.isFetching : isFetching // ignore: cast_nullable_to_non_nullable
as bool,isSearch: null == isSearch ? _self.isSearch : isSearch // ignore: cast_nullable_to_non_nullable
as bool,showFilter: null == showFilter ? _self.showFilter : showFilter // ignore: cast_nullable_to_non_nullable
as bool,showTagList: null == showTagList ? _self.showTagList : showTagList // ignore: cast_nullable_to_non_nullable
as bool,isTagListForFilter: null == isTagListForFilter ? _self.isTagListForFilter : isTagListForFilter // ignore: cast_nullable_to_non_nullable
as bool,longPressFlag: null == longPressFlag ? _self.longPressFlag : longPressFlag // ignore: cast_nullable_to_non_nullable
as bool,allEmailIdsFlag: null == allEmailIdsFlag ? _self.allEmailIdsFlag : allEmailIdsFlag // ignore: cast_nullable_to_non_nullable
as bool,tagFilter: null == tagFilter ? _self.tagFilter : tagFilter // ignore: cast_nullable_to_non_nullable
as bool,allEmailsTrue: null == allEmailsTrue ? _self.allEmailsTrue : allEmailsTrue // ignore: cast_nullable_to_non_nullable
as bool,showMenuOptions: null == showMenuOptions ? _self.showMenuOptions : showMenuOptions // ignore: cast_nullable_to_non_nullable
as bool,showMoveOverlay: null == showMoveOverlay ? _self.showMoveOverlay : showMoveOverlay // ignore: cast_nullable_to_non_nullable
as bool,readingPaneEnabled: null == readingPaneEnabled ? _self.readingPaneEnabled : readingPaneEnabled // ignore: cast_nullable_to_non_nullable
as bool,showReadingPaneMenuOptions: null == showReadingPaneMenuOptions ? _self.showReadingPaneMenuOptions : showReadingPaneMenuOptions // ignore: cast_nullable_to_non_nullable
as bool,showCheckboxes: null == showCheckboxes ? _self.showCheckboxes : showCheckboxes // ignore: cast_nullable_to_non_nullable
as bool,isComposeHovered: null == isComposeHovered ? _self.isComposeHovered : isComposeHovered // ignore: cast_nullable_to_non_nullable
as bool,syncContact: null == syncContact ? _self.syncContact : syncContact // ignore: cast_nullable_to_non_nullable
as bool,isInProcess: null == isInProcess ? _self.isInProcess : isInProcess // ignore: cast_nullable_to_non_nullable
as bool,readingPaneEnabledWeb: null == readingPaneEnabledWeb ? _self.readingPaneEnabledWeb : readingPaneEnabledWeb // ignore: cast_nullable_to_non_nullable
as bool,previousPage: null == previousPage ? _self.previousPage : previousPage // ignore: cast_nullable_to_non_nullable
as int,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,searchKey: null == searchKey ? _self.searchKey : searchKey // ignore: cast_nullable_to_non_nullable
as String,selectedEmailIds: null == selectedEmailIds ? _self.selectedEmailIds : selectedEmailIds // ignore: cast_nullable_to_non_nullable
as List<int>,selectedEmails: null == selectedEmails ? _self.selectedEmails : selectedEmails // ignore: cast_nullable_to_non_nullable
as List<String>,lastClickedIndex: null == lastClickedIndex ? _self.lastClickedIndex : lastClickedIndex // ignore: cast_nullable_to_non_nullable
as int,badgeCount: null == badgeCount ? _self.badgeCount : badgeCount // ignore: cast_nullable_to_non_nullable
as int,emailType: freezed == emailType ? _self.emailType : emailType // ignore: cast_nullable_to_non_nullable
as String?,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,inboxList: freezed == inboxList ? _self.inboxList : inboxList // ignore: cast_nullable_to_non_nullable
as InboxListModel?,tagIdFilter: null == tagIdFilter ? _self.tagIdFilter : tagIdFilter // ignore: cast_nullable_to_non_nullable
as List<int>,totalEmailCount: null == totalEmailCount ? _self.totalEmailCount : totalEmailCount // ignore: cast_nullable_to_non_nullable
as int,selectedTagIds: null == selectedTagIds ? _self.selectedTagIds : selectedTagIds // ignore: cast_nullable_to_non_nullable
as List<int>,selectedEmailIdForReadingPane: freezed == selectedEmailIdForReadingPane ? _self.selectedEmailIdForReadingPane : selectedEmailIdForReadingPane // ignore: cast_nullable_to_non_nullable
as int?,composeInReadingPane: freezed == composeInReadingPane ? _self.composeInReadingPane : composeInReadingPane // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,selectedEmailTags: freezed == selectedEmailTags ? _self.selectedEmailTags : selectedEmailTags // ignore: cast_nullable_to_non_nullable
as TagsListModel?,selectedEmailIndex: freezed == selectedEmailIndex ? _self.selectedEmailIndex : selectedEmailIndex // ignore: cast_nullable_to_non_nullable
as int?,selectedEmailSender: freezed == selectedEmailSender ? _self.selectedEmailSender : selectedEmailSender // ignore: cast_nullable_to_non_nullable
as String?,readingPaneRefreshKey: null == readingPaneRefreshKey ? _self.readingPaneRefreshKey : readingPaneRefreshKey // ignore: cast_nullable_to_non_nullable
as int,currentlyViewedEmailId: freezed == currentlyViewedEmailId ? _self.currentlyViewedEmailId : currentlyViewedEmailId // ignore: cast_nullable_to_non_nullable
as int?,emailListPaneWidth: freezed == emailListPaneWidth ? _self.emailListPaneWidth : emailListPaneWidth // ignore: cast_nullable_to_non_nullable
as double?,readingPaneHeight: freezed == readingPaneHeight ? _self.readingPaneHeight : readingPaneHeight // ignore: cast_nullable_to_non_nullable
as double?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Emails>,userData: freezed == userData ? _self.userData : userData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,undoBuffer: null == undoBuffer ? _self.undoBuffer : undoBuffer // ignore: cast_nullable_to_non_nullable
as List<Emails>,undoIds: null == undoIds ? _self.undoIds : undoIds // ignore: cast_nullable_to_non_nullable
as List<int>,newNotification: null == newNotification ? _self.newNotification : newNotification // ignore: cast_nullable_to_non_nullable
as bool,pendingOptInEmail: freezed == pendingOptInEmail ? _self.pendingOptInEmail : pendingOptInEmail // ignore: cast_nullable_to_non_nullable
as String?,pendingOptInSenderName: freezed == pendingOptInSenderName ? _self.pendingOptInSenderName : pendingOptInSenderName // ignore: cast_nullable_to_non_nullable
as String?,pendingOptInEmails: null == pendingOptInEmails ? _self.pendingOptInEmails : pendingOptInEmails // ignore: cast_nullable_to_non_nullable
as List<String>,tagsItems: null == tagsItems ? _self.tagsItems : tagsItems // ignore: cast_nullable_to_non_nullable
as List<Tags>,showTagDialog: null == showTagDialog ? _self.showTagDialog : showTagDialog // ignore: cast_nullable_to_non_nullable
as bool,tagDialogEmailId: null == tagDialogEmailId ? _self.tagDialogEmailId : tagDialogEmailId // ignore: cast_nullable_to_non_nullable
as int,tagDialogItemIndex: null == tagDialogItemIndex ? _self.tagDialogItemIndex : tagDialogItemIndex // ignore: cast_nullable_to_non_nullable
as int,tagDialogIsMove: null == tagDialogIsMove ? _self.tagDialogIsMove : tagDialogIsMove // ignore: cast_nullable_to_non_nullable
as bool,tagDialogInitialTagIds: null == tagDialogInitialTagIds ? _self.tagDialogInitialTagIds : tagDialogInitialTagIds // ignore: cast_nullable_to_non_nullable
as List<int>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [InboxState].
extension InboxStatePatterns on InboxState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InboxState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InboxState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InboxState value)  $default,){
final _that = this;
switch (_that) {
case _InboxState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InboxState value)?  $default,){
final _that = this;
switch (_that) {
case _InboxState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  bool isFetching,  bool isSearch,  bool showFilter,  bool showTagList,  bool isTagListForFilter,  bool longPressFlag,  bool allEmailIdsFlag,  bool tagFilter,  bool allEmailsTrue,  bool showMenuOptions,  bool showMoveOverlay,  bool readingPaneEnabled,  bool showReadingPaneMenuOptions,  bool showCheckboxes,  bool isComposeHovered,  bool syncContact,  bool isInProcess,  bool readingPaneEnabledWeb,  int previousPage,  int currentPage,  String searchKey,  List<int> selectedEmailIds,  List<String> selectedEmails,  int lastClickedIndex,  int badgeCount,  String? emailType,  String token,  InboxListModel? inboxList,  List<int> tagIdFilter,  int totalEmailCount,  List<int> selectedTagIds,  int? selectedEmailIdForReadingPane,  Map<String, dynamic>? composeInReadingPane,  TagsListModel? selectedEmailTags,  int? selectedEmailIndex,  String? selectedEmailSender,  int readingPaneRefreshKey,  int? currentlyViewedEmailId,  double? emailListPaneWidth,  double? readingPaneHeight,  List<Emails> items,  Map<String, dynamic>? userData,  List<Emails> undoBuffer,  List<int> undoIds,  bool newNotification,  String? pendingOptInEmail,  String? pendingOptInSenderName,  List<String> pendingOptInEmails,  List<Tags> tagsItems,  bool showTagDialog,  int tagDialogEmailId,  int tagDialogItemIndex,  bool tagDialogIsMove,  List<int> tagDialogInitialTagIds,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InboxState() when $default != null:
return $default(_that.isLoading,_that.isFetching,_that.isSearch,_that.showFilter,_that.showTagList,_that.isTagListForFilter,_that.longPressFlag,_that.allEmailIdsFlag,_that.tagFilter,_that.allEmailsTrue,_that.showMenuOptions,_that.showMoveOverlay,_that.readingPaneEnabled,_that.showReadingPaneMenuOptions,_that.showCheckboxes,_that.isComposeHovered,_that.syncContact,_that.isInProcess,_that.readingPaneEnabledWeb,_that.previousPage,_that.currentPage,_that.searchKey,_that.selectedEmailIds,_that.selectedEmails,_that.lastClickedIndex,_that.badgeCount,_that.emailType,_that.token,_that.inboxList,_that.tagIdFilter,_that.totalEmailCount,_that.selectedTagIds,_that.selectedEmailIdForReadingPane,_that.composeInReadingPane,_that.selectedEmailTags,_that.selectedEmailIndex,_that.selectedEmailSender,_that.readingPaneRefreshKey,_that.currentlyViewedEmailId,_that.emailListPaneWidth,_that.readingPaneHeight,_that.items,_that.userData,_that.undoBuffer,_that.undoIds,_that.newNotification,_that.pendingOptInEmail,_that.pendingOptInSenderName,_that.pendingOptInEmails,_that.tagsItems,_that.showTagDialog,_that.tagDialogEmailId,_that.tagDialogItemIndex,_that.tagDialogIsMove,_that.tagDialogInitialTagIds,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  bool isFetching,  bool isSearch,  bool showFilter,  bool showTagList,  bool isTagListForFilter,  bool longPressFlag,  bool allEmailIdsFlag,  bool tagFilter,  bool allEmailsTrue,  bool showMenuOptions,  bool showMoveOverlay,  bool readingPaneEnabled,  bool showReadingPaneMenuOptions,  bool showCheckboxes,  bool isComposeHovered,  bool syncContact,  bool isInProcess,  bool readingPaneEnabledWeb,  int previousPage,  int currentPage,  String searchKey,  List<int> selectedEmailIds,  List<String> selectedEmails,  int lastClickedIndex,  int badgeCount,  String? emailType,  String token,  InboxListModel? inboxList,  List<int> tagIdFilter,  int totalEmailCount,  List<int> selectedTagIds,  int? selectedEmailIdForReadingPane,  Map<String, dynamic>? composeInReadingPane,  TagsListModel? selectedEmailTags,  int? selectedEmailIndex,  String? selectedEmailSender,  int readingPaneRefreshKey,  int? currentlyViewedEmailId,  double? emailListPaneWidth,  double? readingPaneHeight,  List<Emails> items,  Map<String, dynamic>? userData,  List<Emails> undoBuffer,  List<int> undoIds,  bool newNotification,  String? pendingOptInEmail,  String? pendingOptInSenderName,  List<String> pendingOptInEmails,  List<Tags> tagsItems,  bool showTagDialog,  int tagDialogEmailId,  int tagDialogItemIndex,  bool tagDialogIsMove,  List<int> tagDialogInitialTagIds,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _InboxState():
return $default(_that.isLoading,_that.isFetching,_that.isSearch,_that.showFilter,_that.showTagList,_that.isTagListForFilter,_that.longPressFlag,_that.allEmailIdsFlag,_that.tagFilter,_that.allEmailsTrue,_that.showMenuOptions,_that.showMoveOverlay,_that.readingPaneEnabled,_that.showReadingPaneMenuOptions,_that.showCheckboxes,_that.isComposeHovered,_that.syncContact,_that.isInProcess,_that.readingPaneEnabledWeb,_that.previousPage,_that.currentPage,_that.searchKey,_that.selectedEmailIds,_that.selectedEmails,_that.lastClickedIndex,_that.badgeCount,_that.emailType,_that.token,_that.inboxList,_that.tagIdFilter,_that.totalEmailCount,_that.selectedTagIds,_that.selectedEmailIdForReadingPane,_that.composeInReadingPane,_that.selectedEmailTags,_that.selectedEmailIndex,_that.selectedEmailSender,_that.readingPaneRefreshKey,_that.currentlyViewedEmailId,_that.emailListPaneWidth,_that.readingPaneHeight,_that.items,_that.userData,_that.undoBuffer,_that.undoIds,_that.newNotification,_that.pendingOptInEmail,_that.pendingOptInSenderName,_that.pendingOptInEmails,_that.tagsItems,_that.showTagDialog,_that.tagDialogEmailId,_that.tagDialogItemIndex,_that.tagDialogIsMove,_that.tagDialogInitialTagIds,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  bool isFetching,  bool isSearch,  bool showFilter,  bool showTagList,  bool isTagListForFilter,  bool longPressFlag,  bool allEmailIdsFlag,  bool tagFilter,  bool allEmailsTrue,  bool showMenuOptions,  bool showMoveOverlay,  bool readingPaneEnabled,  bool showReadingPaneMenuOptions,  bool showCheckboxes,  bool isComposeHovered,  bool syncContact,  bool isInProcess,  bool readingPaneEnabledWeb,  int previousPage,  int currentPage,  String searchKey,  List<int> selectedEmailIds,  List<String> selectedEmails,  int lastClickedIndex,  int badgeCount,  String? emailType,  String token,  InboxListModel? inboxList,  List<int> tagIdFilter,  int totalEmailCount,  List<int> selectedTagIds,  int? selectedEmailIdForReadingPane,  Map<String, dynamic>? composeInReadingPane,  TagsListModel? selectedEmailTags,  int? selectedEmailIndex,  String? selectedEmailSender,  int readingPaneRefreshKey,  int? currentlyViewedEmailId,  double? emailListPaneWidth,  double? readingPaneHeight,  List<Emails> items,  Map<String, dynamic>? userData,  List<Emails> undoBuffer,  List<int> undoIds,  bool newNotification,  String? pendingOptInEmail,  String? pendingOptInSenderName,  List<String> pendingOptInEmails,  List<Tags> tagsItems,  bool showTagDialog,  int tagDialogEmailId,  int tagDialogItemIndex,  bool tagDialogIsMove,  List<int> tagDialogInitialTagIds,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _InboxState() when $default != null:
return $default(_that.isLoading,_that.isFetching,_that.isSearch,_that.showFilter,_that.showTagList,_that.isTagListForFilter,_that.longPressFlag,_that.allEmailIdsFlag,_that.tagFilter,_that.allEmailsTrue,_that.showMenuOptions,_that.showMoveOverlay,_that.readingPaneEnabled,_that.showReadingPaneMenuOptions,_that.showCheckboxes,_that.isComposeHovered,_that.syncContact,_that.isInProcess,_that.readingPaneEnabledWeb,_that.previousPage,_that.currentPage,_that.searchKey,_that.selectedEmailIds,_that.selectedEmails,_that.lastClickedIndex,_that.badgeCount,_that.emailType,_that.token,_that.inboxList,_that.tagIdFilter,_that.totalEmailCount,_that.selectedTagIds,_that.selectedEmailIdForReadingPane,_that.composeInReadingPane,_that.selectedEmailTags,_that.selectedEmailIndex,_that.selectedEmailSender,_that.readingPaneRefreshKey,_that.currentlyViewedEmailId,_that.emailListPaneWidth,_that.readingPaneHeight,_that.items,_that.userData,_that.undoBuffer,_that.undoIds,_that.newNotification,_that.pendingOptInEmail,_that.pendingOptInSenderName,_that.pendingOptInEmails,_that.tagsItems,_that.showTagDialog,_that.tagDialogEmailId,_that.tagDialogItemIndex,_that.tagDialogIsMove,_that.tagDialogInitialTagIds,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _InboxState extends InboxState {
  const _InboxState({this.isLoading = true, this.isFetching = false, this.isSearch = false, this.showFilter = false, this.showTagList = false, this.isTagListForFilter = false, this.longPressFlag = true, this.allEmailIdsFlag = false, this.tagFilter = false, this.allEmailsTrue = true, this.showMenuOptions = false, this.showMoveOverlay = false, this.readingPaneEnabled = true, this.showReadingPaneMenuOptions = false, this.showCheckboxes = false, this.isComposeHovered = false, this.syncContact = true, this.isInProcess = false, this.readingPaneEnabledWeb = true, this.previousPage = 0, this.currentPage = 1, this.searchKey = '', final  List<int> selectedEmailIds = const [], final  List<String> selectedEmails = const [], this.lastClickedIndex = -1, this.badgeCount = 0, this.emailType = 'inbox', this.token = '', this.inboxList, final  List<int> tagIdFilter = const [], this.totalEmailCount = 0, final  List<int> selectedTagIds = const [], this.selectedEmailIdForReadingPane, final  Map<String, dynamic>? composeInReadingPane, this.selectedEmailTags, this.selectedEmailIndex, this.selectedEmailSender, this.readingPaneRefreshKey = 0, this.currentlyViewedEmailId, this.emailListPaneWidth, this.readingPaneHeight, final  List<Emails> items = const [], final  Map<String, dynamic>? userData, final  List<Emails> undoBuffer = const [], final  List<int> undoIds = const [], this.newNotification = false, this.pendingOptInEmail, this.pendingOptInSenderName, final  List<String> pendingOptInEmails = const [], final  List<Tags> tagsItems = const [], this.showTagDialog = false, this.tagDialogEmailId = 0, this.tagDialogItemIndex = 0, this.tagDialogIsMove = false, final  List<int> tagDialogInitialTagIds = const [], this.errorMessage}): _selectedEmailIds = selectedEmailIds,_selectedEmails = selectedEmails,_tagIdFilter = tagIdFilter,_selectedTagIds = selectedTagIds,_composeInReadingPane = composeInReadingPane,_items = items,_userData = userData,_undoBuffer = undoBuffer,_undoIds = undoIds,_pendingOptInEmails = pendingOptInEmails,_tagsItems = tagsItems,_tagDialogInitialTagIds = tagDialogInitialTagIds,super._();
  

// Flags
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isFetching;
@override@JsonKey() final  bool isSearch;
@override@JsonKey() final  bool showFilter;
@override@JsonKey() final  bool showTagList;
@override@JsonKey() final  bool isTagListForFilter;
// New flag to distinguish filter vs apply
@override@JsonKey() final  bool longPressFlag;
@override@JsonKey() final  bool allEmailIdsFlag;
@override@JsonKey() final  bool tagFilter;
@override@JsonKey() final  bool allEmailsTrue;
@override@JsonKey() final  bool showMenuOptions;
@override@JsonKey() final  bool showMoveOverlay;
@override@JsonKey() final  bool readingPaneEnabled;
@override@JsonKey() final  bool showReadingPaneMenuOptions;
@override@JsonKey() final  bool showCheckboxes;
@override@JsonKey() final  bool isComposeHovered;
@override@JsonKey() final  bool syncContact;
@override@JsonKey() final  bool isInProcess;
@override@JsonKey() final  bool readingPaneEnabledWeb;
// Paging / Search / Filter
@override@JsonKey() final  int previousPage;
@override@JsonKey() final  int currentPage;
@override@JsonKey() final  String searchKey;
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
@override@JsonKey() final  int badgeCount;
@override@JsonKey() final  String? emailType;
@override@JsonKey() final  String token;
@override final  InboxListModel? inboxList;
 final  List<int> _tagIdFilter;
@override@JsonKey() List<int> get tagIdFilter {
  if (_tagIdFilter is EqualUnmodifiableListView) return _tagIdFilter;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tagIdFilter);
}

@override@JsonKey() final  int totalEmailCount;
 final  List<int> _selectedTagIds;
@override@JsonKey() List<int> get selectedTagIds {
  if (_selectedTagIds is EqualUnmodifiableListView) return _selectedTagIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedTagIds);
}

// Reading Pane
@override final  int? selectedEmailIdForReadingPane;
// Compose in reading pane (when set, shows compose instead of email detail)
 final  Map<String, dynamic>? _composeInReadingPane;
// Compose in reading pane (when set, shows compose instead of email detail)
@override Map<String, dynamic>? get composeInReadingPane {
  final value = _composeInReadingPane;
  if (value == null) return null;
  if (_composeInReadingPane is EqualUnmodifiableMapView) return _composeInReadingPane;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  TagsListModel? selectedEmailTags;
@override final  int? selectedEmailIndex;
@override final  String? selectedEmailSender;
@override@JsonKey() final  int readingPaneRefreshKey;
@override final  int? currentlyViewedEmailId;
@override final  double? emailListPaneWidth;
@override final  double? readingPaneHeight;
// Data
 final  List<Emails> _items;
// Data
@override@JsonKey() List<Emails> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  Map<String, dynamic>? _userData;
@override Map<String, dynamic>? get userData {
  final value = _userData;
  if (value == null) return null;
  if (_userData is EqualUnmodifiableMapView) return _userData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

// Undo
 final  List<Emails> _undoBuffer;
// Undo
@override@JsonKey() List<Emails> get undoBuffer {
  if (_undoBuffer is EqualUnmodifiableListView) return _undoBuffer;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_undoBuffer);
}

 final  List<int> _undoIds;
@override@JsonKey() List<int> get undoIds {
  if (_undoIds is EqualUnmodifiableListView) return _undoIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_undoIds);
}

// Notification
@override@JsonKey() final  bool newNotification;
@override final  String? pendingOptInEmail;
@override final  String? pendingOptInSenderName;
 final  List<String> _pendingOptInEmails;
@override@JsonKey() List<String> get pendingOptInEmails {
  if (_pendingOptInEmails is EqualUnmodifiableListView) return _pendingOptInEmails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pendingOptInEmails);
}

// Tags
 final  List<Tags> _tagsItems;
// Tags
@override@JsonKey() List<Tags> get tagsItems {
  if (_tagsItems is EqualUnmodifiableListView) return _tagsItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tagsItems);
}

@override@JsonKey() final  bool showTagDialog;
@override@JsonKey() final  int tagDialogEmailId;
@override@JsonKey() final  int tagDialogItemIndex;
@override@JsonKey() final  bool tagDialogIsMove;
 final  List<int> _tagDialogInitialTagIds;
@override@JsonKey() List<int> get tagDialogInitialTagIds {
  if (_tagDialogInitialTagIds is EqualUnmodifiableListView) return _tagDialogInitialTagIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tagDialogInitialTagIds);
}

// Error
@override final  String? errorMessage;

/// Create a copy of InboxState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InboxStateCopyWith<_InboxState> get copyWith => __$InboxStateCopyWithImpl<_InboxState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InboxState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isFetching, isFetching) || other.isFetching == isFetching)&&(identical(other.isSearch, isSearch) || other.isSearch == isSearch)&&(identical(other.showFilter, showFilter) || other.showFilter == showFilter)&&(identical(other.showTagList, showTagList) || other.showTagList == showTagList)&&(identical(other.isTagListForFilter, isTagListForFilter) || other.isTagListForFilter == isTagListForFilter)&&(identical(other.longPressFlag, longPressFlag) || other.longPressFlag == longPressFlag)&&(identical(other.allEmailIdsFlag, allEmailIdsFlag) || other.allEmailIdsFlag == allEmailIdsFlag)&&(identical(other.tagFilter, tagFilter) || other.tagFilter == tagFilter)&&(identical(other.allEmailsTrue, allEmailsTrue) || other.allEmailsTrue == allEmailsTrue)&&(identical(other.showMenuOptions, showMenuOptions) || other.showMenuOptions == showMenuOptions)&&(identical(other.showMoveOverlay, showMoveOverlay) || other.showMoveOverlay == showMoveOverlay)&&(identical(other.readingPaneEnabled, readingPaneEnabled) || other.readingPaneEnabled == readingPaneEnabled)&&(identical(other.showReadingPaneMenuOptions, showReadingPaneMenuOptions) || other.showReadingPaneMenuOptions == showReadingPaneMenuOptions)&&(identical(other.showCheckboxes, showCheckboxes) || other.showCheckboxes == showCheckboxes)&&(identical(other.isComposeHovered, isComposeHovered) || other.isComposeHovered == isComposeHovered)&&(identical(other.syncContact, syncContact) || other.syncContact == syncContact)&&(identical(other.isInProcess, isInProcess) || other.isInProcess == isInProcess)&&(identical(other.readingPaneEnabledWeb, readingPaneEnabledWeb) || other.readingPaneEnabledWeb == readingPaneEnabledWeb)&&(identical(other.previousPage, previousPage) || other.previousPage == previousPage)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.searchKey, searchKey) || other.searchKey == searchKey)&&const DeepCollectionEquality().equals(other._selectedEmailIds, _selectedEmailIds)&&const DeepCollectionEquality().equals(other._selectedEmails, _selectedEmails)&&(identical(other.lastClickedIndex, lastClickedIndex) || other.lastClickedIndex == lastClickedIndex)&&(identical(other.badgeCount, badgeCount) || other.badgeCount == badgeCount)&&(identical(other.emailType, emailType) || other.emailType == emailType)&&(identical(other.token, token) || other.token == token)&&(identical(other.inboxList, inboxList) || other.inboxList == inboxList)&&const DeepCollectionEquality().equals(other._tagIdFilter, _tagIdFilter)&&(identical(other.totalEmailCount, totalEmailCount) || other.totalEmailCount == totalEmailCount)&&const DeepCollectionEquality().equals(other._selectedTagIds, _selectedTagIds)&&(identical(other.selectedEmailIdForReadingPane, selectedEmailIdForReadingPane) || other.selectedEmailIdForReadingPane == selectedEmailIdForReadingPane)&&const DeepCollectionEquality().equals(other._composeInReadingPane, _composeInReadingPane)&&(identical(other.selectedEmailTags, selectedEmailTags) || other.selectedEmailTags == selectedEmailTags)&&(identical(other.selectedEmailIndex, selectedEmailIndex) || other.selectedEmailIndex == selectedEmailIndex)&&(identical(other.selectedEmailSender, selectedEmailSender) || other.selectedEmailSender == selectedEmailSender)&&(identical(other.readingPaneRefreshKey, readingPaneRefreshKey) || other.readingPaneRefreshKey == readingPaneRefreshKey)&&(identical(other.currentlyViewedEmailId, currentlyViewedEmailId) || other.currentlyViewedEmailId == currentlyViewedEmailId)&&(identical(other.emailListPaneWidth, emailListPaneWidth) || other.emailListPaneWidth == emailListPaneWidth)&&(identical(other.readingPaneHeight, readingPaneHeight) || other.readingPaneHeight == readingPaneHeight)&&const DeepCollectionEquality().equals(other._items, _items)&&const DeepCollectionEquality().equals(other._userData, _userData)&&const DeepCollectionEquality().equals(other._undoBuffer, _undoBuffer)&&const DeepCollectionEquality().equals(other._undoIds, _undoIds)&&(identical(other.newNotification, newNotification) || other.newNotification == newNotification)&&(identical(other.pendingOptInEmail, pendingOptInEmail) || other.pendingOptInEmail == pendingOptInEmail)&&(identical(other.pendingOptInSenderName, pendingOptInSenderName) || other.pendingOptInSenderName == pendingOptInSenderName)&&const DeepCollectionEquality().equals(other._pendingOptInEmails, _pendingOptInEmails)&&const DeepCollectionEquality().equals(other._tagsItems, _tagsItems)&&(identical(other.showTagDialog, showTagDialog) || other.showTagDialog == showTagDialog)&&(identical(other.tagDialogEmailId, tagDialogEmailId) || other.tagDialogEmailId == tagDialogEmailId)&&(identical(other.tagDialogItemIndex, tagDialogItemIndex) || other.tagDialogItemIndex == tagDialogItemIndex)&&(identical(other.tagDialogIsMove, tagDialogIsMove) || other.tagDialogIsMove == tagDialogIsMove)&&const DeepCollectionEquality().equals(other._tagDialogInitialTagIds, _tagDialogInitialTagIds)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hashAll([runtimeType,isLoading,isFetching,isSearch,showFilter,showTagList,isTagListForFilter,longPressFlag,allEmailIdsFlag,tagFilter,allEmailsTrue,showMenuOptions,showMoveOverlay,readingPaneEnabled,showReadingPaneMenuOptions,showCheckboxes,isComposeHovered,syncContact,isInProcess,readingPaneEnabledWeb,previousPage,currentPage,searchKey,const DeepCollectionEquality().hash(_selectedEmailIds),const DeepCollectionEquality().hash(_selectedEmails),lastClickedIndex,badgeCount,emailType,token,inboxList,const DeepCollectionEquality().hash(_tagIdFilter),totalEmailCount,const DeepCollectionEquality().hash(_selectedTagIds),selectedEmailIdForReadingPane,const DeepCollectionEquality().hash(_composeInReadingPane),selectedEmailTags,selectedEmailIndex,selectedEmailSender,readingPaneRefreshKey,currentlyViewedEmailId,emailListPaneWidth,readingPaneHeight,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_userData),const DeepCollectionEquality().hash(_undoBuffer),const DeepCollectionEquality().hash(_undoIds),newNotification,pendingOptInEmail,pendingOptInSenderName,const DeepCollectionEquality().hash(_pendingOptInEmails),const DeepCollectionEquality().hash(_tagsItems),showTagDialog,tagDialogEmailId,tagDialogItemIndex,tagDialogIsMove,const DeepCollectionEquality().hash(_tagDialogInitialTagIds),errorMessage]);

@override
String toString() {
  return 'InboxState(isLoading: $isLoading, isFetching: $isFetching, isSearch: $isSearch, showFilter: $showFilter, showTagList: $showTagList, isTagListForFilter: $isTagListForFilter, longPressFlag: $longPressFlag, allEmailIdsFlag: $allEmailIdsFlag, tagFilter: $tagFilter, allEmailsTrue: $allEmailsTrue, showMenuOptions: $showMenuOptions, showMoveOverlay: $showMoveOverlay, readingPaneEnabled: $readingPaneEnabled, showReadingPaneMenuOptions: $showReadingPaneMenuOptions, showCheckboxes: $showCheckboxes, isComposeHovered: $isComposeHovered, syncContact: $syncContact, isInProcess: $isInProcess, readingPaneEnabledWeb: $readingPaneEnabledWeb, previousPage: $previousPage, currentPage: $currentPage, searchKey: $searchKey, selectedEmailIds: $selectedEmailIds, selectedEmails: $selectedEmails, lastClickedIndex: $lastClickedIndex, badgeCount: $badgeCount, emailType: $emailType, token: $token, inboxList: $inboxList, tagIdFilter: $tagIdFilter, totalEmailCount: $totalEmailCount, selectedTagIds: $selectedTagIds, selectedEmailIdForReadingPane: $selectedEmailIdForReadingPane, composeInReadingPane: $composeInReadingPane, selectedEmailTags: $selectedEmailTags, selectedEmailIndex: $selectedEmailIndex, selectedEmailSender: $selectedEmailSender, readingPaneRefreshKey: $readingPaneRefreshKey, currentlyViewedEmailId: $currentlyViewedEmailId, emailListPaneWidth: $emailListPaneWidth, readingPaneHeight: $readingPaneHeight, items: $items, userData: $userData, undoBuffer: $undoBuffer, undoIds: $undoIds, newNotification: $newNotification, pendingOptInEmail: $pendingOptInEmail, pendingOptInSenderName: $pendingOptInSenderName, pendingOptInEmails: $pendingOptInEmails, tagsItems: $tagsItems, showTagDialog: $showTagDialog, tagDialogEmailId: $tagDialogEmailId, tagDialogItemIndex: $tagDialogItemIndex, tagDialogIsMove: $tagDialogIsMove, tagDialogInitialTagIds: $tagDialogInitialTagIds, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$InboxStateCopyWith<$Res> implements $InboxStateCopyWith<$Res> {
  factory _$InboxStateCopyWith(_InboxState value, $Res Function(_InboxState) _then) = __$InboxStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, bool isFetching, bool isSearch, bool showFilter, bool showTagList, bool isTagListForFilter, bool longPressFlag, bool allEmailIdsFlag, bool tagFilter, bool allEmailsTrue, bool showMenuOptions, bool showMoveOverlay, bool readingPaneEnabled, bool showReadingPaneMenuOptions, bool showCheckboxes, bool isComposeHovered, bool syncContact, bool isInProcess, bool readingPaneEnabledWeb, int previousPage, int currentPage, String searchKey, List<int> selectedEmailIds, List<String> selectedEmails, int lastClickedIndex, int badgeCount, String? emailType, String token, InboxListModel? inboxList, List<int> tagIdFilter, int totalEmailCount, List<int> selectedTagIds, int? selectedEmailIdForReadingPane, Map<String, dynamic>? composeInReadingPane, TagsListModel? selectedEmailTags, int? selectedEmailIndex, String? selectedEmailSender, int readingPaneRefreshKey, int? currentlyViewedEmailId, double? emailListPaneWidth, double? readingPaneHeight, List<Emails> items, Map<String, dynamic>? userData, List<Emails> undoBuffer, List<int> undoIds, bool newNotification, String? pendingOptInEmail, String? pendingOptInSenderName, List<String> pendingOptInEmails, List<Tags> tagsItems, bool showTagDialog, int tagDialogEmailId, int tagDialogItemIndex, bool tagDialogIsMove, List<int> tagDialogInitialTagIds, String? errorMessage
});




}
/// @nodoc
class __$InboxStateCopyWithImpl<$Res>
    implements _$InboxStateCopyWith<$Res> {
  __$InboxStateCopyWithImpl(this._self, this._then);

  final _InboxState _self;
  final $Res Function(_InboxState) _then;

/// Create a copy of InboxState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? isFetching = null,Object? isSearch = null,Object? showFilter = null,Object? showTagList = null,Object? isTagListForFilter = null,Object? longPressFlag = null,Object? allEmailIdsFlag = null,Object? tagFilter = null,Object? allEmailsTrue = null,Object? showMenuOptions = null,Object? showMoveOverlay = null,Object? readingPaneEnabled = null,Object? showReadingPaneMenuOptions = null,Object? showCheckboxes = null,Object? isComposeHovered = null,Object? syncContact = null,Object? isInProcess = null,Object? readingPaneEnabledWeb = null,Object? previousPage = null,Object? currentPage = null,Object? searchKey = null,Object? selectedEmailIds = null,Object? selectedEmails = null,Object? lastClickedIndex = null,Object? badgeCount = null,Object? emailType = freezed,Object? token = null,Object? inboxList = freezed,Object? tagIdFilter = null,Object? totalEmailCount = null,Object? selectedTagIds = null,Object? selectedEmailIdForReadingPane = freezed,Object? composeInReadingPane = freezed,Object? selectedEmailTags = freezed,Object? selectedEmailIndex = freezed,Object? selectedEmailSender = freezed,Object? readingPaneRefreshKey = null,Object? currentlyViewedEmailId = freezed,Object? emailListPaneWidth = freezed,Object? readingPaneHeight = freezed,Object? items = null,Object? userData = freezed,Object? undoBuffer = null,Object? undoIds = null,Object? newNotification = null,Object? pendingOptInEmail = freezed,Object? pendingOptInSenderName = freezed,Object? pendingOptInEmails = null,Object? tagsItems = null,Object? showTagDialog = null,Object? tagDialogEmailId = null,Object? tagDialogItemIndex = null,Object? tagDialogIsMove = null,Object? tagDialogInitialTagIds = null,Object? errorMessage = freezed,}) {
  return _then(_InboxState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isFetching: null == isFetching ? _self.isFetching : isFetching // ignore: cast_nullable_to_non_nullable
as bool,isSearch: null == isSearch ? _self.isSearch : isSearch // ignore: cast_nullable_to_non_nullable
as bool,showFilter: null == showFilter ? _self.showFilter : showFilter // ignore: cast_nullable_to_non_nullable
as bool,showTagList: null == showTagList ? _self.showTagList : showTagList // ignore: cast_nullable_to_non_nullable
as bool,isTagListForFilter: null == isTagListForFilter ? _self.isTagListForFilter : isTagListForFilter // ignore: cast_nullable_to_non_nullable
as bool,longPressFlag: null == longPressFlag ? _self.longPressFlag : longPressFlag // ignore: cast_nullable_to_non_nullable
as bool,allEmailIdsFlag: null == allEmailIdsFlag ? _self.allEmailIdsFlag : allEmailIdsFlag // ignore: cast_nullable_to_non_nullable
as bool,tagFilter: null == tagFilter ? _self.tagFilter : tagFilter // ignore: cast_nullable_to_non_nullable
as bool,allEmailsTrue: null == allEmailsTrue ? _self.allEmailsTrue : allEmailsTrue // ignore: cast_nullable_to_non_nullable
as bool,showMenuOptions: null == showMenuOptions ? _self.showMenuOptions : showMenuOptions // ignore: cast_nullable_to_non_nullable
as bool,showMoveOverlay: null == showMoveOverlay ? _self.showMoveOverlay : showMoveOverlay // ignore: cast_nullable_to_non_nullable
as bool,readingPaneEnabled: null == readingPaneEnabled ? _self.readingPaneEnabled : readingPaneEnabled // ignore: cast_nullable_to_non_nullable
as bool,showReadingPaneMenuOptions: null == showReadingPaneMenuOptions ? _self.showReadingPaneMenuOptions : showReadingPaneMenuOptions // ignore: cast_nullable_to_non_nullable
as bool,showCheckboxes: null == showCheckboxes ? _self.showCheckboxes : showCheckboxes // ignore: cast_nullable_to_non_nullable
as bool,isComposeHovered: null == isComposeHovered ? _self.isComposeHovered : isComposeHovered // ignore: cast_nullable_to_non_nullable
as bool,syncContact: null == syncContact ? _self.syncContact : syncContact // ignore: cast_nullable_to_non_nullable
as bool,isInProcess: null == isInProcess ? _self.isInProcess : isInProcess // ignore: cast_nullable_to_non_nullable
as bool,readingPaneEnabledWeb: null == readingPaneEnabledWeb ? _self.readingPaneEnabledWeb : readingPaneEnabledWeb // ignore: cast_nullable_to_non_nullable
as bool,previousPage: null == previousPage ? _self.previousPage : previousPage // ignore: cast_nullable_to_non_nullable
as int,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,searchKey: null == searchKey ? _self.searchKey : searchKey // ignore: cast_nullable_to_non_nullable
as String,selectedEmailIds: null == selectedEmailIds ? _self._selectedEmailIds : selectedEmailIds // ignore: cast_nullable_to_non_nullable
as List<int>,selectedEmails: null == selectedEmails ? _self._selectedEmails : selectedEmails // ignore: cast_nullable_to_non_nullable
as List<String>,lastClickedIndex: null == lastClickedIndex ? _self.lastClickedIndex : lastClickedIndex // ignore: cast_nullable_to_non_nullable
as int,badgeCount: null == badgeCount ? _self.badgeCount : badgeCount // ignore: cast_nullable_to_non_nullable
as int,emailType: freezed == emailType ? _self.emailType : emailType // ignore: cast_nullable_to_non_nullable
as String?,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,inboxList: freezed == inboxList ? _self.inboxList : inboxList // ignore: cast_nullable_to_non_nullable
as InboxListModel?,tagIdFilter: null == tagIdFilter ? _self._tagIdFilter : tagIdFilter // ignore: cast_nullable_to_non_nullable
as List<int>,totalEmailCount: null == totalEmailCount ? _self.totalEmailCount : totalEmailCount // ignore: cast_nullable_to_non_nullable
as int,selectedTagIds: null == selectedTagIds ? _self._selectedTagIds : selectedTagIds // ignore: cast_nullable_to_non_nullable
as List<int>,selectedEmailIdForReadingPane: freezed == selectedEmailIdForReadingPane ? _self.selectedEmailIdForReadingPane : selectedEmailIdForReadingPane // ignore: cast_nullable_to_non_nullable
as int?,composeInReadingPane: freezed == composeInReadingPane ? _self._composeInReadingPane : composeInReadingPane // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,selectedEmailTags: freezed == selectedEmailTags ? _self.selectedEmailTags : selectedEmailTags // ignore: cast_nullable_to_non_nullable
as TagsListModel?,selectedEmailIndex: freezed == selectedEmailIndex ? _self.selectedEmailIndex : selectedEmailIndex // ignore: cast_nullable_to_non_nullable
as int?,selectedEmailSender: freezed == selectedEmailSender ? _self.selectedEmailSender : selectedEmailSender // ignore: cast_nullable_to_non_nullable
as String?,readingPaneRefreshKey: null == readingPaneRefreshKey ? _self.readingPaneRefreshKey : readingPaneRefreshKey // ignore: cast_nullable_to_non_nullable
as int,currentlyViewedEmailId: freezed == currentlyViewedEmailId ? _self.currentlyViewedEmailId : currentlyViewedEmailId // ignore: cast_nullable_to_non_nullable
as int?,emailListPaneWidth: freezed == emailListPaneWidth ? _self.emailListPaneWidth : emailListPaneWidth // ignore: cast_nullable_to_non_nullable
as double?,readingPaneHeight: freezed == readingPaneHeight ? _self.readingPaneHeight : readingPaneHeight // ignore: cast_nullable_to_non_nullable
as double?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Emails>,userData: freezed == userData ? _self._userData : userData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,undoBuffer: null == undoBuffer ? _self._undoBuffer : undoBuffer // ignore: cast_nullable_to_non_nullable
as List<Emails>,undoIds: null == undoIds ? _self._undoIds : undoIds // ignore: cast_nullable_to_non_nullable
as List<int>,newNotification: null == newNotification ? _self.newNotification : newNotification // ignore: cast_nullable_to_non_nullable
as bool,pendingOptInEmail: freezed == pendingOptInEmail ? _self.pendingOptInEmail : pendingOptInEmail // ignore: cast_nullable_to_non_nullable
as String?,pendingOptInSenderName: freezed == pendingOptInSenderName ? _self.pendingOptInSenderName : pendingOptInSenderName // ignore: cast_nullable_to_non_nullable
as String?,pendingOptInEmails: null == pendingOptInEmails ? _self._pendingOptInEmails : pendingOptInEmails // ignore: cast_nullable_to_non_nullable
as List<String>,tagsItems: null == tagsItems ? _self._tagsItems : tagsItems // ignore: cast_nullable_to_non_nullable
as List<Tags>,showTagDialog: null == showTagDialog ? _self.showTagDialog : showTagDialog // ignore: cast_nullable_to_non_nullable
as bool,tagDialogEmailId: null == tagDialogEmailId ? _self.tagDialogEmailId : tagDialogEmailId // ignore: cast_nullable_to_non_nullable
as int,tagDialogItemIndex: null == tagDialogItemIndex ? _self.tagDialogItemIndex : tagDialogItemIndex // ignore: cast_nullable_to_non_nullable
as int,tagDialogIsMove: null == tagDialogIsMove ? _self.tagDialogIsMove : tagDialogIsMove // ignore: cast_nullable_to_non_nullable
as bool,tagDialogInitialTagIds: null == tagDialogInitialTagIds ? _self._tagDialogInitialTagIds : tagDialogInitialTagIds // ignore: cast_nullable_to_non_nullable
as List<int>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
