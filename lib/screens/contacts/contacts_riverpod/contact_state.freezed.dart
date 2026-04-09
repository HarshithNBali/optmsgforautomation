// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contact_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ContactState {

 bool get isLoading; bool get isInProcess; bool get isRefresh; bool get readingPaneEnabled; bool get clearSelectedContact; bool get isSearch; List<Contacts> get allContacts; List<Contacts> get filteredContacts; Contacts? get selectedContact; String get searchText; Map<String, dynamic>? get userData;// Filter state
 String get contactTypeFilter; bool get showFilter;// Multi-select state
 List<int> get selectedContactIds; bool get longPressFlag; bool get allContactsFlag; bool get showCheckboxes; int get lastClickedIndex;
/// Create a copy of ContactState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactStateCopyWith<ContactState> get copyWith => _$ContactStateCopyWithImpl<ContactState>(this as ContactState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isInProcess, isInProcess) || other.isInProcess == isInProcess)&&(identical(other.isRefresh, isRefresh) || other.isRefresh == isRefresh)&&(identical(other.readingPaneEnabled, readingPaneEnabled) || other.readingPaneEnabled == readingPaneEnabled)&&(identical(other.clearSelectedContact, clearSelectedContact) || other.clearSelectedContact == clearSelectedContact)&&(identical(other.isSearch, isSearch) || other.isSearch == isSearch)&&const DeepCollectionEquality().equals(other.allContacts, allContacts)&&const DeepCollectionEquality().equals(other.filteredContacts, filteredContacts)&&(identical(other.selectedContact, selectedContact) || other.selectedContact == selectedContact)&&(identical(other.searchText, searchText) || other.searchText == searchText)&&const DeepCollectionEquality().equals(other.userData, userData)&&(identical(other.contactTypeFilter, contactTypeFilter) || other.contactTypeFilter == contactTypeFilter)&&(identical(other.showFilter, showFilter) || other.showFilter == showFilter)&&const DeepCollectionEquality().equals(other.selectedContactIds, selectedContactIds)&&(identical(other.longPressFlag, longPressFlag) || other.longPressFlag == longPressFlag)&&(identical(other.allContactsFlag, allContactsFlag) || other.allContactsFlag == allContactsFlag)&&(identical(other.showCheckboxes, showCheckboxes) || other.showCheckboxes == showCheckboxes)&&(identical(other.lastClickedIndex, lastClickedIndex) || other.lastClickedIndex == lastClickedIndex));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,isInProcess,isRefresh,readingPaneEnabled,clearSelectedContact,isSearch,const DeepCollectionEquality().hash(allContacts),const DeepCollectionEquality().hash(filteredContacts),selectedContact,searchText,const DeepCollectionEquality().hash(userData),contactTypeFilter,showFilter,const DeepCollectionEquality().hash(selectedContactIds),longPressFlag,allContactsFlag,showCheckboxes,lastClickedIndex);

@override
String toString() {
  return 'ContactState(isLoading: $isLoading, isInProcess: $isInProcess, isRefresh: $isRefresh, readingPaneEnabled: $readingPaneEnabled, clearSelectedContact: $clearSelectedContact, isSearch: $isSearch, allContacts: $allContacts, filteredContacts: $filteredContacts, selectedContact: $selectedContact, searchText: $searchText, userData: $userData, contactTypeFilter: $contactTypeFilter, showFilter: $showFilter, selectedContactIds: $selectedContactIds, longPressFlag: $longPressFlag, allContactsFlag: $allContactsFlag, showCheckboxes: $showCheckboxes, lastClickedIndex: $lastClickedIndex)';
}


}

/// @nodoc
abstract mixin class $ContactStateCopyWith<$Res>  {
  factory $ContactStateCopyWith(ContactState value, $Res Function(ContactState) _then) = _$ContactStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, bool isInProcess, bool isRefresh, bool readingPaneEnabled, bool clearSelectedContact, bool isSearch, List<Contacts> allContacts, List<Contacts> filteredContacts, Contacts? selectedContact, String searchText, Map<String, dynamic>? userData, String contactTypeFilter, bool showFilter, List<int> selectedContactIds, bool longPressFlag, bool allContactsFlag, bool showCheckboxes, int lastClickedIndex
});




}
/// @nodoc
class _$ContactStateCopyWithImpl<$Res>
    implements $ContactStateCopyWith<$Res> {
  _$ContactStateCopyWithImpl(this._self, this._then);

  final ContactState _self;
  final $Res Function(ContactState) _then;

/// Create a copy of ContactState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? isInProcess = null,Object? isRefresh = null,Object? readingPaneEnabled = null,Object? clearSelectedContact = null,Object? isSearch = null,Object? allContacts = null,Object? filteredContacts = null,Object? selectedContact = freezed,Object? searchText = null,Object? userData = freezed,Object? contactTypeFilter = null,Object? showFilter = null,Object? selectedContactIds = null,Object? longPressFlag = null,Object? allContactsFlag = null,Object? showCheckboxes = null,Object? lastClickedIndex = null,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isInProcess: null == isInProcess ? _self.isInProcess : isInProcess // ignore: cast_nullable_to_non_nullable
as bool,isRefresh: null == isRefresh ? _self.isRefresh : isRefresh // ignore: cast_nullable_to_non_nullable
as bool,readingPaneEnabled: null == readingPaneEnabled ? _self.readingPaneEnabled : readingPaneEnabled // ignore: cast_nullable_to_non_nullable
as bool,clearSelectedContact: null == clearSelectedContact ? _self.clearSelectedContact : clearSelectedContact // ignore: cast_nullable_to_non_nullable
as bool,isSearch: null == isSearch ? _self.isSearch : isSearch // ignore: cast_nullable_to_non_nullable
as bool,allContacts: null == allContacts ? _self.allContacts : allContacts // ignore: cast_nullable_to_non_nullable
as List<Contacts>,filteredContacts: null == filteredContacts ? _self.filteredContacts : filteredContacts // ignore: cast_nullable_to_non_nullable
as List<Contacts>,selectedContact: freezed == selectedContact ? _self.selectedContact : selectedContact // ignore: cast_nullable_to_non_nullable
as Contacts?,searchText: null == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String,userData: freezed == userData ? _self.userData : userData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,contactTypeFilter: null == contactTypeFilter ? _self.contactTypeFilter : contactTypeFilter // ignore: cast_nullable_to_non_nullable
as String,showFilter: null == showFilter ? _self.showFilter : showFilter // ignore: cast_nullable_to_non_nullable
as bool,selectedContactIds: null == selectedContactIds ? _self.selectedContactIds : selectedContactIds // ignore: cast_nullable_to_non_nullable
as List<int>,longPressFlag: null == longPressFlag ? _self.longPressFlag : longPressFlag // ignore: cast_nullable_to_non_nullable
as bool,allContactsFlag: null == allContactsFlag ? _self.allContactsFlag : allContactsFlag // ignore: cast_nullable_to_non_nullable
as bool,showCheckboxes: null == showCheckboxes ? _self.showCheckboxes : showCheckboxes // ignore: cast_nullable_to_non_nullable
as bool,lastClickedIndex: null == lastClickedIndex ? _self.lastClickedIndex : lastClickedIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ContactState].
extension ContactStatePatterns on ContactState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContactState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContactState value)  $default,){
final _that = this;
switch (_that) {
case _ContactState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContactState value)?  $default,){
final _that = this;
switch (_that) {
case _ContactState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  bool isInProcess,  bool isRefresh,  bool readingPaneEnabled,  bool clearSelectedContact,  bool isSearch,  List<Contacts> allContacts,  List<Contacts> filteredContacts,  Contacts? selectedContact,  String searchText,  Map<String, dynamic>? userData,  String contactTypeFilter,  bool showFilter,  List<int> selectedContactIds,  bool longPressFlag,  bool allContactsFlag,  bool showCheckboxes,  int lastClickedIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactState() when $default != null:
return $default(_that.isLoading,_that.isInProcess,_that.isRefresh,_that.readingPaneEnabled,_that.clearSelectedContact,_that.isSearch,_that.allContacts,_that.filteredContacts,_that.selectedContact,_that.searchText,_that.userData,_that.contactTypeFilter,_that.showFilter,_that.selectedContactIds,_that.longPressFlag,_that.allContactsFlag,_that.showCheckboxes,_that.lastClickedIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  bool isInProcess,  bool isRefresh,  bool readingPaneEnabled,  bool clearSelectedContact,  bool isSearch,  List<Contacts> allContacts,  List<Contacts> filteredContacts,  Contacts? selectedContact,  String searchText,  Map<String, dynamic>? userData,  String contactTypeFilter,  bool showFilter,  List<int> selectedContactIds,  bool longPressFlag,  bool allContactsFlag,  bool showCheckboxes,  int lastClickedIndex)  $default,) {final _that = this;
switch (_that) {
case _ContactState():
return $default(_that.isLoading,_that.isInProcess,_that.isRefresh,_that.readingPaneEnabled,_that.clearSelectedContact,_that.isSearch,_that.allContacts,_that.filteredContacts,_that.selectedContact,_that.searchText,_that.userData,_that.contactTypeFilter,_that.showFilter,_that.selectedContactIds,_that.longPressFlag,_that.allContactsFlag,_that.showCheckboxes,_that.lastClickedIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  bool isInProcess,  bool isRefresh,  bool readingPaneEnabled,  bool clearSelectedContact,  bool isSearch,  List<Contacts> allContacts,  List<Contacts> filteredContacts,  Contacts? selectedContact,  String searchText,  Map<String, dynamic>? userData,  String contactTypeFilter,  bool showFilter,  List<int> selectedContactIds,  bool longPressFlag,  bool allContactsFlag,  bool showCheckboxes,  int lastClickedIndex)?  $default,) {final _that = this;
switch (_that) {
case _ContactState() when $default != null:
return $default(_that.isLoading,_that.isInProcess,_that.isRefresh,_that.readingPaneEnabled,_that.clearSelectedContact,_that.isSearch,_that.allContacts,_that.filteredContacts,_that.selectedContact,_that.searchText,_that.userData,_that.contactTypeFilter,_that.showFilter,_that.selectedContactIds,_that.longPressFlag,_that.allContactsFlag,_that.showCheckboxes,_that.lastClickedIndex);case _:
  return null;

}
}

}

/// @nodoc


class _ContactState extends ContactState {
  const _ContactState({this.isLoading = true, this.isInProcess = false, this.isRefresh = false, this.readingPaneEnabled = false, this.clearSelectedContact = false, this.isSearch = false, final  List<Contacts> allContacts = const [], final  List<Contacts> filteredContacts = const [], this.selectedContact, this.searchText = '', final  Map<String, dynamic>? userData, this.contactTypeFilter = 'all', this.showFilter = false, final  List<int> selectedContactIds = const [], this.longPressFlag = true, this.allContactsFlag = false, this.showCheckboxes = false, this.lastClickedIndex = -1}): _allContacts = allContacts,_filteredContacts = filteredContacts,_userData = userData,_selectedContactIds = selectedContactIds,super._();
  

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isInProcess;
@override@JsonKey() final  bool isRefresh;
@override@JsonKey() final  bool readingPaneEnabled;
@override@JsonKey() final  bool clearSelectedContact;
@override@JsonKey() final  bool isSearch;
 final  List<Contacts> _allContacts;
@override@JsonKey() List<Contacts> get allContacts {
  if (_allContacts is EqualUnmodifiableListView) return _allContacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allContacts);
}

 final  List<Contacts> _filteredContacts;
@override@JsonKey() List<Contacts> get filteredContacts {
  if (_filteredContacts is EqualUnmodifiableListView) return _filteredContacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_filteredContacts);
}

@override final  Contacts? selectedContact;
@override@JsonKey() final  String searchText;
 final  Map<String, dynamic>? _userData;
@override Map<String, dynamic>? get userData {
  final value = _userData;
  if (value == null) return null;
  if (_userData is EqualUnmodifiableMapView) return _userData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

// Filter state
@override@JsonKey() final  String contactTypeFilter;
@override@JsonKey() final  bool showFilter;
// Multi-select state
 final  List<int> _selectedContactIds;
// Multi-select state
@override@JsonKey() List<int> get selectedContactIds {
  if (_selectedContactIds is EqualUnmodifiableListView) return _selectedContactIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedContactIds);
}

@override@JsonKey() final  bool longPressFlag;
@override@JsonKey() final  bool allContactsFlag;
@override@JsonKey() final  bool showCheckboxes;
@override@JsonKey() final  int lastClickedIndex;

/// Create a copy of ContactState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactStateCopyWith<_ContactState> get copyWith => __$ContactStateCopyWithImpl<_ContactState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isInProcess, isInProcess) || other.isInProcess == isInProcess)&&(identical(other.isRefresh, isRefresh) || other.isRefresh == isRefresh)&&(identical(other.readingPaneEnabled, readingPaneEnabled) || other.readingPaneEnabled == readingPaneEnabled)&&(identical(other.clearSelectedContact, clearSelectedContact) || other.clearSelectedContact == clearSelectedContact)&&(identical(other.isSearch, isSearch) || other.isSearch == isSearch)&&const DeepCollectionEquality().equals(other._allContacts, _allContacts)&&const DeepCollectionEquality().equals(other._filteredContacts, _filteredContacts)&&(identical(other.selectedContact, selectedContact) || other.selectedContact == selectedContact)&&(identical(other.searchText, searchText) || other.searchText == searchText)&&const DeepCollectionEquality().equals(other._userData, _userData)&&(identical(other.contactTypeFilter, contactTypeFilter) || other.contactTypeFilter == contactTypeFilter)&&(identical(other.showFilter, showFilter) || other.showFilter == showFilter)&&const DeepCollectionEquality().equals(other._selectedContactIds, _selectedContactIds)&&(identical(other.longPressFlag, longPressFlag) || other.longPressFlag == longPressFlag)&&(identical(other.allContactsFlag, allContactsFlag) || other.allContactsFlag == allContactsFlag)&&(identical(other.showCheckboxes, showCheckboxes) || other.showCheckboxes == showCheckboxes)&&(identical(other.lastClickedIndex, lastClickedIndex) || other.lastClickedIndex == lastClickedIndex));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,isInProcess,isRefresh,readingPaneEnabled,clearSelectedContact,isSearch,const DeepCollectionEquality().hash(_allContacts),const DeepCollectionEquality().hash(_filteredContacts),selectedContact,searchText,const DeepCollectionEquality().hash(_userData),contactTypeFilter,showFilter,const DeepCollectionEquality().hash(_selectedContactIds),longPressFlag,allContactsFlag,showCheckboxes,lastClickedIndex);

@override
String toString() {
  return 'ContactState(isLoading: $isLoading, isInProcess: $isInProcess, isRefresh: $isRefresh, readingPaneEnabled: $readingPaneEnabled, clearSelectedContact: $clearSelectedContact, isSearch: $isSearch, allContacts: $allContacts, filteredContacts: $filteredContacts, selectedContact: $selectedContact, searchText: $searchText, userData: $userData, contactTypeFilter: $contactTypeFilter, showFilter: $showFilter, selectedContactIds: $selectedContactIds, longPressFlag: $longPressFlag, allContactsFlag: $allContactsFlag, showCheckboxes: $showCheckboxes, lastClickedIndex: $lastClickedIndex)';
}


}

/// @nodoc
abstract mixin class _$ContactStateCopyWith<$Res> implements $ContactStateCopyWith<$Res> {
  factory _$ContactStateCopyWith(_ContactState value, $Res Function(_ContactState) _then) = __$ContactStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, bool isInProcess, bool isRefresh, bool readingPaneEnabled, bool clearSelectedContact, bool isSearch, List<Contacts> allContacts, List<Contacts> filteredContacts, Contacts? selectedContact, String searchText, Map<String, dynamic>? userData, String contactTypeFilter, bool showFilter, List<int> selectedContactIds, bool longPressFlag, bool allContactsFlag, bool showCheckboxes, int lastClickedIndex
});




}
/// @nodoc
class __$ContactStateCopyWithImpl<$Res>
    implements _$ContactStateCopyWith<$Res> {
  __$ContactStateCopyWithImpl(this._self, this._then);

  final _ContactState _self;
  final $Res Function(_ContactState) _then;

/// Create a copy of ContactState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? isInProcess = null,Object? isRefresh = null,Object? readingPaneEnabled = null,Object? clearSelectedContact = null,Object? isSearch = null,Object? allContacts = null,Object? filteredContacts = null,Object? selectedContact = freezed,Object? searchText = null,Object? userData = freezed,Object? contactTypeFilter = null,Object? showFilter = null,Object? selectedContactIds = null,Object? longPressFlag = null,Object? allContactsFlag = null,Object? showCheckboxes = null,Object? lastClickedIndex = null,}) {
  return _then(_ContactState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isInProcess: null == isInProcess ? _self.isInProcess : isInProcess // ignore: cast_nullable_to_non_nullable
as bool,isRefresh: null == isRefresh ? _self.isRefresh : isRefresh // ignore: cast_nullable_to_non_nullable
as bool,readingPaneEnabled: null == readingPaneEnabled ? _self.readingPaneEnabled : readingPaneEnabled // ignore: cast_nullable_to_non_nullable
as bool,clearSelectedContact: null == clearSelectedContact ? _self.clearSelectedContact : clearSelectedContact // ignore: cast_nullable_to_non_nullable
as bool,isSearch: null == isSearch ? _self.isSearch : isSearch // ignore: cast_nullable_to_non_nullable
as bool,allContacts: null == allContacts ? _self._allContacts : allContacts // ignore: cast_nullable_to_non_nullable
as List<Contacts>,filteredContacts: null == filteredContacts ? _self._filteredContacts : filteredContacts // ignore: cast_nullable_to_non_nullable
as List<Contacts>,selectedContact: freezed == selectedContact ? _self.selectedContact : selectedContact // ignore: cast_nullable_to_non_nullable
as Contacts?,searchText: null == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String,userData: freezed == userData ? _self._userData : userData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,contactTypeFilter: null == contactTypeFilter ? _self.contactTypeFilter : contactTypeFilter // ignore: cast_nullable_to_non_nullable
as String,showFilter: null == showFilter ? _self.showFilter : showFilter // ignore: cast_nullable_to_non_nullable
as bool,selectedContactIds: null == selectedContactIds ? _self._selectedContactIds : selectedContactIds // ignore: cast_nullable_to_non_nullable
as List<int>,longPressFlag: null == longPressFlag ? _self.longPressFlag : longPressFlag // ignore: cast_nullable_to_non_nullable
as bool,allContactsFlag: null == allContactsFlag ? _self.allContactsFlag : allContactsFlag // ignore: cast_nullable_to_non_nullable
as bool,showCheckboxes: null == showCheckboxes ? _self.showCheckboxes : showCheckboxes // ignore: cast_nullable_to_non_nullable
as bool,lastClickedIndex: null == lastClickedIndex ? _self.lastClickedIndex : lastClickedIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
