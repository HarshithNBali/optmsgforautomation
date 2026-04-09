// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'help_center_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HelpCenterState {

// Flags
 bool get isLoading;// UI State
 String get selectedCategory; String get searchQuery; List<String> get expandedItems;
/// Create a copy of HelpCenterState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HelpCenterStateCopyWith<HelpCenterState> get copyWith => _$HelpCenterStateCopyWithImpl<HelpCenterState>(this as HelpCenterState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HelpCenterState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.selectedCategory, selectedCategory) || other.selectedCategory == selectedCategory)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&const DeepCollectionEquality().equals(other.expandedItems, expandedItems));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,selectedCategory,searchQuery,const DeepCollectionEquality().hash(expandedItems));

@override
String toString() {
  return 'HelpCenterState(isLoading: $isLoading, selectedCategory: $selectedCategory, searchQuery: $searchQuery, expandedItems: $expandedItems)';
}


}

/// @nodoc
abstract mixin class $HelpCenterStateCopyWith<$Res>  {
  factory $HelpCenterStateCopyWith(HelpCenterState value, $Res Function(HelpCenterState) _then) = _$HelpCenterStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, String selectedCategory, String searchQuery, List<String> expandedItems
});




}
/// @nodoc
class _$HelpCenterStateCopyWithImpl<$Res>
    implements $HelpCenterStateCopyWith<$Res> {
  _$HelpCenterStateCopyWithImpl(this._self, this._then);

  final HelpCenterState _self;
  final $Res Function(HelpCenterState) _then;

/// Create a copy of HelpCenterState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? selectedCategory = null,Object? searchQuery = null,Object? expandedItems = null,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,selectedCategory: null == selectedCategory ? _self.selectedCategory : selectedCategory // ignore: cast_nullable_to_non_nullable
as String,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,expandedItems: null == expandedItems ? _self.expandedItems : expandedItems // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [HelpCenterState].
extension HelpCenterStatePatterns on HelpCenterState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HelpCenterState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HelpCenterState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HelpCenterState value)  $default,){
final _that = this;
switch (_that) {
case _HelpCenterState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HelpCenterState value)?  $default,){
final _that = this;
switch (_that) {
case _HelpCenterState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  String selectedCategory,  String searchQuery,  List<String> expandedItems)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HelpCenterState() when $default != null:
return $default(_that.isLoading,_that.selectedCategory,_that.searchQuery,_that.expandedItems);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  String selectedCategory,  String searchQuery,  List<String> expandedItems)  $default,) {final _that = this;
switch (_that) {
case _HelpCenterState():
return $default(_that.isLoading,_that.selectedCategory,_that.searchQuery,_that.expandedItems);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  String selectedCategory,  String searchQuery,  List<String> expandedItems)?  $default,) {final _that = this;
switch (_that) {
case _HelpCenterState() when $default != null:
return $default(_that.isLoading,_that.selectedCategory,_that.searchQuery,_that.expandedItems);case _:
  return null;

}
}

}

/// @nodoc


class _HelpCenterState extends HelpCenterState {
  const _HelpCenterState({this.isLoading = false, this.selectedCategory = '', this.searchQuery = '', final  List<String> expandedItems = const []}): _expandedItems = expandedItems,super._();
  

// Flags
@override@JsonKey() final  bool isLoading;
// UI State
@override@JsonKey() final  String selectedCategory;
@override@JsonKey() final  String searchQuery;
 final  List<String> _expandedItems;
@override@JsonKey() List<String> get expandedItems {
  if (_expandedItems is EqualUnmodifiableListView) return _expandedItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_expandedItems);
}


/// Create a copy of HelpCenterState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HelpCenterStateCopyWith<_HelpCenterState> get copyWith => __$HelpCenterStateCopyWithImpl<_HelpCenterState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HelpCenterState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.selectedCategory, selectedCategory) || other.selectedCategory == selectedCategory)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&const DeepCollectionEquality().equals(other._expandedItems, _expandedItems));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,selectedCategory,searchQuery,const DeepCollectionEquality().hash(_expandedItems));

@override
String toString() {
  return 'HelpCenterState(isLoading: $isLoading, selectedCategory: $selectedCategory, searchQuery: $searchQuery, expandedItems: $expandedItems)';
}


}

/// @nodoc
abstract mixin class _$HelpCenterStateCopyWith<$Res> implements $HelpCenterStateCopyWith<$Res> {
  factory _$HelpCenterStateCopyWith(_HelpCenterState value, $Res Function(_HelpCenterState) _then) = __$HelpCenterStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, String selectedCategory, String searchQuery, List<String> expandedItems
});




}
/// @nodoc
class __$HelpCenterStateCopyWithImpl<$Res>
    implements _$HelpCenterStateCopyWith<$Res> {
  __$HelpCenterStateCopyWithImpl(this._self, this._then);

  final _HelpCenterState _self;
  final $Res Function(_HelpCenterState) _then;

/// Create a copy of HelpCenterState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? selectedCategory = null,Object? searchQuery = null,Object? expandedItems = null,}) {
  return _then(_HelpCenterState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,selectedCategory: null == selectedCategory ? _self.selectedCategory : selectedCategory // ignore: cast_nullable_to_non_nullable
as String,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,expandedItems: null == expandedItems ? _self._expandedItems : expandedItems // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
