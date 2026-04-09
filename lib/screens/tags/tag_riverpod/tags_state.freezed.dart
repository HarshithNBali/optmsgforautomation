// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tags_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TagsState {

// Data
 TagsListModel? get tagsList; int? get id;// Flags
 bool get isLoading; bool get editFlag;// Multi-select
 List<int> get selectedTagIds; bool get showCheckboxes; bool get longPressFlag; bool get allTagsFlag; int get lastClickedIndex;
/// Create a copy of TagsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TagsStateCopyWith<TagsState> get copyWith => _$TagsStateCopyWithImpl<TagsState>(this as TagsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TagsState&&(identical(other.tagsList, tagsList) || other.tagsList == tagsList)&&(identical(other.id, id) || other.id == id)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.editFlag, editFlag) || other.editFlag == editFlag)&&const DeepCollectionEquality().equals(other.selectedTagIds, selectedTagIds)&&(identical(other.showCheckboxes, showCheckboxes) || other.showCheckboxes == showCheckboxes)&&(identical(other.longPressFlag, longPressFlag) || other.longPressFlag == longPressFlag)&&(identical(other.allTagsFlag, allTagsFlag) || other.allTagsFlag == allTagsFlag)&&(identical(other.lastClickedIndex, lastClickedIndex) || other.lastClickedIndex == lastClickedIndex));
}


@override
int get hashCode => Object.hash(runtimeType,tagsList,id,isLoading,editFlag,const DeepCollectionEquality().hash(selectedTagIds),showCheckboxes,longPressFlag,allTagsFlag,lastClickedIndex);

@override
String toString() {
  return 'TagsState(tagsList: $tagsList, id: $id, isLoading: $isLoading, editFlag: $editFlag, selectedTagIds: $selectedTagIds, showCheckboxes: $showCheckboxes, longPressFlag: $longPressFlag, allTagsFlag: $allTagsFlag, lastClickedIndex: $lastClickedIndex)';
}


}

/// @nodoc
abstract mixin class $TagsStateCopyWith<$Res>  {
  factory $TagsStateCopyWith(TagsState value, $Res Function(TagsState) _then) = _$TagsStateCopyWithImpl;
@useResult
$Res call({
 TagsListModel? tagsList, int? id, bool isLoading, bool editFlag, List<int> selectedTagIds, bool showCheckboxes, bool longPressFlag, bool allTagsFlag, int lastClickedIndex
});




}
/// @nodoc
class _$TagsStateCopyWithImpl<$Res>
    implements $TagsStateCopyWith<$Res> {
  _$TagsStateCopyWithImpl(this._self, this._then);

  final TagsState _self;
  final $Res Function(TagsState) _then;

/// Create a copy of TagsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tagsList = freezed,Object? id = freezed,Object? isLoading = null,Object? editFlag = null,Object? selectedTagIds = null,Object? showCheckboxes = null,Object? longPressFlag = null,Object? allTagsFlag = null,Object? lastClickedIndex = null,}) {
  return _then(_self.copyWith(
tagsList: freezed == tagsList ? _self.tagsList : tagsList // ignore: cast_nullable_to_non_nullable
as TagsListModel?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,editFlag: null == editFlag ? _self.editFlag : editFlag // ignore: cast_nullable_to_non_nullable
as bool,selectedTagIds: null == selectedTagIds ? _self.selectedTagIds : selectedTagIds // ignore: cast_nullable_to_non_nullable
as List<int>,showCheckboxes: null == showCheckboxes ? _self.showCheckboxes : showCheckboxes // ignore: cast_nullable_to_non_nullable
as bool,longPressFlag: null == longPressFlag ? _self.longPressFlag : longPressFlag // ignore: cast_nullable_to_non_nullable
as bool,allTagsFlag: null == allTagsFlag ? _self.allTagsFlag : allTagsFlag // ignore: cast_nullable_to_non_nullable
as bool,lastClickedIndex: null == lastClickedIndex ? _self.lastClickedIndex : lastClickedIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TagsState].
extension TagsStatePatterns on TagsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TagsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TagsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TagsState value)  $default,){
final _that = this;
switch (_that) {
case _TagsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TagsState value)?  $default,){
final _that = this;
switch (_that) {
case _TagsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TagsListModel? tagsList,  int? id,  bool isLoading,  bool editFlag,  List<int> selectedTagIds,  bool showCheckboxes,  bool longPressFlag,  bool allTagsFlag,  int lastClickedIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TagsState() when $default != null:
return $default(_that.tagsList,_that.id,_that.isLoading,_that.editFlag,_that.selectedTagIds,_that.showCheckboxes,_that.longPressFlag,_that.allTagsFlag,_that.lastClickedIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TagsListModel? tagsList,  int? id,  bool isLoading,  bool editFlag,  List<int> selectedTagIds,  bool showCheckboxes,  bool longPressFlag,  bool allTagsFlag,  int lastClickedIndex)  $default,) {final _that = this;
switch (_that) {
case _TagsState():
return $default(_that.tagsList,_that.id,_that.isLoading,_that.editFlag,_that.selectedTagIds,_that.showCheckboxes,_that.longPressFlag,_that.allTagsFlag,_that.lastClickedIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TagsListModel? tagsList,  int? id,  bool isLoading,  bool editFlag,  List<int> selectedTagIds,  bool showCheckboxes,  bool longPressFlag,  bool allTagsFlag,  int lastClickedIndex)?  $default,) {final _that = this;
switch (_that) {
case _TagsState() when $default != null:
return $default(_that.tagsList,_that.id,_that.isLoading,_that.editFlag,_that.selectedTagIds,_that.showCheckboxes,_that.longPressFlag,_that.allTagsFlag,_that.lastClickedIndex);case _:
  return null;

}
}

}

/// @nodoc


class _TagsState extends TagsState {
  const _TagsState({this.tagsList, this.id, this.isLoading = false, this.editFlag = false, final  List<int> selectedTagIds = const [], this.showCheckboxes = false, this.longPressFlag = true, this.allTagsFlag = false, this.lastClickedIndex = -1}): _selectedTagIds = selectedTagIds,super._();
  

// Data
@override final  TagsListModel? tagsList;
@override final  int? id;
// Flags
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool editFlag;
// Multi-select
 final  List<int> _selectedTagIds;
// Multi-select
@override@JsonKey() List<int> get selectedTagIds {
  if (_selectedTagIds is EqualUnmodifiableListView) return _selectedTagIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedTagIds);
}

@override@JsonKey() final  bool showCheckboxes;
@override@JsonKey() final  bool longPressFlag;
@override@JsonKey() final  bool allTagsFlag;
@override@JsonKey() final  int lastClickedIndex;

/// Create a copy of TagsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TagsStateCopyWith<_TagsState> get copyWith => __$TagsStateCopyWithImpl<_TagsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TagsState&&(identical(other.tagsList, tagsList) || other.tagsList == tagsList)&&(identical(other.id, id) || other.id == id)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.editFlag, editFlag) || other.editFlag == editFlag)&&const DeepCollectionEquality().equals(other._selectedTagIds, _selectedTagIds)&&(identical(other.showCheckboxes, showCheckboxes) || other.showCheckboxes == showCheckboxes)&&(identical(other.longPressFlag, longPressFlag) || other.longPressFlag == longPressFlag)&&(identical(other.allTagsFlag, allTagsFlag) || other.allTagsFlag == allTagsFlag)&&(identical(other.lastClickedIndex, lastClickedIndex) || other.lastClickedIndex == lastClickedIndex));
}


@override
int get hashCode => Object.hash(runtimeType,tagsList,id,isLoading,editFlag,const DeepCollectionEquality().hash(_selectedTagIds),showCheckboxes,longPressFlag,allTagsFlag,lastClickedIndex);

@override
String toString() {
  return 'TagsState(tagsList: $tagsList, id: $id, isLoading: $isLoading, editFlag: $editFlag, selectedTagIds: $selectedTagIds, showCheckboxes: $showCheckboxes, longPressFlag: $longPressFlag, allTagsFlag: $allTagsFlag, lastClickedIndex: $lastClickedIndex)';
}


}

/// @nodoc
abstract mixin class _$TagsStateCopyWith<$Res> implements $TagsStateCopyWith<$Res> {
  factory _$TagsStateCopyWith(_TagsState value, $Res Function(_TagsState) _then) = __$TagsStateCopyWithImpl;
@override @useResult
$Res call({
 TagsListModel? tagsList, int? id, bool isLoading, bool editFlag, List<int> selectedTagIds, bool showCheckboxes, bool longPressFlag, bool allTagsFlag, int lastClickedIndex
});




}
/// @nodoc
class __$TagsStateCopyWithImpl<$Res>
    implements _$TagsStateCopyWith<$Res> {
  __$TagsStateCopyWithImpl(this._self, this._then);

  final _TagsState _self;
  final $Res Function(_TagsState) _then;

/// Create a copy of TagsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tagsList = freezed,Object? id = freezed,Object? isLoading = null,Object? editFlag = null,Object? selectedTagIds = null,Object? showCheckboxes = null,Object? longPressFlag = null,Object? allTagsFlag = null,Object? lastClickedIndex = null,}) {
  return _then(_TagsState(
tagsList: freezed == tagsList ? _self.tagsList : tagsList // ignore: cast_nullable_to_non_nullable
as TagsListModel?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,editFlag: null == editFlag ? _self.editFlag : editFlag // ignore: cast_nullable_to_non_nullable
as bool,selectedTagIds: null == selectedTagIds ? _self._selectedTagIds : selectedTagIds // ignore: cast_nullable_to_non_nullable
as List<int>,showCheckboxes: null == showCheckboxes ? _self.showCheckboxes : showCheckboxes // ignore: cast_nullable_to_non_nullable
as bool,longPressFlag: null == longPressFlag ? _self.longPressFlag : longPressFlag // ignore: cast_nullable_to_non_nullable
as bool,allTagsFlag: null == allTagsFlag ? _self.allTagsFlag : allTagsFlag // ignore: cast_nullable_to_non_nullable
as bool,lastClickedIndex: null == lastClickedIndex ? _self.lastClickedIndex : lastClickedIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
